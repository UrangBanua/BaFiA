import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'drawer_menu.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Import Syncfusion Flutter Gauges library
import '../controllers/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: DrawerMenu(),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (dashboardController.hasError.value) {
          return Center(child: Text('Failed to load data'));
        } else {
          return RefreshIndicator(
            onRefresh: dashboardController.fetchDashboardData,
            child: ListView.builder(
              itemCount: dashboardController.dashboardData.length,
              itemBuilder: (context, index) {
                var data = dashboardController.dashboardData[index];
                var nilaiAnggaran = NumberFormat.currency(
                        symbol: 'Rp ',
                        decimalDigits: 2,
                        locale: Localizations.localeOf(context).toString())
                    .format(data['anggaran']);
                var nilaiPengajuan = NumberFormat.currency(
                        symbol: 'Rp ',
                        decimalDigits: 2,
                        locale: Localizations.localeOf(context).toString())
                    .format(data['realisasi_rencana']);
                var nilaiRealisasi = NumberFormat.currency(
                        symbol: 'Rp ',
                        decimalDigits: 2,
                        locale: Localizations.localeOf(context).toString())
                    .format(data['realisasi_rill']);
                return Column(
                  children: [
                    Text('\nSerapan Realisasi Anggaran',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                        '\n' +
                            DateFormat('dd MMMM y', 'id')
                                .format(DateTime.parse(data['time_update'])),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('${data['nama_skpd']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold))),
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.7,
                              widget: Text(
                                'Total Anggaran\n${nilaiAnggaran}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 1.2,
                              widget: Text(
                                'Total Pengajuan Realisasi\n${nilaiPengajuan}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 1.7,
                              widget: Text(
                                'Total Pencairan Realisasi\n${nilaiRealisasi}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
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
          );
        }
      }),
    );
  }
}
