// buat class CustomBottomSheet
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'animations/custom_pulse_animation.dart';
import '../../controllers/auth_controller.dart';
import '../../services/logger_service.dart';
import '../../services/tutorial_service.dart';

class CustomBottomSheet extends StatelessWidget {
  final TutorialService tutorialService = TutorialService();
  final AuthController authController = Get.find<AuthController>();

  // Key untuk tombol Tutorial
  final GlobalKey keyLaporan = GlobalKey();
  final GlobalKey keyCekKendali = GlobalKey();
  final GlobalKey keyPengaturan = GlobalKey();

  // Setup tutorial Menu Utama
  void setupTutorialMenu() {
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

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.blue.withOpacity(0.1),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.2,
          minChildSize: 0.0,
          maxChildSize: 0.3,
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.chartLine,
                                        color: Colors.blue),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.wallet,
                                        color: Colors.blue),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.assignment_ind,
                                        color: Colors.blue),
                                    SizedBox(height: 4),
                                    Text('Profile',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/akuntansi/menu_jurnal');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.multiline_chart,
                                        color: Colors.green),
                                    SizedBox(height: 4),
                                    Text('Menu Jurnal',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spasi antar tombol
                            Expanded(
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    //Get.toNamed('/aklap/form_approve');
                                    LoggerService.logger
                                        .i('Tampilkan Asisten BaFiA');
                                  },
                                  child: CustomPulseButton(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spasi antar tombol
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Pilih Tracking',
                                            textAlign: TextAlign.center),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Tutup dialog
                                                Get.toNamed(
                                                    '/penatausahaan/tracking_document');
                                              },
                                              child: const Text(
                                                  'Tracking Document',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Tutup dialog
                                                Get.toNamed(
                                                    '/penatausahaan/tracking_realisasi');
                                              },
                                              child: const Text(
                                                  'Tracking Realisasi',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.query_stats,
                                        color: Colors.green),
                                    SizedBox(height: 4),
                                    Text('Tracking',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/akuntansi/menu_buku');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.menu_book, color: Colors.green),
                                    SizedBox(height: 4),
                                    Text('Pembukuan',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Spasi antar tombol
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/task_list');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.task_alt_rounded,
                                        color: Colors.green),
                                    SizedBox(height: 4),
                                    Text('Task List',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  authController.logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .transparent, // Set background color to transparent
                                  elevation: 0, // Remove elevation
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.logout, color: Colors.amber),
                                    SizedBox(height: 4),
                                    Text('Logout',
                                        style: TextStyle(fontSize: 11)),
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
    tutorialService.showTutorial(
      context,
      delayInSeconds: 1,
      tutorialName: 'tutorialMenuUtama',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
