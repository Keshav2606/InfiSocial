import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  void initializeNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.data;
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'InfiSocial',
      channelDescription: 'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecond,
      notification["title"],
      notification["body"],
      platformDetails,
      payload: message.data['channel_id'],
    );
  }
}
