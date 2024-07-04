import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/user_controller.dart';

class ProfileUserPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  Future<void> _updateProfilePhotoAndReplaceDefault() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      userController.updateProfilePhotoAndReplaceDefault(pickedFile.path);
    }
  }

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
              Center(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/default_profile_image.jpg'), // Ganti dengan path gambar default
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _updateProfilePhotoAndReplaceDefault,
                child: Text('Perbarui Photo Profil'),
              ),
              SizedBox(height: 16.0),
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
                title: Text('Token OK - Belum Expired ⌛'),
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
