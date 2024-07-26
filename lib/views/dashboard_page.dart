import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'drawer_menu.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../controllers/dashboard_controller.dart';

// ignore: must_be_immutable
class DashboardPage extends StatelessWidget {
  int notificationCount = 3;
  final DashboardController dashboardController =
      Get.put(DashboardController());
  DateTime? currentBackPressTime;

  DashboardPage({super.key});

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
            return Obx(() {
              if (dashboardController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (dashboardController.hasError.value) {
                return const Center(child: Text('Failed to load data'));
              } else {
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
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ketuk tombol sekali lagi untuk keluar')),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar:
            AppBar(title: const Text('Serapan Realisasi'), centerTitle: true),
        drawer: DrawerMenu(),
        body: Stack(
          children: [
            Obx(() {
              if (dashboardController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (dashboardController.hasError.value) {
                return const Center(child: Text('Failed to load data'));
              } else {
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: dashboardController.fetchDashboardData,
                      child: ListView.builder(
                        itemCount: dashboardController.dashboardData.length,
                        itemBuilder: (context, index) {
                          var data = dashboardController.dashboardData[index];
                          var nilaiAnggaran = dashboardController
                              .formatCurrency(data['anggaran_b'], context);
                          var nilaiPengajuan =
                              dashboardController.formatCurrency(
                                  data['realisasi_rencana_b'], context);
                          var nilaiRealisasi =
                              dashboardController.formatCurrency(
                                  data['realisasi_rill_b'], context);
                          return Column(
                            children: [
                              Text(
                                dashboardController
                                    .formatDate(data['time_update']),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${data['nama_skpd']}\n',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SfRadialGauge(
                                title: const GaugeTitle(
                                  text: '\nBelanja',
                                  textStyle: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 100,
                                    canScaleToFit: true,
                                    labelOffset: 30,
                                    radiusFactor: 0.95,
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                        startValue: 0,
                                        endValue: 100,
                                        color: Colors.blueAccent,
                                        startWidth: 10,
                                        endWidth: 30,
                                      ),
                                      GaugeRange(
                                        label: ((data['realisasi_rill_b'] /
                                                    data['anggaran_b']) *
                                                100)
                                            .toStringAsFixed(2),
                                        startValue: 0,
                                        endValue: (data['realisasi_rencana_b'] /
                                                data['anggaran_b']) *
                                            100,
                                        color: Colors.lightGreen,
                                        startWidth: 10,
                                        endWidth: 30,
                                      ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                        enableAnimation: true,
                                        needleColor: Colors.deepPurpleAccent,
                                        animationType:
                                            AnimationType.easeOutBack,
                                        animationDuration: 3000,
                                        value: (data['realisasi_rencana_b'] /
                                                data['anggaran_b']) *
                                            100,
                                      ),
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        positionFactor: 0.4,
                                        angle: 90,
                                        widget: AnimatedTextKit(
                                          animatedTexts: [
                                            TypewriterAnimatedText(
                                              '${((data['realisasi_rill_b'] / data['anggaran_b']) * 100).toStringAsFixed(2)} %',
                                              textAlign: TextAlign.center,
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        ),
                                      ),
                                      GaugeAnnotation(
                                        angle: 90,
                                        positionFactor: 0.8,
                                        widget: AnimatedTextKit(
                                          animatedTexts: [
                                            TypewriterAnimatedText(
                                              speed: const Duration(
                                                  milliseconds: 100),
                                              'Total Anggaran\n$nilaiAnggaran',
                                              textAlign: TextAlign.center,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        ),
                                      ),
                                      GaugeAnnotation(
                                        angle: 90,
                                        positionFactor: 1.2,
                                        widget: AnimatedTextKit(
                                          animatedTexts: [
                                            TypewriterAnimatedText(
                                              speed: const Duration(
                                                  milliseconds: 150),
                                              'Total Pengajuan\n$nilaiPengajuan',
                                              textAlign: TextAlign.center,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.deepPurpleAccent,
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        ),
                                      ),
                                      GaugeAnnotation(
                                        angle: 90,
                                        positionFactor: 1.6,
                                        widget: AnimatedTextKit(
                                          animatedTexts: [
                                            TypewriterAnimatedText(
                                              speed: const Duration(
                                                  milliseconds: 200),
                                              'Total Realisasi\n$nilaiRealisasi',
                                              textAlign: TextAlign.center,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                          isRepeatingAnimation: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
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
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, right: 16.0),
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Get.toNamed('/notification');
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications),
                      if (notificationCount > 0)
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
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
