import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';

class ApiFirebase {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static final bool isDevelopmentMode = dotenv.env['DEVELOPMENT_MODE'] == 'ON';

  static final GetStorage _storage = GetStorage();
  static final GetStorage _storageFcmToken = GetStorage('fcm_token');

  // Fungsi untuk subscribe topic
  Future<void> subscribeTopic(String topic) async {
    // Cek apakah topic sudah disubscribe
    if (_storage.read(topic) != null) return;

    // Simpan topik ke GetStorage
    await _storage.write(topic, true);

    // Subscribe ke topik menggunakan FirebaseMessaging
    await _firebaseMessaging.subscribeToTopic(topic);
    LoggerService.logger.i('Subscribed topic: $topic');
  }

  // Fungsi untuk unsubscribe semua topic
  Future<void> unsubscribeAllTopics() async {
    final keys = // get keys include 'bafia-info' from GetStorage
        _storage
            .getKeys()
            .where((String key) => key.contains('bafia-info'))
            .toList();
    for (String topic in keys) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      LoggerService.logger.i('Unsubscribed topic: $topic');
      // Hapus data topic dari GetStorage
      await _storage.remove(topic);
    }
  }

  Future<void> initNotifications() async {
    if (kIsWeb) {
      LoggerService.logger.i('FCM is disabled on web platform.');
      return;
    }

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LoggerService.logger.i('User granted permission for notifications');
    } else {
      LoggerService.logger
          .i('User declined or has not accepted permission for notifications');
    }

    // init GetStorage for FCM token
    String? fCMToken = _storageFcmToken.read('fcm_token');
    if (fCMToken == null) {
      fCMToken = kIsWeb ? 'web_token' : await _firebaseMessaging.getToken();
      if (fCMToken != null) {
        await _storageFcmToken.write('fcm_token', fCMToken);
      }
    }

    LoggerService.logger.i('FCM Token: $fCMToken');

    // Set Channel ID for Android
    if (!kIsWeb) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await _firebaseMessaging.setAutoInitEnabled(true);
    }

    // Subscribe to the 'bafia-info' topic
    isDevelopmentMode
        ? await subscribeTopic('bafia-info-dev')
        : await subscribeTopic('bafia-info');
  }

  /* Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    final link = message.data['link'];
    if (link != null) {
      LoggerService.logger.i('OPEN_URL link is available');
      _launchURL(link);
    }

    if (message.data.isNotEmpty) {
      LoggerService.logger.i('Message also contained data: ${message.data}');
      await LocalStorageService.saveMessageData(message.data);
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
    }
  } */
}
