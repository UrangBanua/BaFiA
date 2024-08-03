import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/logger_service.dart';

class ProfileUserPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      );
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Profile User'),
      actions: [
        IconButton(
          icon: Icon(
            themeController.isDarkMode.value
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            themeController.toggleTheme(userController.userData['id_user']);
            LoggerService.logger.i(
                'Tema: ${themeController.isDarkMode.value ? 'Gelap' : 'Terang'}');
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (userController.userData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      var user = userController.userData;
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16.0),
          _buildUserInfo(user),
        ],
      );
    }
  }

  Widget _buildProfileImage() {
    return Center(
      child: Obx(() {
        var profileImage = userController.userData['profile_photo'];
        return GestureDetector(
          onTap: () => _showProfileImageDialog(profileImage),
          child: Stack(
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: profileImage != '-'
                        ? MemoryImage(base64Decode(profileImage!))
                        : const AssetImage('assets/images/default_profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon:
                        const Icon(Icons.edit, size: 16.0, color: Colors.white),
                    onPressed: userController.pickProfilePhoto,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showProfileImageDialog(String? profileImage) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.infinity,
          height: 300.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: profileImage != '-'
                  ? MemoryImage(base64Decode(profileImage!))
                  : const AssetImage('assets/images/default_profile.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(RxMap<dynamic, dynamic> user) {
    return Column(
      children: [
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
        ListTile(
          title: const Text('Token OK - ⌛'),
          subtitle: Text(userController.maskString(user['refresh_token'])),
        ),
      ],
    );
  }
}
