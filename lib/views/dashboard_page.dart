import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'drawer_menu.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Import Syncfusion Flutter Gauges library
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/dashboard_controller.dart';

// ignore: must_be_immutable
class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  DateTime? currentBackPressTime;

  DashboardPage({super.key});

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
        appBar: AppBar(title: const Text('Dashboard')),
        drawer: DrawerMenu(),
        body: Obx(() {
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
                      var nilaiAnggaran = NumberFormat.currency(
                              symbol: 'Rp ',
                              decimalDigits: 2,
                              locale:
                                  Localizations.localeOf(context).toString())
                          .format(data['anggaran']);
                      var nilaiPengajuan = NumberFormat.currency(
                              symbol: 'Rp ',
                              decimalDigits: 2,
                              locale:
                                  Localizations.localeOf(context).toString())
                          .format(data['realisasi_rencana']);
                      var nilaiRealisasi = NumberFormat.currency(
                              symbol: 'Rp ',
                              decimalDigits: 2,
                              locale:
                                  Localizations.localeOf(context).toString())
                          .format(data['realisasi_rill']);
                      return Column(
                        children: [
                          const Text('\nSerapan Realisasi Anggaran',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          Text(
                              '\n${DateFormat('dd MMMM y', 'id').format(DateTime.parse(data['time_update']))}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('${data['nama_skpd']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 100,
                                canScaleToFit: true,
                                labelOffset: 30,
                                radiusFactor: 0.8,
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                      startValue: 0,
                                      endValue: 100,
                                      color: Colors.lightGreen,
                                      startWidth: 10,
                                      endWidth: 30),
                                  GaugeRange(
                                      label: ((data['realisasi_rill'] /
                                                  data['anggaran']) *
                                              100)
                                          .toStringAsFixed(2),
                                      startValue: 0,
                                      endValue: (data['realisasi_rencana'] /
                                              data['anggaran']) *
                                          100,
                                      color: Colors.blueAccent,
                                      startWidth: 10,
                                      endWidth: 30),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                      enableAnimation: true,
                                      animationType: AnimationType.easeOutBack,
                                      animationDuration:
                                          3000, // add animation duration
                                      value: (data['realisasi_rill'] /
                                              data['anggaran']) *
                                          100),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                      positionFactor: 0.4,
                                      angle: 90,
                                      widget: Text(
                                          '${((data['realisasi_rill'] / data['anggaran']) * 100).toStringAsFixed(2)} %',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 0.7,
                                    widget: Text(
                                      'Total Anggaran\n$nilaiAnggaran',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 1.1,
                                    widget: Text(
                                      'Total Pengajuan Realisasi\n$nilaiPengajuan',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 1.5,
                                    widget: Text(
                                      'Total Realisasi\n$nilaiRealisasi',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/penatausahaan/dokumen_kendali');
                      },
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.wallet), //
                          SizedBox(
                              height:
                                  4), // Add some space between the icon and text
                          Text('Cek Kendali'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
