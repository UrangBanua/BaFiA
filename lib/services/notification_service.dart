import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logger_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin as FlutterLocalNotificationsPlugin;

  Future<void> initialize() async {
    // Inisialisasi Local Notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    //final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      //iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Menerima notifikasi ketika aplikasi berjalan di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LoggerService.logger
          .i('Menerima notifikasi ketika aplikasi berjalan di foreground');
      _showNotification(message);
    });

    // Menerima notifikasi ketika aplikasi berjalan di background dan dibuka
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LoggerService.logger.i(
          'Menerima notifikasi ketika aplikasi berjalan di background dan dibuka');
      // Handle the notification when the app is opened
    });

    // Mendapatkan token FCM
    String? token = await _firebaseMessaging.getToken();
    LoggerService.logger.i('FCM Token: $token');
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
    LoggerService.logger.i('Menampilkan notifikasi');
  }
}
