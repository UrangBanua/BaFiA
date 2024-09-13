import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/logger_service.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileUserPageState createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.put(UserController());
  final ThemeController themeController = Get.put(ThemeController());
  bool isUserTokenMasked = true;
  bool isFcmTokenMasked = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(context),
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
            themeController.toggleTheme(userController.userProfile['id_user']);
            LoggerService.logger.i(
                'Tema: ${themeController.isDarkMode.value ? 'Gelap' : 'Terang'}');
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (userController.userProfile.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      var user = userController.userProfile;
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileImage(),
          const SizedBox(height: 20.0),
          _buildBalanceCards(context),
          const SizedBox(height: 20.0),
          _buildUserInfo(user),
        ],
      );
    }
  }

  Widget _buildProfileImage() {
    return Center(
      child: Obx(() {
        return GestureDetector(
          onTap: () =>
              _showProfileImageDialog(userController.fotoProfile.value),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: userController
                            .getProfileImage2(userController.fotoProfile.value),
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
                        icon: const Icon(Icons.edit,
                            size: 16.0, color: Colors.white),
                        onPressed: userController.pickProfilePhoto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(userController.userProfile['nama_role'] ?? ''),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCards(BuildContext context) {
    var bankBalance = userController.saldoBank.value;
    var cashBalance = userController.saldoTunai.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            _controller.forward(from: 0);
            userController.fetchBalanceData();
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.rotationY(_animation.value),
                alignment: Alignment.center,
                child: Card(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.438,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        const Text('Saldo UP - Bank (Rp)',
                            style: TextStyle(fontSize: 14.0)),
                        const SizedBox(height: 8.0),
                        Text(bankBalance,
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            _controller.forward(from: 0);
            userController.fetchBalanceData();
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.rotationY(_animation.value),
                alignment: Alignment.center,
                child: Card(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.438,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        const Text('Saldo UP - Tunai (Rp)',
                            style: TextStyle(fontSize: 14.0)),
                        const SizedBox(height: 8.0),
                        Text(cashBalance,
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProfileImageDialog(String? profileImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              profileImage != '-'
                  ? Image.memory(base64Decode(profileImage!))
                  : Image.asset('assets/images/default_profile.png'),
              const SizedBox(height: 8.0),
              Text(userController.userProfile['nama_role'] ?? ''),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(RxMap<dynamic, dynamic> user) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('Username'),
                subtitle: Text(user['username']),
              ),
              ListTile(
                title: const Text('Password'),
                subtitle: Text(userController.maskString(user['password'])),
              ),
              const ListTile(
                title: Text('Nama Pegawai'),
                subtitle: Text('tidak ditampilkan'),
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
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const ListTile(
            title: Text('! Harap Dibaca !', style: TextStyle(fontSize: 14)),
            subtitle: Text(
                'Jangan bagikan token dibawah ini kepada siapapun,\nkecuali admin terkait aktivasi maupun masalah teknis/bug aplikasi.',
                style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            title:
                const Text('Token User - 🔑', style: TextStyle(fontSize: 14)),
            subtitle: Text(
                isUserTokenMasked
                    ? userController.maskString(user['refresh_token'])
                    : user['refresh_token'],
                style: const TextStyle(fontSize: 12)),
            onTap: () {
              setState(() {
                isUserTokenMasked = !isUserTokenMasked;
              });
              // set delay to mask the token after 5 seconds
              Future.delayed(const Duration(seconds: 5), () {
                setState(() {
                  isUserTokenMasked = true;
                });
              });
            },
            onLongPress: () {
              if (!isUserTokenMasked) {
                Clipboard.setData(ClipboardData(text: user['refresh_token']));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Token User copied to clipboard')),
                );
                // set delay to mask the token after 2 seconds
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    isUserTokenMasked = !isUserTokenMasked;
                  });
                });
              }
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            title:
                const Text('Token Device - 🔔', style: TextStyle(fontSize: 14)),
            subtitle: Text(
                isFcmTokenMasked
                    ? userController.maskString(userController.fcmToken.value)
                    : userController.fcmToken.value,
                style: const TextStyle(fontSize: 12)),
            onTap: () {
              setState(() {
                isFcmTokenMasked = !isFcmTokenMasked;
              });
              // set delay to mask the token after 5 seconds
              Future.delayed(const Duration(seconds: 5), () {
                setState(() {
                  isFcmTokenMasked = true;
                });
              });
            },
            onLongPress: () {
              if (!isFcmTokenMasked) {
                Clipboard.setData(
                    ClipboardData(text: userController.fcmToken.value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Token Device copied to clipboard')),
                );
                // set delay to mask the token after 2 seconds
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    isFcmTokenMasked = !isFcmTokenMasked;
                  });
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
