import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom/custom_button_animation.dart';
import '../widgets/dashboard_page/radial_gauge_widget.dart';
import 'drawer_menu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/services/logger_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/custom/custom_loading_animation.dart';

// ignore: must_be_immutable
class DashboardPage extends StatelessWidget {
  int notificationCount = 0;
  //int unreadCount = 1;
  final AuthController authController = Get.put(AuthController());
  final DashboardController dashboardController =
      Get.put(DashboardController());
  //final NotificationController notificationController =
  //    Get.put(NotificationController()); // Initialize NotificationController

  DateTime? currentBackPressTime;

  DashboardPage({super.key});

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Get.snackbar('Exit', 'Ketuk tombol sekali lagi untuk keluar');
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
            return ListView(
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/laporan');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.chartLine),
                            SizedBox(height: 4),
                            Text('Laporan'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/penatausahaan/dokumen_kendali');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.wallet),
                            SizedBox(height: 4),
                            Text('Cek Kendali'),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed('/profile_user');
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ignore: deprecated_member_use
                            FaIcon(FontAwesomeIcons.cogs),
                            SizedBox(height: 4),
                            Text('Pengaturan'),
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
                return Align(
                  alignment: const FractionalOffset(0.5,
                      0.3), // 0.5 untuk horizontal center, 0.7 untuk menyesuaikan tinggi
                  child: CustomButtonSerapan(
                    onPressed: () {
                      dashboardController.showGauge.value = true;
                      dashboardController.fetchDashboardData();
                    },
                    color: Colors.blue,
                    borderWidth: 3.0,
                    fontSize: 32.0,
                    textCaption: 'MULAI',
                  ),
                );
              }
            }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showBottomSheet(context),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ignore: deprecated_member_use
                      FaIcon(FontAwesomeIcons.home),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
