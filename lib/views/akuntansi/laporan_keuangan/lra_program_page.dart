import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '/controllers/akuntansi/laporan_keuagan/lra_program_controller.dart';

class LKLraProgramPage extends StatelessWidget {
  final LKLraProgramController controller = Get.put(LKLraProgramController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Realisasi Anggaran Program',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.blue),
            onPressed: controller.printPdf,
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
                        child: TextField(
                          controller: controller.tanggalMulaiController,
                          decoration:
                              const InputDecoration(labelText: 'Tanggal Mulai'),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              initialEntryMode: DatePickerEntryMode.calendar,
                            );
                            if (pickedDate != null) {
                              controller.tanggalMulaiController.text =
                                  "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: controller.tanggalSampaiController,
                          decoration: const InputDecoration(
                              labelText: 'Tanggal Sampai'),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              initialEntryMode: DatePickerEntryMode.calendar,
                            );
                            if (pickedDate != null) {
                              controller.tanggalSampaiController.text =
                                  "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: 200,
                          child: Obx(() => DropdownButton<int?>(
                                value: controller.klasifikasi.value,
                                onChanged: (int? newValue) {
                                  controller.klasifikasi.value = newValue!;
                                },
                                items: const [
                                  DropdownMenuItem<int?>(
                                    value: 0,
                                    child: Text('Tanpa Uraian'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 1,
                                    child: Text('1. Urusan'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 2,
                                    child: Text('2. Bidang Urusan'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 3,
                                    child: Text('3. SKPD'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 4,
                                    child: Text('4. Program'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 5,
                                    child: Text('5. Kegiatan'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 6,
                                    child: Text('6. Sub Kegiatan'),
                                  ),
                                  DropdownMenuItem<int?>(
                                    value: 6,
                                    child: Text('7. Rekening'),
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
                                value: controller.konsolidasiSKPD.value,
                                onChanged: (String? newValue) {
                                  controller.konsolidasiSKPD.value = newValue!;
                                },
                                items: const [
                                  DropdownMenuItem<String?>(
                                    value: 'skpd',
                                    child: Text('SKPD'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'skpd_unit',
                                    child: Text('SKPD & Unit'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'skpd_mandiri',
                                    child: Text('SKPD & Konsolidasi'),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
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
            ),
          ),
          // Panel 2: PDF Viewer
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.filePdf.value.isEmpty) {
                return const Center(child: Text('No PDF to display'));
              } else {
                return PDFView(
                  pdfData: controller.filePdf.value,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: false,
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
