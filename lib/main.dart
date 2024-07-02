import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baFia/routes/app_router.gr.dart';
import 'package:baFia/controllers/auth_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Obx(() {
      return MaterialApp.router(
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        title: 'BaFia',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        builder: (context, router) {
          return authController.isLoggedIn.value ? router! : LoginPage();
        },
      );
    });
  }
}
