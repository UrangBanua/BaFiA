import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class NotificationService {
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
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');
    if (token == null) {
      token = await _firebaseMessaging.getToken();
      if (token != null) {
        await prefs.setString('fcm_token', token);
        LoggerService.logger.i('FCM Token saved: $token');
      } else {
        LoggerService.logger.e('Failed to get FCM Token');
      }
    } else {
      LoggerService.logger.i('FCM Token: $token');
    }
  }
}
