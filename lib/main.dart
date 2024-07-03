import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'routes.dart';
import 'services/local_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    LocalStorageService.database.then((database) {
      print('Database is ready');
        });
  } catch (error) {
    print('Error during app initialization: $error');
  }

  runApp(BafiaApp());
}

class BafiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bafia',
      initialBinding: BindingsBuilder(() {
        Get.put(
            AuthController()); // Sediakan AuthController saat app diluncurkan
      }),
      initialRoute: '/login',
      getPages: appRoutes(),
    );
  }
}
