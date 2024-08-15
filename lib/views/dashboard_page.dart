// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'drawer_menu.dart';
import '../services/logger_service.dart';
import '../services/api_firebase.dart';
import '../services/tutorial_service.dart';
import '../controllers/connectivity_controller.dart';
import '../widgets/custom/animations/custom_button_animation.dart';
import '../widgets/custom/custom_radial_gauge_widget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/custom/animations/custom_loading_animation.dart';

// ignore: must_be_immutable
class DashboardPage extends StatelessWidget {
  int notificationCount = 0;
  //int unreadCount = 1;
  final TutorialService tutorialService = TutorialService();
  final GetStorage storage = GetStorage();
  final ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  final AuthController authController = Get.put(AuthController());
  final DashboardController dashboardController =
      Get.put(DashboardController());
  var idDaerah = Get.find<AuthController>().userData['id_daerah'];
  var idSkpd = Get.find<AuthController>().userData['id_skpd'];
  var namaRole = Get.find<AuthController>().userData['nama_role'];
  var userName = Get.find<AuthController>().userData['username'];
  //final NotificationController notificationController =
  //    Get.put(NotificationController()); // Initialize NotificationController

  DateTime? currentBackPressTime;

  DashboardPage({
    super.key,
  });

  // Create global keys for each widget dashboard
  final GlobalKey keyNotifikasi = GlobalKey();
  final GlobalKey keyHome = GlobalKey();
  final GlobalKey keyLaporan = GlobalKey();
  final GlobalKey keyCekKendali = GlobalKey();
  final GlobalKey keyPengaturan = GlobalKey();

  // Setup tutorial Awal
  void _setupTutorialAwal() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      keyNotifikasi,
      'Untuk menihat Notifikasi/Pesan masuk ada disini.',
      title: 'Notifikasi',
      align: ContentAlign.bottom,
      icon: Icons.notifications_active,
    );
    tutorialService.addTarget(
      keyHome,
      'ini adalah Tombol Cepat dari Fitur Utama. Laporan, Cek Kendali dan Pengaturan.',
      title: 'Fitur Utama',
      align: ContentAlign.top,
      icon: Icons.calendar_today_rounded,
      shape: ShapeLightFocus.RRect,
    );
  }

  // Setup tutorial Menu Utama
  void _setupTutorialMenu() {
    tutorialService.clearTargets(); // Bersihkan target sebelumnya
    tutorialService.addTarget(
      keyLaporan,
      'Semua Fitur dari Laporan, Register & Tracking Realisasi ada disini. sesuai hak akses masing-masing.',
      title: 'Laporan',
      align: ContentAlign.top,
      icon: Icons.person_pin,
      shape: ShapeLightFocus.RRect,
    );
    tutorialService.addTarget(
      keyCekKendali,
      'Untuk Cek Pohon Kendali disini.',
      title: 'Pohon Kendali',
      align: ContentAlign.top,
      icon: Icons.person_pin,
      shape: ShapeLightFocus.RRect,
    );
    tutorialService.addTarget(
      keyPengaturan,
      'Untuk Pengaturan Profil Pengguna dan Cek Saldo ada disini, sesuai hak akses masing-masing.',
      title: 'Pengaturan',
      align: ContentAlign.top,
      icon: Icons.person_pin,
      shape: ShapeLightFocus.RRect,
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      dashboardController.showGauge.value = false;
      Get.snackbar(
        '',
        '                Ketuk tombol sekali lagi untuk keluar',
        //colorText: Colors.red,
        backgroundColor: Colors.transparent,
        //icon: const Icon(Icons.cancel, color: Colors.red),
        snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin:
            const EdgeInsets.all(10), // Adjust the margin to reduce the size
        padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5), // Adjust the padding to reduce the size
      );
      return Future.value(false);
    }

    authController.isLoggedIn.value = false; // Set isLoggedIn to false
    LoggerService.logger.i('App is exit');
    exit(0); // Force stop the application
    //return Future.value(true);
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.1,
          minChildSize: 0.0,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return Column(
              children: [
                // penambahan garis sebagai tanda bisa digeser
                /* Container(
                  width: 45,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ), */
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                key: keyLaporan,
                                onPressed: () {
                                  Get.toNamed('/laporan');
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.chartLine),
                                    SizedBox(height: 4),
                                    Text('Laporan',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spasi antar tombol
                            Expanded(
                              child: ElevatedButton(
                                key: keyCekKendali,
                                onPressed: () {
                                  Get.toNamed('/penatausahaan/dokumen_kendali');
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.wallet),
                                    SizedBox(height: 4),
                                    Text('Cek Kendali',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spasi antar tombol
                            Expanded(
                              child: ElevatedButton(
                                key: keyPengaturan,
                                onPressed: () {
                                  Get.toNamed('/profile_user');
                                },
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.cogs),
                                    SizedBox(height: 4),
                                    Text('Pengaturan',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasShownTutorial = storage.read('tutorialDashboard') ?? false;
    if (!hasShownTutorial) {
      _setupTutorialAwal();
      tutorialService.showTutorial(
        context,
        delayInSeconds: 3,
        tutorialName: 'tutorialDashboard',
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Serapan Realisasi'),
          centerTitle: true,
          actions: [
            Stack(
              children: [
                IconButton(
                  key: keyNotifikasi,
                  icon: const Icon(Icons.notifications_active,
                      color: Colors.blueAccent),
                  onPressed: () {
                    // Handle notification icon press
                    Get.toNamed('/notification');
                  },
                ),
                Obx(() {
                  //dashboardController.loadReadNotifications();
                  notificationCount = dashboardController.dnotifications.length;
                  //notificationController.notifications.length;
                  LoggerService.logger
                      .i('Notification Count: $notificationCount');
                  return notificationCount > 0
                      ? Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Container();
                }),
              ],
            ),
          ],
        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: [
            // tambahkan widget text nama skpd dengan authController.userData['nama_skpd'] mengggunakan Obx
            Obx(() {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '${authController.userData['nama_skpd']}\n',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
            Obx(() {
              if (dashboardController.showGauge.value) {
                return Obx(() {
                  if (dashboardController.isLoading.value) {
                    return const Center(child: CustomLoadingAnimation());
                  } else if (dashboardController.hasError.value) {
                    return const Center(child: Text('Failed to load data'));
                  } else {
                    return RefreshIndicator(
                      onRefresh: dashboardController.fetchDashboardData,
                      child: ListView.builder(
                        itemCount: dashboardController.dashboardData.length,
                        itemBuilder: (context, index) {
                          var data = dashboardController.dashboardData[index];
                          return RadialGaugeWidget(
                            data: data,
                            dashboardController: dashboardController,
                          );
                        },
                      ),
                    );
                  }
                });
              } else {
                // Set Topic Subscribe User
                if (connectivityController.connectivityState.value &&
                    dashboardController.isDemo == false) {
                  // Set Topic Subscribe Id Daerah
                  ApiFirebase().subscribeTopic('bafia-info-$idDaerah');
                  // Set Topic Subscribe IdDaerah-IdSKPD
                  ApiFirebase().subscribeTopic(
                      'bafia-info-$idDaerah-${idSkpd.toString().toLowerCase().replaceAll(' ', '_')}');
                  // Set Topic Subscribe IdDaerah-NamaJabatan
                  ApiFirebase().subscribeTopic(
                      'bafia-info-$idDaerah-${namaRole.toString().toLowerCase().replaceAll(' ', '_')}');
                  // Topic Subscribe NIP User
                  ApiFirebase().subscribeTopic('bafia-info-$userName');
                } else if (connectivityController.connectivityState.value &&
                    dashboardController.isDemo == true) {
                  // Set Topic Subscribe Demo
                  ApiFirebase().subscribeTopic('bafia-info-demo');
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: const FractionalOffset(
                          0.5, 0), // Menaikkan lebih ke atas
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10.0), // Menambahkan jarak bawah
                        child: CustomButtonSerapan(
                          onPressed: () {
                            dashboardController.showGauge.value = true;
                            dashboardController.fetchDashboardData();
                          },
                          color: connectivityController.connectivityState.value
                              ? Colors.blue
                              : Colors.amber,
                          borderWidth: 3.0,
                          fontSize: 32.0,
                          textCaption: 'MULAI',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        height: 160, // Set a fixed height for the text
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              connectivityController.connectivityCaption.value,
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: connectivityController
                                        .connectivityState.value
                                    ? Colors.blue
                                    : Colors.amber,
                              ),
                              duration: const Duration(milliseconds: 2000),
                            ),
                            FadeAnimatedText(
                              connectivityController.connectivityState.value
                                  ? 'silahkan tekan tombol mulai\nuntuk singkron data terbaru'
                                  : 'silahkan tekan tombol mulai\nuntuk singkron data lokal terakhir',
                              textAlign: TextAlign.center,
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: connectivityController
                                        .connectivityState.value
                                    ? Colors.blue
                                    : Colors.amber,
                              ),
                              duration: const Duration(milliseconds: 4000),
                            ),
                          ],
                          repeatForever: true,
                        )),
                  ],
                );
              }
            }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  return ElevatedButton(
                    key: keyHome,
                    onPressed: () {
                      try {
                        _showBottomSheet(context);
                      } catch (e) {
                        LoggerService.logger.e('Error: $e');
                      } finally {
                        bool hasShownTutorial =
                            storage.read('tutorialMenuUtama') ?? false;
                        if (!hasShownTutorial) {
                          _setupTutorialMenu();
                          tutorialService.showTutorial(
                            context,
                            delayInSeconds: 1,
                            tutorialName: 'tutorialMenuUtama',
                          );
                        }
                      }
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.home),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
