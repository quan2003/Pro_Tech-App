import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_login_app/views/Routes/AppRoutes.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

// Conditional import for Workmanager
import './views/utils/workmanager_helper.dart'
    if (dart.library.js) './views/utils/workmanager_web_stub.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  await _ensureFirebaseInitialized();
}

Future<void> _ensureFirebaseInitialized() async {
  if (!Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options:
          kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.android,
    );
  }
}

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await _ensureFirebaseInitialized();
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      print('Background message handler set up successfully');

      if (!kIsWeb) {
        await initializeWorkmanager();
        await registerPeriodicTasks();
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      runApp(const MyApp());
    } catch (error) {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Có lỗi xảy ra khi khởi động ứng dụng: $error'),
          ),
        ),
      ));
    }
  }, (error, stackTrace) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building MyApp widget');
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

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg',
    appId: '1:989890578847:android:8c0ab0b820dbdbfa9d95aa',
    messagingSenderId: '989890578847',
    projectId: 'signin-example-b56ee',
    storageBucket: 'signin-example-b56ee.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDm-LnWxMTncU4nvMhdGFyT0Qh2SSjwgIg',
    appId:
        '1:989890578847:web:903a936a3b2278ed9d95aa', // Giữ nguyên giá trị web app ID nếu bạn đã có
    messagingSenderId: '989890578847',
    projectId: 'signin-example-b56ee',
    storageBucket: 'signin-example-b56ee.appspot.com',
    authDomain:
        'signin-example-b56ee.firebaseapp.com', // Thêm authDomain nếu cần thiết cho web
    measurementId:
        'G-6C63FNQH88', // Giữ nguyên nếu bạn đã có Measurement ID cho web
  );
}
