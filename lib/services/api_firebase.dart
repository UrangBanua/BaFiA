import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'logger_service.dart';

class ApiFirebase {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LoggerService.logger.i('User granted permission');
    } else {
      LoggerService.logger.i('User declined or has not accepted permission');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fCMToken = prefs.getString('fcm_token');

    if (fCMToken == null) {
      fCMToken = kIsWeb ? 'web_token' : await _firebaseMessaging.getToken();
      if (fCMToken != null) {
        await prefs.setString('fcm_token', fCMToken);
      }
    }

    LoggerService.logger.i('FCM Token: $fCMToken');

    // Subscribe to the 'bafia-info' topic
    await _firebaseMessaging.subscribeToTopic('bafia-info');
    LoggerService.logger.i('Subscribed to topic: bafia-info');
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    final link = message.data['link'];
    if (link != null) {
      LoggerService.logger.i('OPEN_URL link is available');
      _launchURL(link);
    }

    navigatorKey.currentState?.pushNamed(
      '/notification',
      arguments: message,
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      LoggerService.logger.i('Launching link url: $url');
      await launch(url);
    } else {
      LoggerService.logger.i('Could not launch link url: $url');
      throw 'Could not launch $url';
    }
  }

  Future<void> initPushNotifications() async {
    if (!kIsWeb) {
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          LoggerService.logger.i(
              'getInitialMessage: ${message.toMap()}'); // Log the full message
          handleMessage(message);
        }
      });
    } else {
      FirebaseMessaging.onBackgroundMessage((message) async {
        LoggerService.logger
            .i('Full message: ${message.toMap()}'); // Log the full message
        handleMessage(message);
      });
    }
  }
}
