import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class StepTrackingService extends GetxService {
  var steps = 0.obs; // Observable to hold the step count
  var calories = 0.0.obs; // Observable to hold calories
  var distance = 0.0.obs; // Observable to hold distance
  var minutes = 0.obs; // Observable to hold minutes

  User? _user; // Firebase user
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late StreamSubscription<StepCount> _stepCountSubscription;
  int? _initialSteps;
  int _lastSavedSteps = 0;
  bool _isTracking = false;
  String gender = 'male'; // Giá trị mặc định, bạn có thể thay đổi

  // Biến để lưu trữ bước và thời gian lần trước
  int? lastStepCount;
  DateTime? lastStepTime;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        print("Current user: ${_user?.uid}");
        initialize();
      } else {
        print("User is not logged in.");
        stopListening();
      }
    });
  }

  // Initialize the service
  Future<void> initialize() async {
    print("Initializing StepTrackingService");
    await _checkAndRequestPermission();
    await loadSteps(); // Load step count from Firestore
    await loadUserGender(); // Load gender từ Firestore
    if (_isTracking) {
      startListening();
    }
    print("StepTrackingService initialized with ${steps.value} steps and gender: $gender");
  }

  // Check and request necessary permissions
  Future<void> _checkAndRequestPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;

    if (status.isGranted) {
      // Permission granted
    } else {
      status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        _showPermissionDeniedDialog();
      }
    }
  }

  // Show dialog when permission is denied
  void _showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Cần Quyền Vận Động",
      middleText:
          "Vui lòng cấp quyền vận động để ứng dụng có thể theo dõi hoạt động của bạn.",
      onConfirm: () {
        Get.back();
      },
      textConfirm: "OK",
    );
  }

  // Load gender từ Firestore
  Future<void> loadUserGender() async {
    if (_user == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        gender = (userData['gender'] ?? 'male').toString().toLowerCase();
        print("User gender: $gender");
      } else {
        print("User document does not exist.");
        gender = 'male'; // Giá trị mặc định nếu không tìm thấy
      }
    } catch (e) {
      print("Error loading user gender: $e");
      gender = 'male'; // Giá trị mặc định trong trường hợp lỗi
    }
  }

  // Start listening to step count stream
  void startListening() {
    if (_isTracking) return; // Already listening
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
      cancelOnError: false,
    );
    _isTracking = true;
    print("Started listening to step count stream");
  }

  // Stop listening to step count stream
  void stopListening() {
    if (_isTracking) {
      _stepCountSubscription.cancel();
      _isTracking = false;
      print("Stopped listening to step count stream");
    }
  }

  // Handle step count events
  void onStepCount(StepCount event) {
    if (!_isTracking) return;

    DateTime now = DateTime.now();

    if (_initialSteps == null) {
      _initialSteps = event.steps;
      lastStepCount = event.steps;
      lastStepTime = now;
      print("Initial steps set to $_initialSteps");
      updateData();
      saveStepsToFirebase();
      return;
    }

    int newSteps = event.steps - lastStepCount!;
    Duration timeDiff = now.difference(lastStepTime!);

    if (timeDiff.inSeconds == 0) {
      // Tránh chia cho 0
      return;
    }

    double stepsPerMinute = (newSteps / timeDiff.inSeconds) * 60;

    // Kiểm tra xem số bước có nằm trong khoảng bình thường không
    bool isValid = false;
    if (gender == 'male') {
      isValid = stepsPerMinute >= 90 && stepsPerMinute <= 130;
    } else if (gender == 'female') {
      isValid = stepsPerMinute >= 80 && stepsPerMinute <= 120;
    }

    if (isValid) {
      steps.value = _lastSavedSteps + newSteps;
      updateData();
      saveStepsToFirebase();
      _lastSavedSteps = steps.value;
    } else {
      print("Số bước không hợp lý: $newSteps với tần suất $stepsPerMinute bước/phút");
    }

    // Cập nhật các giá trị cho lần sau
    lastStepCount = event.steps;
    lastStepTime = now;
  }

  // Handle step count errors
  void onStepCountError(error) {
    print("Step Count Error: $error");
    // Có thể hiển thị thông báo cho người dùng hoặc thử khởi động lại luồng
  }

  // Update các giá trị phụ như calo, khoảng cách, thời gian
  void updateData() {
    calories.value = steps.value * 0.04; // Ví dụ: 0.04 kcal/bước
    distance.value = steps.value * 0.000762; // Ví dụ: 0.000762 km/bước

    if (lastStepTime != null && _initialSteps != null) {
      Duration duration = DateTime.now().difference(lastStepTime!);
      minutes.value = duration.inMinutes;
    }
  }

  // Save steps to Firebase
  Future<void> saveStepsToFirebase() async {
    if (_user == null) return;

    try {
      DateTime now = DateTime.now();
      String todayKey = "${now.year}-${now.month}-${now.day}";

      CollectionReference dataCollection =
          _firestore.collection('activity_data');

      await dataCollection.doc(_user!.uid).set({
        'date': todayKey,
        'steps': steps.value,
        'calories': calories.value,
        'distance': distance.value,
        'minutes': minutes.value,
        // Thêm các trường khác nếu cần
      }, SetOptions(merge: true));

      print("Saved ${steps.value} steps to Firebase");
    } catch (e) {
      print("Error saving steps to Firebase: $e");
    }
  }

// Load steps for today from Firestore
Future<void> loadTodaySteps() async {
  if (_user == null) return; // Kiểm tra nếu người dùng đã đăng nhập

  try {
    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";

    final stepData = await _firestore
        .collection('activity_data')
        .doc(_user!.uid)
        .get();

    if (stepData.exists && stepData.data()?['steps'] != null) {
      steps.value = stepData.data()!['steps'];
      print("Loaded today's steps: ${steps.value}");
    } else {
      steps.value = 0; // Nếu không có dữ liệu, gán là 0
      print("No step data found for today.");
    }
  } catch (e) {
    print("Error loading today's steps: $e");
  }
}


  // Toggle tracking on/off
  Future<void> toggleTracking() async {
    if (_isTracking) {
      stopListening();
    } else {
      await _checkAndRequestPermission();
      await loadUserGender(); // Đảm bảo gender được tải lại trước khi bắt đầu
      startListening();
    }
    // Cập nhật trạng thái theo dõi lên Firebase nếu cần
    await saveStepsToFirebase();
  }

  // Load steps from Firestore
  Future<void> loadSteps() async {
    try {
      if (_user != null) {
        final stepData = await _firestore.collection('activity_data').doc(_user!.uid).get();

        print("Step data exists: ${stepData.exists}");
        print("Step data: ${stepData.data()}");

        if (stepData.exists && stepData.data()?['steps'] != null) {
          steps.value = stepData.data()!['steps'];
          _lastSavedSteps = steps.value;
          print("Loaded ${steps.value} steps from Firebase");
        } else {
          print("No valid step data found for this user.");
          steps.value = 0;
          _lastSavedSteps = 0;
        }
      } else {
        print("User is not logged in.");
      }
    } catch (e) {
      print("Error loading steps: $e");
    }
  }

  // Getter to return the step count as a formatted string
  String get stepCountString {
    print("Current step count: ${steps.value}"); // In ra giá trị hiện tại
    return "${steps.value} bước / 5000";
  }

  @override
  void onClose() {
    super.onClose();
    stopListening();
  }
}
