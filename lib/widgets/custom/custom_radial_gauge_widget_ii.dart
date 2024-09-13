import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../controllers/dashboard_controller.dart';
import '../../services/logger_service.dart';

class RadialGaugeWidgetII extends StatelessWidget {
  final dynamic data;
  final DashboardController dashboardController;
  final PageController _pageController = PageController();

  RadialGaugeWidgetII({
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
        //const SizedBox(height: 20),
        // Card for Belanja
        Card(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SizedBox(
                  // high auto size on mobile
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      // First Page
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SfRadialGauge(
                            title: const GaugeTitle(
                              text: 'Belanja',
                              textStyle: TextStyle(
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
                                    label: ((data['realisasi_rencana_b'] /
                                                data['anggaran_b']) *
                                            100)
                                        .toStringAsFixed(2),
                                    startValue: 0,
                                    endValue: (data['realisasi_rencana_b'] /
                                            data['anggaran_b']) *
                                        100,
                                    color: Colors.orange,
                                    startWidth: 10,
                                    endWidth: 30,
                                  ),
                                  GaugeRange(
                                    label: ((data['realisasi_rill_b'] /
                                                data['anggaran_b']) *
                                            100)
                                        .toStringAsFixed(2),
                                    startValue: 0,
                                    endValue: (data['realisasi_rill_b'] /
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
                                    needleColor: Colors.orange,
                                    animationType: AnimationType.easeOutBack,
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
                                          speed:
                                              const Duration(milliseconds: 100),
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
                                        LoggerService.logger.i(
                                            'Total Anggaran\n$nilaiAnggaran');
                                      },
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 1.1,
                                    widget: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          speed:
                                              const Duration(milliseconds: 150),
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
                                        LoggerService.logger.i(
                                            'Total Realisasi\n$nilaiRealisasi');
                                      },
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 1.4,
                                    widget: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          speed:
                                              const Duration(milliseconds: 150),
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
                                        LoggerService.logger.i(
                                            'Total Selisih Pengajuan vs Realisasi\n$nilaiPengajuan');
                                      },
                                    ),
                                  ),
                                  GaugeAnnotation(
                                    angle: 90,
                                    positionFactor: 1.7,
                                    widget: AnimatedTextKit(
                                      animatedTexts: [
                                        TyperAnimatedText(
                                          speed:
                                              const Duration(milliseconds: 150),
                                          'Catatan: ${dashboardController.catatanPengajuan}',
                                          textAlign: TextAlign.center,
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Color.fromARGB(
                                                255, 182, 54, 54),
                                          ),
                                        ),
                                      ],
                                      isRepeatingAnimation: true,
                                      onTap: () {
                                        LoggerService.logger.i('Catatan...');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Second Page
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SfRadialGauge(
                            title: const GaugeTitle(
                              text: 'Pendapatan',
                              textStyle: TextStyle(
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
                                    label: 0.toStringAsFixed(2),
                                    startValue: 0,
                                    endValue: 5,
                                    color: Colors.orange,
                                    startWidth: 10,
                                    endWidth: 30,
                                  ),
                                  GaugeRange(
                                    label: (0).toStringAsFixed(2),
                                    startValue: 0,
                                    endValue: 2.5,
                                    color: Colors.lightGreen,
                                    startWidth: 10,
                                    endWidth: 30,
                                  ),
                                ],
                                pointers: const <GaugePointer>[
                                  NeedlePointer(
                                    enableAnimation: true,
                                    needleColor: Colors.orange,
                                    animationType: AnimationType.easeOutBack,
                                    animationDuration: 3000,
                                    value: 0,
                                  )
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    positionFactor: 0.4,
                                    angle: 90,
                                    widget: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          '0 %',
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
                                          speed:
                                              const Duration(milliseconds: 100),
                                          'Total Anggaran\n~',
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
                                    positionFactor: 1.1,
                                    widget: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          speed:
                                              const Duration(milliseconds: 150),
                                          'Data Pendapatan Belum Tersedia Saat ini',
                                          textAlign: TextAlign.center,
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.red,
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 2, // Update this count based on the number of pages
                  effect: const WormEffect(
                    dotHeight: 4,
                    dotWidth: 4,
                    activeDotColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
