import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'routes/routes.dart';
import 'services/api_firebase.dart';
import 'theme_provider.dart';
import 'services/logger_service.dart';
import 'services/local_storage_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await loadEnv();
  } catch (error) {
    LoggerService.logger.e(error);
  } finally {
    // Initialize Firebase App Messaging
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: 'BaFiA_PushNotif',
      // Add the following line to fix the error on web
      // This is required for Firebase Messaging on web
      // Remove this line if you're not targeting web
      // messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    );

    if (!kIsWeb) {
      await ApiFirebase().initNotifications();
      //NotificationService().initialize();
    }
  }

  // Initialize ThemeProvider and load theme
  final themeProvider = ThemeProvider();

  // Clear database structure untuk pembaruan atau update struktur database
  //await LocalStorageService.deleteDatabase();

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LoggerService.logger.i('Got a message whilst in the foreground!');
    LoggerService.logger
        .i('Full message: ${message.toMap()}'); // Log the full message
    LoggerService.logger.i('Message data: ${message.data}');

    if (message.notification != null) {
      LoggerService.logger
          .i('Message also contained a notification: ${message.notification}');
    }
  });

  // Initialize database and get user data
  Map<String, dynamic>? userData;
  try {
    userData = await LocalStorageService.getUserData();
    LoggerService.logger.i('Database is ready');

    themeProvider.loadTheme(userData?['isDarkMode']);
    LoggerService.logger.i(
        'Initialize ThemeProvider and load DarkTheme: ${userData!['isDarkMode']}');
  } catch (error) {
    LoggerService.logger.w('App initialization: fresh user data');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: BafiaApp(userData: userData),
    ),
  );
}

class BafiaApp extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const BafiaApp({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalStorageService.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child:
                    Text('Error initializing the database: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return GetMaterialApp(
            title: 'Bafia',
            initialBinding: BindingsBuilder(() {
              Get.put(
                  AuthController()); // Sediakan AuthController saat app diluncurkan
            }),
            initialRoute: userData == null ? '/login' : '/dashboard',
            navigatorKey: navigatorKey,
            getPages: appRoutes(),
            theme: context.watch<ThemeProvider>().currentTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
            ],
            locale: const Locale('id', 'ID'),
          );
        }
      },
    );
  }
}
