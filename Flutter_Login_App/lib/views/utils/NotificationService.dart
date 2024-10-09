import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initNotification() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings initializationSettingsIOS =
          const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          print('Notification tapped: ${response.payload}');
        },
      );

      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      } else if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Request notification permission on Android 13+
          final bool? granted =
              await androidImplementation.requestNotificationsPermission();
          print('Android notification permission granted: $granted');
        } else {
          print('Unable to resolve Android implementation');
        }
      }
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Handling a foreground message: ${message.messageId}");
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Handling a message that opened the app: ${message.messageId}");
      _handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> showNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Reminders for taking medication',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notification scheduled for $scheduledDate');
      await _saveNotification(id, title, body, scheduledDate);
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> _saveNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(jsonEncode({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
    }));
    await prefs.setStringList('notifications', notifications);
  }

  Future<void> rescheduleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    for (final notificationJson in notifications) {
      final notification = jsonDecode(notificationJson);
      await showNotification(
        notification['id'],
        notification['title'],
        notification['body'],
        DateTime.parse(notification['scheduledDate']),
      );
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      showNotification(
        message.hashCode,
        message.notification!.title ?? '',
        message.notification!.body ?? '',
        DateTime.now(),
      );
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // Handle background notification processing
}
