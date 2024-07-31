import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../services/logger_service.dart';
import '../theme_provider.dart';

class ProfileUserPage extends StatelessWidget {
  //const ProfileUserPage({super.key});

  UserController get userController => Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile User'),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme(userController.userData['id_user']);
                  LoggerService.logger.i(
                      'Tema: ${themeProvider.isDarkMode ? 'Gelap' : 'Terang'}');
                },
              ),
            ],
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
                    child: FutureBuilder<ImageProvider>(
                      future: userController.getProfileImage(
                          userController.userData['profile_photo']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/default_profile.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: userController.pickProfilePhoto,
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
                    subtitle: Text(
                      user['nama_daerah'] != '-'
                          ? user['nama_daerah']
                          : 'Kabupaten Hulu Sungai Tengah',
                    ),
                  ),
                  // fitur Biometric Authentication
                  /* SwitchListTile(
                    title: const Text('Enable Biometric Authentication'),
                    value: userController.isBiometricEnabled.value,
                    onChanged: (bool value) {
                      userController.setBiometricEnabled(value);
                    },
                  ), */
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
