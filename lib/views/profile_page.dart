import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baFia/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Obx(() {
        if (profileController.user.value == null) {
          return Center(child: CircularProgressIndicator());
        } else {
          final user = profileController.user.value!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Phone: ${user.phone}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: profileController.logout,
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
