//import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/penatausahaan/tracking_realisasi_controller.dart';
import '../../../widgets/custom/animations/custom_loading_animation.dart';
import '../../../widgets/custom/custom_datagrid_widget.dart';

class RBTrackingRealisasiPage extends StatelessWidget {
  final RBTrackingRealisasi controller = Get.put(RBTrackingRealisasi());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  RBTrackingRealisasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Realisasi Perbulan',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.blue),
            onPressed: () {
              var dataToPdf = controller.jenisDokumen.value == '*'
                  ? controller.responOutput
                  : controller.filteredDetails;
              controller.printPdf(dataToPdf as List<Map<String, dynamic>>);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel 1: Input Parameters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: 200,
                          child: Obx(() => DropdownButton<String?>(
                                value: controller.pilihBulan.value,
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != controller.pilihBulan.value) {
                                    controller.pilihBulan.value = newValue;
                                  }
                                },
                                items: const [
                                  DropdownMenuItem<String?>(
                                    value: '1',
                                    child: Text('Januari'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '2',
                                    child: Text('Februari'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '3',
                                    child: Text('Maret'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '4',
                                    child: Text('April'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '5',
                                    child: Text('Mei'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '6',
                                    child: Text('Juni'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '7',
                                    child: Text('Juli'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '8',
                                    child: Text('Agustus'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '9',
                                    child: Text('September'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '10',
                                    child: Text('Oktober'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '11',
                                    child: Text('November'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: '12',
                                    child: Text('Desember'),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: SizedBox(
                          width: 200,
                          child: Obx(() => DropdownButton<String?>(
                                value: controller.jenisDokumen.value,
                                onChanged: controller.responOutput.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        controller.jenisDokumen.value =
                                            newValue!;
                                        controller.filterDetails();
                                      },
                                items: const [
                                  DropdownMenuItem<String?>(
                                    value: '*',
                                    child: Text('Semua'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'gantung',
                                    child: Text('Belum Terealisasi'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'LS',
                                    child: Text('Tracking - LS'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'TU',
                                    child: Text('Tracking - TU'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'UP',
                                    child: Text('Tracking - GU'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'STS',
                                    child: Text('Tracking - STS'),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => SizedBox(
                            height: 32.0,
                            child: TextField(
                              controller: controller.searchQueryController,
                              decoration: const InputDecoration(
                                hintText: 'Cari',
                              ),
                              enabled: controller.responOutput.isNotEmpty,
                              onChanged: (value) {
                                controller.searchQuery.value = value;
                                controller.filterDetails();
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Center(
                        child: IconButton(
                          onPressed: controller.previewReport,
                          icon: const Icon(
                            Icons.pageview,
                            color: Colors.blue,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Panel 2: PDF Viewer
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CustomLoadingAnimation());
              } else if (controller.responOutput.isEmpty) {
                return const Center(child: Text('No data display'));
              } else {
                var details = controller.jenisDokumen.value == '*'
                    ? controller.responOutput
                    : controller.filteredDetails;
                if (details.isNotEmpty &&
                    details[0]['jenis_transaksi'].isNotEmpty) {
                  return CustomDataGrid(
                    jsonData: List<Map<String, dynamic>>.from(details),
                    columns: controller.columnsDataGrid,
                    stackedHeader: true,
                    stackedHeaderRows: controller.stackedHeaderRows,
                    columnWidthMode: controller.columnWidthMode,
                  );
                } else {
                  return const Center(child: Text('Data tidak ditemukan'));
                }
              }
            }),
          ),
        ],
      ),
    );
  }
}
