import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin as FlutterLocalNotificationsPlugin;
  final Logger _logger = Logger('NotificationService');

  NotificationService() {
    _logger.onRecord.listen(
      (record) =>
          print('${record.level.name}: ${record.time}: ${record.message}'),
    );
  }

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
      _logger
          .fine('Menerima notifikasi ketika aplikasi berjalan di foreground');
      _showNotification(message);
    });

    // Menerima notifikasi ketika aplikasi berjalan di background dan dibuka
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.fine(
          'Menerima notifikasi ketika aplikasi berjalan di background dan dibuka');
      // Handle the notification when the app is opened
    });

    // Mendapatkan token FCM
    String? token = await _firebaseMessaging.getToken();
    _logger.fine('FCM Token: $token');
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
    _logger.fine('Menampilkan notifikasi');
  }
}
