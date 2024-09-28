import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_app/views/Routes/AppRoutes.dart';
import 'package:flutter_login_app/views/controller/StepTrackingService.dart';
import 'package:get/get.dart';
// import 'package:flutter_login_app/views/controller/StepTrackingService.dart';

// Hàm xử lý thông báo khi ứng dụng ở nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Đảm bảo Firebase đã được khởi tạo trước khi xử lý tin nhắn
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get.put(Ste0pTrackingService());

  // Khởi tạo Firebase cho các nền tảng khác nhau
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg", // Được cung cấp từ hình ảnh
        authDomain:
            "signin-example-b56ee.firebaseapp.com", // Dựa vào project ID
        projectId: "signin-example-b56ee", // Được cung cấp từ hình ảnh
        storageBucket:
            "signin-example-b56ee.appspot.com", // Dựa vào cấu trúc tên project
        messagingSenderId: "989890578847", // Được cung cấp từ hình ảnh
        appId:
            "1:989890578847:android:039450145d92cefd9d95aa", // Được cung cấp từ hình ảnh
      ),
    );
  }

  // Thiết lập phương thức để xử lý thông báo khi ứng dụng ở nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Đặt hướng cho thiết bị
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Chạy ứng dụng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pro-Tech',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.SIGNINSCREEN,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.purple, // Tùy chỉnh màu sắc chủ đạo
      ),
    );
  }
}
