// buat class CustomBottomSheet
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../services/logger_service.dart';
import '../../services/tutorial_service.dart';

class CustomBottomSheet extends StatelessWidget {
  final TutorialService tutorialService = TutorialService();

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
                                  Get.toNamed('/akuntansi/menu_aklap');
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
                                  child: Image.asset(
                                    //Image.network(
                                    //'https://mir-s3-cdn-cf.behance.net/project_modules/disp/04de2e31234507.564a1d23645bf.gif',
                                    //'https://mir-s3-cdn-cf.behance.net/project_modules/disp/35771931234507.564a1d2403b3a.gif',
                                    'assets/images/menu.gif',
                                    height:
                                        80, // Sesuaikan ukuran sesuai kebutuhan
                                    width:
                                        80, // Sesuaikan ukuran sesuai kebutuhan
                                  ),
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
    return Container();
  }
}
