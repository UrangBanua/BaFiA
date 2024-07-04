import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'routes.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Delete db if it exists (untuk testing)
  //await LocalStorageService.deleteDatabase();
  // Variable to store user data
  Map<String, dynamic>? userData;

  try {
    userData = await LocalStorageService.getUserData();
    print('Database is ready');
  } catch (error) {
    print('Error during app initialization: $error');
  }

  runApp(BafiaApp(userData: userData));
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
          );
        }
      },
    );
  }
}
