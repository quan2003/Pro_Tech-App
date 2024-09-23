import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controller/StepTrackingService.dart';

class StepTrackingScreen extends StatefulWidget {
  // final StepTrackingService _stepService = Get.find<StepTrackingService>();

  @override
  _StepTrackingScreenState createState() => _StepTrackingScreenState();
}

class _StepTrackingScreenState extends State<StepTrackingScreen> {
  
  String _userEmail = '';
  int _steps = 0;
  int _stepGoal = 5000;
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

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userEmail = _user?.email ?? '';
    _initSharedPreferences();
    _checkAndRequestPermission();
    _loadDataFromFirebase();
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
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['date'] == todayKey) {
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
      if (_initialSteps == null) {
        _initialSteps = event.steps;
      }
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
          title: Text("Physical Activity Permission Required"),
          content: Text("Please grant physical activity permission to track your activities."),
          actions: [
            TextButton(
              child: Text("OK"),
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

    CollectionReference dataCollection = FirebaseFirestore.instance.collection('activity_data');

    await dataCollection.doc(_user!.uid).set({
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
    double _percent = _steps / _stepGoal;

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
        appBar: AppBar(
          title: Text('Activity Tracker'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 150.0,
                lineWidth: 13.0,
                animation: true,
                percent: _percent > 1 ? 1 : _percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_walk, size: 40),
                    Text(
                      "$_steps",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Logic to edit step goal
                      },
                      child: Text(
                        "Edit Goal",
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 15.0,
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
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("steps", _steps.toString(), Icons.directions_walk),
                  _buildStatItem("kcal", _calories.toStringAsFixed(1), Icons.local_fire_department),
                  _buildStatItem("km", _distance.toStringAsFixed(2), Icons.directions),
                  _buildStatItem("minutes", _minutes.toString(), Icons.timer),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _toggleTracking,
                child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.pinkAccent),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
  
}