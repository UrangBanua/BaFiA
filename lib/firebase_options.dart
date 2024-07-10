// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCuDJxbX8CysqVFDAcUwxmngOhRUjgfeDI',
    appId: '1:648049824628:web:7cf65883273b6594109221',
    messagingSenderId: '648049824628',
    projectId: 'bpkad-official',
    authDomain: 'bpkad-official.firebaseapp.com',
    storageBucket: 'bpkad-official.appspot.com',
    measurementId: 'G-QR11HF4TBP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsVGKPuTzY_PDRipXCTb71bq8o7R-MaN8',
    appId: '1:648049824628:android:ebba87b532504ef1109221',
    messagingSenderId: '648049824628',
    projectId: 'bpkad-official',
    storageBucket: 'bpkad-official.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDs9H1N6OUxXDYvnkRqCPWinluIBQyU_wQ',
    appId: '1:648049824628:ios:cb48b1ea08159976109221',
    messagingSenderId: '648049824628',
    projectId: 'bpkad-official',
    storageBucket: 'bpkad-official.appspot.com',
    iosBundleId: 'com.bafia-ios.app',
  );
}