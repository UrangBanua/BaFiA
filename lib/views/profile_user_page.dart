import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/user_controller.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                          image: NetworkImage(
                              'https://static.vecteezy.com/system/resources/thumbnails/019/879/198/small_2x/user-icon-on-transparent-background-free-png.png'), // Ganti dengan path gambar default
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
                  SwitchListTile(
                    title: Text('Tema'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                      print(
                          'Tema: ${themeProvider.isDarkMode ? 'Gelap' : 'Terang'}');
                    },
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
      },
    );
  }
}
