import 'package:flutter/material.dart';
import 'package:flutter_login_app/views/screens/WeekScreen.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
// import '../controller/StepTrackingService.dart';

class StepTrackingScreen extends StatefulWidget {
  const StepTrackingScreen({super.key});

  @override
  _StepTrackingScreenState createState() => _StepTrackingScreenState();
}

class _StepTrackingScreenState extends State<StepTrackingScreen>
    with SingleTickerProviderStateMixin {
  String _userEmail = '';
  int _steps = 0;
  final int _stepGoal = 5000;
  double _calories = 0;
  double _distance = 0;
  int _minutes = 0;
  late SharedPreferences _prefs;
  late Stream<StepCount> _stepCountStream;
  User? _user;
  DateTime? _startTime;
  bool _isTracking = false;
  int? _initialSteps;
  int _lastSavedSteps = 0;

  late TabController _tabController;
  final List<String> _tabs = ['Ngày', 'Tuần', 'Tháng', 'Năm'];
  DateTime _currentDate = DateTime.now();
  String _currentPeriod = "Hôm nay";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? '';
    _initSharedPreferences();
    _checkAndRequestPermission();
    _loadDataForDate(_currentDate);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentPeriod =
              'Hôm nay'; // Nội dung cho tab 'Ngày' _currentPeriod = _formatDate(_currentDate);
          _loadDataForDate(_currentDate);
          break;
        case 1:
          _currentPeriod = 'Tổng số bước trong tuần'; // Nội dung cho tab 'Tuần'
          break;
        case 2:
          _currentPeriod =
              'Tổng số bước trong tháng'; // Nội dung cho tab 'Tháng'
          break;
        case 3:
          _currentPeriod = 'Tổng số bước trong năm'; // Nội dung cho tab 'Năm'
          break;
        default:
          _currentPeriod = 'Hôm nay';
      }
    });
  }

  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return 'Hôm nay';
    } else if (date.isAtSameMomentAs(yesterday)) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateDay(bool forward) {
    setState(() {
      _currentDate = forward
          ? _currentDate.add(const Duration(days: 1))
          : _currentDate.subtract(const Duration(days: 1));
      _currentPeriod = _formatDate(_currentDate);
      _loadDataForDate(_currentDate);
    });
  }

  Future<void> _loadDataForDate(DateTime date) async {
    if (_user == null) return;

    String dateKey = "${date.year}-${date.month}-${date.day}";

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('activity_data')
        .doc(_user!.uid)
        .collection('daily_data')
        .doc(dateKey)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _steps = data['steps'] ?? 0;
        _calories = data['calories'] ?? 0.0;
        _distance = data['distance'] ?? 0.0;
        _minutes = data['minutes'] ?? 0;
      });
    } else {
      _resetData();
    }
  }
  // void _loadDataForPeriod(String period) {
  //   // Implement logic to load data for the selected period
  //   // This is where you would query Firestore for the appropriate data
  //   // For now, we'll just use dummy data
  //   setState(() {
  //     _steps = 1000 * (_tabController.index + 1); // Dummy data
  //     _updateData();
  //   });
  // }

  @override
  void dispose() {
    _tabController.dispose(); // Đảm bảo giải phóng bộ nhớ khi không cần thiết
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadDataFromFirebase() async {
    if (_user == null) return;

    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('activity_data')
        .doc(_user!.uid)
        .collection('daily_data')
        .doc(todayKey)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _steps = data['steps'] ?? 0;
        _lastSavedSteps = _steps;
        _calories = data['calories'] ?? 0.0;
        _distance = data['distance'] ?? 0.0;
        _minutes = data['minutes'] ?? 0;
        _isTracking = data['isTracking'] ?? false;
        _startTime = data['startTime'] != null
            ? DateTime.parse(data['startTime'])
            : null;
      });
    } else {
      _resetData();
    }
  }

  void _resetData() {
    setState(() {
      _steps = 0;
      _lastSavedSteps = 0;
      _calories = 0;
      _distance = 0;
      _minutes = 0;
      _initialSteps = null;
      _isTracking = false;
      _startTime = null;
    });
  }

  void _onStepCount(StepCount event) {
    if (!_isTracking) return;

    setState(() {
      _initialSteps ??= event.steps;
      int newSteps = event.steps - _initialSteps!;
      _steps = _lastSavedSteps + newSteps;
      _updateData();
    });

    _saveDataToFirebase({
      'steps': _steps,
      'calories': _calories,
      'distance': _distance,
      'minutes': _minutes,
      'isTracking': _isTracking,
      'startTime': _startTime?.toIso8601String(),
    });
  }

  Future<void> _checkAndRequestPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;

    if (status.isGranted) {
      _startListening();
    } else {
      status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        _startListening();
      } else if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Physical Activity Permission Required"),
          content: const Text(
              "Please grant physical activity permission to track your activities."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _updateData() {
    _calories = _steps * 0.04;
    _distance = _steps * 0.000762;

    if (_startTime != null) {
      _minutes = DateTime.now().difference(_startTime!).inMinutes;
    }
  }

  void _onStepCountError(error) {
    print("Step Count Error: $error");
  }

  Future<void> _saveDataToFirebase(Map<String, dynamic> data) async {
    if (_user == null) return;

    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";

    CollectionReference userDataCollection = FirebaseFirestore.instance
        .collection('activity_data')
        .doc(_user!.uid)
        .collection('daily_data');

    await userDataCollection.doc(todayKey).set({
      'date': todayKey,
      'email': _userEmail,
      ...data,
    }, SetOptions(merge: true));

    _lastSavedSteps = _steps;
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _startTime = _startTime ?? DateTime.now();
        _initialSteps = null;
      }
    });

    _saveDataToFirebase({
      'isTracking': _isTracking,
      'startTime': _startTime?.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    double percent = _steps / _stepGoal;

    return WillPopScope(
      onWillPop: () async {
        await _saveDataToFirebase({
          'steps': _steps,
          'calories': _calories,
          'distance': _distance,
          'minutes': _minutes,
          'isTracking': _isTracking,
          'startTime': _startTime?.toIso8601String(),
        });
        Navigator.pop(context, _steps);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Bước chân', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () async {
              await _saveDataToFirebase({
                'steps': _steps,
                'calories': _calories,
                'distance': _distance,
                'minutes': _minutes,
                'isTracking': _isTracking,
                'startTime': _startTime?.toIso8601String(),
              });
              Navigator.pop(context, _steps);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs.map((String name) => Tab(text: name)).toList(),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.pinkAccent,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(), // Ngày
            WeekScreen(
                // stepsPerDay: _stepsPerDay,
                // tabController: _tabController,
                ), // Tuần
            _buildTabContent(), // Tháng
            _buildTabContent(), // Năm
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    double percent = _steps / _stepGoal;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    _navigateDay(false); // Navigate back
                  },
                ),
                Expanded(
                  // Wrap Text inside Expanded
                  child: Text(
                    _currentPeriod,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // Center text
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onPressed: _currentDate.isBefore(DateTime.now())
                      ? () {
                          _navigateDay(true); // Navigate forward
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 150.0,
            lineWidth: 15.0,
            animation: true,
            percent: percent > 1 ? 1 : percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_walk, size: 50, color: Colors.pink),
                Text(
                  "$_steps",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0),
                ),
                GestureDetector(
                  onTap: () {
                    // Logic to edit step goal
                  },
                  child: const Text(
                    "Sửa mục tiêu",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
            backgroundColor: Colors.grey[300]!,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("bước", _steps.toString(), Icons.directions_walk),
              _buildStatItem("kcal", _calories.toStringAsFixed(1),
                  Icons.local_fire_department),
              _buildStatItem(
                  "m", _distance.toStringAsFixed(2), Icons.directions),
              _buildStatItem("phút", _minutes.toString(), Icons.timer),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _toggleTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isTracking ? Colors.red : Colors.green,
            ),
            child: Text(_isTracking ? 'Dừng theo dõi' : 'Bắt đầu theo dõi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.pinkAccent),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
