import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class ProfileUserPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile User'),
      ),
      body: Obx(() {
        if (userController.userData.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          var user = userController.userData;
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: Text('Username'),
                subtitle: Text(user['username']),
              ),
              ListTile(
                title: Text('Password'),
                subtitle: Text(userController.maskString(user['password'])),
              ),
              ListTile(
                title: Text('Nama Pegawai'),
                subtitle: Text(user['nama_pegawai']),
              ),
              ListTile(
                title: Text('Role'),
                subtitle: Text(user['nama_role']),
              ),
              ListTile(
                title: Text('SKPD'),
                subtitle: Text(user['nama_skpd']),
              ),
              ListTile(
                title: Text('Daerah'),
                subtitle: Text(user['nama_daerah']),
              ),
              ListTile(
                title: Text('Token'),
                subtitle: Text(userController.maskString(user['token'])),
              ),
              ListTile(
                title: Text('Refresh Token'),
                subtitle:
                    Text(userController.maskString(user['refresh_token'])),
              ),
            ],
          );
        }
      }),
    );
  }
}
