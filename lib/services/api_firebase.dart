import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart'; // Pastikan Anda mengimpor LoggerService jika belum

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
      fCMToken = await _firebaseMessaging.getToken();
      await prefs.setString('fcm_token', fCMToken!);
    }

    LoggerService.logger.i('FCM Token: $fCMToken');
  }
}
