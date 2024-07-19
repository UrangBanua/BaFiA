import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../main.dart';
import 'logger_service.dart';

class ApiFirebase {
  // create an instance of Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize notifications
  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kIsWeb) {
      // Web-specific initialization
      await _firebaseMessaging.requestPermission();
    } else {
      // Mobile-specific initialization
      await _firebaseMessaging.requestPermission();
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LoggerService.logger.i('User granted permission');
    } else {
      LoggerService.logger.i('User declined or has not accepted permission');
    }

    // Get the token
    final fCMToken = kIsWeb ? 'web_token' : await _firebaseMessaging.getToken();
    LoggerService.logger.i('FCM Token: $fCMToken');
  }

  // function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // if the message is null, do nothing
    if (message == null) return;

    // navigate to new screen when message is received and user taps notification
    navigatorKey.currentState?.pushNamed(
      '/notification',
      arguments: message,
    );
  }

  // function to initialize background settings
  Future<void> initPushNotifications() async {
    if (!kIsWeb) {
      // handle notification if the app was terminated and now opened
      FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    }
  }
}
