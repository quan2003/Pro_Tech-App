import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StepTrackingService extends GetxService {
  var steps = 0.obs; // Observable to hold the step count
  User? _user; // Firebase user
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    }
  });
}
Future<void> updateSteps(int newSteps) async {
  try {
    if (_user != null) {
      await FirebaseFirestore.instance
          .collection('activity_data')
          .doc(_user!.uid)
          .set({'steps': newSteps}, SetOptions(merge: true));
      steps.value = newSteps;
      print("Updated steps to $newSteps");
    } else {
      print("Cannot update steps: User is not logged in.");
    }
  } catch (e) {
    print("Error updating steps: $e");
  }
}
  // Initialize the service
  Future<void> initialize() async {
    print("Initializing StepTrackingService");
    await loadSteps(); // Load step count from Firestore
    print("StepTrackingService initialized with ${steps.value} steps");
  }
var isLoading = true.obs;
  // Load the steps from Firestore
  Future<void> loadSteps() async {
    try {
      if (_user != null) {
        final stepData = await FirebaseFirestore.instance
            .collection('activity_data')
            .doc(_user!.uid)
            .get();

        print("Step data exists: ${stepData.exists}");
        print("Step data: ${stepData.data()}");

        if (stepData.exists && stepData.data()?['steps'] != null) {
          steps.value = stepData.data()!['steps'];
          print("Loaded ${steps.value} steps from Firebase");
        } else {
          print("No valid step data found for this user.");
          // Có thể khởi tạo giá trị mặc định nếu cần
          // steps.value = 0;
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
    return "${steps.value} bước"; // Trả về số bước dưới dạng chuỗi
  }
}
