import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/logger_service.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

Future<void> loadEnv() async {
  await dotenv.load();
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      LoggerService.logger
          .d('Current platform is Web key: ${dotenv.env['API_KEY_WEB']}');
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        LoggerService.logger.d(
            'Current platform is Android key: ${dotenv.env['API_KEY_ANDROID']}');
        return android;
      case TargetPlatform.iOS:
        LoggerService.logger.d('Current platform is iOS');
        return ios;
      case TargetPlatform.macOS:
        LoggerService.logger.d('Current platform is macOS');
        return macos;
      case TargetPlatform.windows:
        LoggerService.logger.d(
            'Current platform is Windows key: ${dotenv.env['API_KEY_WINDOWS']}');
        return windows;
      case TargetPlatform.linux:
        LoggerService.logger.e(
            'DefaultFirebaseOptions have not been configured for Linux - '
            'you can reconfigure this by running the FlutterFire CLI again.');
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        LoggerService.logger
            .e('DefaultFirebaseOptions are not supported for this platform.');
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Returns the FirebaseOptions based on the current platform.
  static FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_WEB'] ?? '',
    appId: '1:487583025296:web:193c17e25d70948539b015',
    messagingSenderId: '487583025296',
    projectId: 'bafia-428505',
    authDomain: 'bafia-428505.firebaseapp.com',
    storageBucket: 'bafia-428505.appspot.com',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_ANDROID'] ?? '',
    appId: '1:487583025296:android:dca831457fca37a739b015',
    messagingSenderId: '487583025296',
    projectId: 'bafia-428505',
    storageBucket: 'bafia-428505.appspot.com',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_IOS'] ?? '',
    appId: '1:487583025296:ios:a90ea3406a46521539b015',
    messagingSenderId: '487583025296',
    projectId: 'bafia-428505',
    storageBucket: 'bafia-428505.appspot.com',
    iosBundleId: 'com.urangbanua.bafia',
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_MACOS'] ?? '',
    appId: '1:648049824628:ios:83f322b3a86b4ce6109221',
    messagingSenderId: '648049824628',
    projectId: 'bpkad-official',
    storageBucket: 'bpkad-official.appspot.com',
    iosBundleId: 'com.urangbanua.bafia',
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: dotenv.env['API_KEY_WINDOWS'] ?? '',
    appId: '1:487583025296:web:059b43badbf5598639b015',
    messagingSenderId: '487583025296',
    projectId: 'bafia-428505',
    authDomain: 'bafia-428505.firebaseapp.com',
    storageBucket: 'bafia-428505.appspot.com',
  );
}
