import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bafia/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                await authController.login('email', 'password');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
