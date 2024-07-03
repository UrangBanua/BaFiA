import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'routes.dart';

void main() {
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
