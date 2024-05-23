import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/routes.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    print('Title : ${message.notification!.title}');
  }
  if (kDebugMode) {
    print('Body : ${message.notification!.body}');
  }
  if (kDebugMode) {
    print('Payload : ${message.data}');
  }
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // channel ID
    'High Importance Notifications', // channel name
    description: 'Incoming channel is used for important notifications',
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState
        ?.pushNamed(Routes.kNotificationScreen, arguments: message);
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(settings,

        /// This method triggers when the users click on the local notification when the app is in foreground state

        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    /// When the app is open from a terminated state after clicking on the notification
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    /// When the app is open from a background state after clicking on the notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    /// while a message come during the app is in the background and terminated state

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    /// while a message come during the app is in the foreground state

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;

      if (notification == null) return;

      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChannel.id, _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: '@drawable/ic_launcher'),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Token: $fCMToken');
    }

    initPushNotification();
    initLocalNotifications();
  }
}
