import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../services/logger_service.dart';
import '../theme_provider.dart';

class ProfileUserPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  ProfileUserPage({super.key});

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
            title: const Text('Profile User'),
          ),
          body: Obx(() {
            if (userController.userData.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else {
              var user = userController.userData;
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Center(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/default_profile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _updateProfilePhotoAndReplaceDefault,
                    child: const Text('Perbarui Photo Profil'),
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: const Text('Username'),
                    subtitle: Text(user['username']),
                  ),
                  ListTile(
                    title: const Text('Password'),
                    subtitle: Text(userController.maskString(user['password'])),
                  ),
                  ListTile(
                    title: const Text('Nama Pegawai'),
                    subtitle: Text(user['nama_pegawai']),
                  ),
                  ListTile(
                    title: const Text('Role'),
                    subtitle: Text(user['nama_role']),
                  ),
                  ListTile(
                    title: const Text('SKPD'),
                    subtitle: Text(user['nama_skpd']),
                  ),
                  ListTile(
                    title: const Text('Daerah'),
                    subtitle: Text(user['nama_daerah']),
                  ),
                  SwitchListTile(
                    title: const Text('Tema'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(user['id_user']);
                      LoggerService.logger.i(
                          'Tema: ${themeProvider.isDarkMode ? 'Gelap' : 'Terang'}');
                    },
                  ),
                  ListTile(
                    title: const Text('Token OK - ⌛'),
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
