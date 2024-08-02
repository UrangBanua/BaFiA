import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
//import 'controllers/notification_controller.dart';
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
//final NotificationController notificationController =
//    Get.put(NotificationController());

// Register the background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LoggerService.logger.i('Handling a background message: ${message.messageId}');
  if (message.data.isNotEmpty) {
    LoggerService.logger.i('Message also contained data: ${message.data}');
    await LocalStorageService.saveMessageData(message.data);
    //await notificationController.addNotification(message.data);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  try {
    // Load environment variables
    await loadEnv();
    // hapus database
    //await LocalStorageService.deleteDatabase();
  } catch (error) {
    LoggerService.logger.e(error);
  } finally {
    if (!kIsWeb) {
      // Initialize Firebase App Messaging
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
        name: 'BaFiA_PushNotif',
      );
      await ApiFirebase().initNotifications();
    }
  }
  // Get put AuthController
  //final AuthController authController = Get.put(AuthController());
  // cek user autentikasi
  //bool isAuthenticated = await authController.authenticate();

  // Initialize ThemeProvider and load theme
  final themeProvider = ThemeProvider();

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    LoggerService.logger.i('Got a message whilst in the foreground!');
    LoggerService.logger
        .i('Full message: ${message.toMap()}'); // Log the full message
    if (message.notification != null) {
      LoggerService.logger
          .i('Message also contained a notification: ${message.notification}');
    }
    if (message.data.isNotEmpty) {
      LoggerService.logger.i('Message also contained data: ${message.data}');
      try {
        await LocalStorageService.saveMessageData(message.data);
        //await notificationController.addNotification(message.data);
      } catch (error) {
        LoggerService.logger.e('Error saving message data: $error');
      } finally {
        Get.snackbar(
          message.notification?.title ?? 'BaFiA',
          message.notification?.body ?? 'Ada pesan baru',
          onTap: (_) {
            Get.toNamed('/notification');
          },
        );
      }
    }
  });

  // Initialize database and get user data
  Map<String, dynamic>? userData;
  try {
    userData = await LocalStorageService.getUserData();
    LoggerService.logger.i('Database is ready');
    themeProvider.loadTheme(userData?['isDarkMode']);
    LoggerService.logger.i(
        'Initialize ThemeProvider and load DarkTheme: ${userData?['isDarkMode']}');
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
  //final bool isAuthenticated;

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
          );
        }
      },
    );
  }
}
