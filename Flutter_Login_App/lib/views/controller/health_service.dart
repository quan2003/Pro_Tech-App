import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class HealthService {
  final Health _health = Health();

  Future<void> initialize() async {
    await requestAuthorization(); // Chờ hoàn thành yêu cầu quyền
  }

  Future<void> openHealthConnectSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
        data: 'package:com.google.android.apps.healthdata',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } else {
      print("Health Connect chỉ có sẵn trên Android.");
    }
  }

  Future<bool> requestAuthorization() async {
    // Yêu cầu quyền truy cập activity recognition trước
    var activityRecognitionStatus = await Permission.activityRecognition.request();
    if (!activityRecognitionStatus.isGranted) {
      print("Quyền activityRecognition chưa được cấp.");
      return false; // Nếu quyền không được cấp, dừng yêu cầu
    }

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_TEMPERATURE,
    ];

    try {
      // Yêu cầu quyền truy cập Health Connect
      bool authorized = await _health.requestAuthorization(types);
      print("Health Connect authorization result: $authorized");
      return authorized;
    } catch (e) {
      print("Error requesting authorization: $e");
      return false;
    }
  }

  Future<List<HealthDataPoint>> fetchHealthData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.BODY_TEMPERATURE,
    ];

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );
      return _health.removeDuplicates(healthData);
    } catch (e) {
      print("Error fetching health data: $e");
      return [];
    }
  }

  Future<int?> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      return await _health.getTotalStepsInInterval(midnight, now);
    } catch (e) {
      print("Error getting today's steps: $e");
      return null;
    }
  }

  Future<bool> writeHealthData(HealthDataType type, double value) async {
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(seconds: 1)); // startTime phải trước endTime

    try {
      return await _health.writeHealthData(
        value: value,
        type: type,
        startTime: startTime,
        endTime: now,
      );
    } catch (e) {
      print("Lỗi khi ghi dữ liệu sức khỏe: $e");
      return false;
    }
  }
}
