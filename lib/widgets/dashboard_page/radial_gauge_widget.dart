import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../controllers/dashboard_controller.dart';

class RadialGaugeWidget extends StatelessWidget {
  final dynamic data;
  final DashboardController dashboardController;

  const RadialGaugeWidget({
    super.key,
    required this.data,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    var nilaiAnggaran =
        dashboardController.formatCurrency(data['anggaran_b'], context);
    var nilaiRealisasi =
        dashboardController.formatCurrency(data['realisasi_rill_b'], context);
    var nilaiPengajuan = dashboardController.formatCurrency(
        data['realisasi_rencana_b'] - data['realisasi_rill_b'], context);

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          '\n ${dashboardController.formatDate(data['time_update'])}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        // tambahkan iconbutton switch
        /* IconButton(
          icon: const Icon(Icons.settings_ethernet),
          onPressed: () {
            dashboardController.showGauge.value = false;
          },
        ), */
        SfRadialGauge(
          title: const GaugeTitle(
            text: 'Belanja',
            textStyle: TextStyle(
              color: Colors.blue,
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
                  label:
                      ((data['realisasi_rencana_b'] / data['anggaran_b']) * 100)
                          .toStringAsFixed(2),
                  startValue: 0,
                  endValue:
                      (data['realisasi_rencana_b'] / data['anggaran_b']) * 100,
                  color: Colors.orange,
                  startWidth: 10,
                  endWidth: 30,
                ),
                GaugeRange(
                  label: ((data['realisasi_rill_b'] / data['anggaran_b']) * 100)
                      .toStringAsFixed(2),
                  startValue: 0,
                  endValue:
                      (data['realisasi_rill_b'] / data['anggaran_b']) * 100,
                  color: Colors.lightGreen,
                  startWidth: 10,
                  endWidth: 30,
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  enableAnimation: true,
                  needleColor: Colors.orange,
                  animationType: AnimationType.easeOutBack,
                  animationDuration: 3000,
                  value:
                      (data['realisasi_rencana_b'] / data['anggaran_b']) * 100,
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
                        speed: const Duration(milliseconds: 100),
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
                    onTap: () {
                      if (kDebugMode) {
                        print('Total Anggaran\n$nilaiAnggaran');
                      }
                    },
                  ),
                ),
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 1.2,
                  widget: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        speed: const Duration(milliseconds: 150),
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
                    onTap: () {
                      if (kDebugMode) {
                        print('Total Realisasi\n$nilaiRealisasi');
                      }
                    },
                  ),
                ),
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 1.6,
                  widget: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        speed: const Duration(milliseconds: 150),
                        'Total Selisih Pengajuan vs Realisasi\n$nilaiPengajuan',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                    isRepeatingAnimation: false,
                    onTap: () {
                      if (kDebugMode) {
                        print(
                            'Total Selisih Pengajuan vs Realisasi\n$nilaiPengajuan');
                      }
                    },
                  ),
                ),
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 1.95,
                  widget: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        speed: const Duration(milliseconds: 150),
                        'Catatan: ${dashboardController.catatanPengajuan}',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Color.fromARGB(255, 182, 54, 54),
                        ),
                      ),
                    ],
                    isRepeatingAnimation: true,
                    onTap: () {
                      if (kDebugMode) {
                        print('Catatan...');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
