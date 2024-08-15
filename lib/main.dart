import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'routes/routes.dart';
import 'services/logger_service.dart';
import 'services/local_storage_service.dart';
import 'controllers/theme_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LoggerService.logger.i('Handling a background message: ${message.messageId}');
  if (message.data.isNotEmpty) {
    LoggerService.logger.i('Message also contained data: ${message.data}');
    await LocalStorageService.saveMessageData(message.data);
    // Simpan status notifikasi
    final box = GetStorage();
    box.write('hasNotification', true);
    box.write('notificationData', message.data.toString());

    // Pengarahan ke halaman notifikasi
    navigatorKey.currentState?.pushNamed(
      '/notification',
      arguments: message,
    );
  }
}

Future<String> getInitialRoute() async {
  final box = GetStorage();
  //box.remove('isOverboard');
  // Membaca status overboard
  bool isOverboard = box.read('isOverboard') ?? true; // Default value is true
  LoggerService.logger.i('isOverboard: $isOverboard');

  // Membaca status notifikasi
  bool hasNotification = box.read('hasNotification') ?? false;

  if (AuthController().isLoggedIn.value) {
    if (hasNotification) {
      // Hapus status notifikasi setelah dibaca
      box.remove('hasNotification');
      return '/notification';
    } else if (isOverboard) {
      return '/overboard';
    } else {
      return '/login';
    }
  } else if (isOverboard) {
    return '/overboard';
  } else {
    return '/login';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  String initialRoute = await getInitialRoute();
  // panggil theme controller
  final themeController = Get.put(ThemeController());

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  try {
    await loadEnv();
  } catch (error) {
    LoggerService.logger.e(error);
  } finally {
    if (!kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
        name: 'BaFiA_PushNotif',
      );
    }
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    LoggerService.logger.i('Got a message whilst in the foreground!');
    LoggerService.logger.i('Full message: ${message.toMap()}');
    if (message.notification != null) {
      LoggerService.logger
          .i('Message also contained a notification: ${message.notification}');
    }
    if (message.data.isNotEmpty) {
      LoggerService.logger.i('Message also contained data: ${message.data}');
      try {
        await LocalStorageService.saveMessageData(message.data);
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

  try {
    var userData = await LocalStorageService.getUserData();
    LoggerService.logger.i('Database is ready');
    themeController.loadTheme(userData?['isDarkMode']);
    LoggerService.logger.i(
        'Initialize ThemeProvider and load DarkTheme: ${userData?['isDarkMode']}');
  } catch (error) {
    LoggerService.logger.w('App initialization: fresh user data');
  }

  runApp(BafiaApp(initialRoute: initialRoute));
}

class BafiaApp extends StatelessWidget {
  final String initialRoute;
  const BafiaApp({required this.initialRoute});

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
          return Obx(() {
            Get.put(ThemeController());
            final themeController = Get.find<ThemeController>();
            return GetMaterialApp(
              title: 'Bafia',
              initialBinding: BindingsBuilder(() {
                Get.put(AuthController());
              }),
              navigatorKey: navigatorKey,
              initialRoute: initialRoute,
              getPages: appRoutes(), // Set the routes here
              theme: ThemeData(
                primarySwatch: Colors.blue,
                brightness: themeController.isDarkMode.value
                    ? Brightness.dark
                    : Brightness.light,
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          });
        }
      },
    );
  }
}
