import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_login_app/views/Routes/AppRoutes.dart';

import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Khởi tạo FlutterLocalNotificationsPlugin
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    switch (task) {
      case 'runningReminder':
        await _showRunningReminder(flutterLocalNotificationsPlugin);
        break;
      case 'stepCountReminder':
        await _showStepCountReminder(flutterLocalNotificationsPlugin);
        break;
      default:
        print('Unknown task: $task');
    }
    return Future.value(true);
  });
}

Future<void> _showRunningReminder(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.show(
    0,
    'Nhắc nhở chạy bộ',
    'Đã đến giờ chạy bộ buổi sáng rồi!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'running_reminder_channel',
        'Running Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

Future<void> _showStepCountReminder(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.show(
    1,
    'Thống kê bước chạy',
    'Hãy kiểm tra số bước chạy của bạn hôm nay!',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'step_count_channel',
        'Step Count Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

// Hàm xử lý thông báo khi ứng dụng ở nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true
  );
  
  // Đăng ký tác vụ nhắc nhở chạy bộ hàng ngày lúc 7:00
  await Workmanager().registerPeriodicTask(
    "running-reminder",
    "runningReminder",
    frequency: const Duration(days: 1),
    initialDelay: const Duration(minutes: 1),  // Đặt thời gian delay ngắn hơn để kiểm tra
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );

  // Đăng ký tác vụ thống kê bước chạy hàng ngày lúc 20:00
  await Workmanager().registerPeriodicTask(
    "step-count-reminder",
    "stepCountReminder",
    frequency: const Duration(days: 1),
    initialDelay: const Duration(minutes: 2),  // Đặt thời gian delay ngắn hơn để kiểm tra
    constraints: Constraints(
      networkType: NetworkType.not_required,
    ),
  );
  
  // Khởi tạo Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg",
        authDomain: "signin-example-b56ee.firebaseapp.com",
        projectId: "signin-example-b56ee",
        storageBucket: "signin-example-b56ee.appspot.com",
        messagingSenderId: "989890578847",
        appId: "1:989890578847:android:039450145d92cefd9d95aa",
      ),
    );
  }

  // Thiết lập xử lý thông báo nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Cài đặt hướng thiết bị
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);



  runApp(const MyApp());
}
  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    return GetMaterialApp(
      title: 'Pro-Tech',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.SPLASH_SCREEN,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}
