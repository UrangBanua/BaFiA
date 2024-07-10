import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'routes.dart';
import 'theme_provider.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeProvider and load theme
  ThemeProvider themeProvider = ThemeProvider();

  // Delete db if it exists (untuk testing)
  //await LocalStorageService.deleteDatabase();

  // Initialize database and get user data
  Map<String, dynamic>? userData;
  try {
    userData = await LocalStorageService.getUserData();
    print('Database is ready');

    themeProvider.loadTheme(userData?['isDarkMode']);
    print('Initialize ThemeProvider and load DarkTheme: ' +
        userData!['isDarkMode'].toString());
  } catch (error) {
    print('Error during app initialization: $error');
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

  BafiaApp({this.userData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalStorageService.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
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
            getPages: appRoutes(),
            theme: context.watch<ThemeProvider>().currentTheme,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('id', 'ID'),
            ],
            locale: const Locale('id', 'ID'),
          );
        }
      },
    );
  }
}