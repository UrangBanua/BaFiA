//import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/penatausahaan/tracking_document_controller.dart';
import '../../widgets/custom/custom_loading_animation.dart';

class RBTrackingDocumentPage extends StatelessWidget {
  final RBTrackingDocumentController controller =
      Get.put(RBTrackingDocumentController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  RBTrackingDocumentPage() {
    final String formattedDate = formatter.format(DateTime.now());
    controller.tanggalSampaiController.text = formattedDate;
  }

  // Fungsi menampilkan Total Nilai TBP, Potongan, dan Netto dari SP2D
  void showTotalSnackbar(BuildContext context, Map<String, dynamic> item) {
    final snackBar = SnackBar(
      content: Text('TOTAL Tracking Document\n'
          'SPP: ${controller.formatCurrency(item['total_spp'].toDouble())}\n'
          'SPM: ${controller.formatCurrency(item['total_spm'].toDouble())}\n'
          'SP2D: ${controller.formatCurrency(item['total_sp2d'].toDouble())}'),
      duration:
          const Duration(seconds: 5), // Keep the Snackbar displayed 5 seconds
      action: SnackBarAction(
        label: 'x',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Document Pengajuan Belanja',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.blue),
            onPressed: () {
              var dataToPdf = controller.jenisSP2D.value == '*'
                  ? List<Map<String, dynamic>>.from(
                      controller.responOutput[0]['detail'])
                  : controller.filteredDetails;
              controller.printPdf(dataToPdf);
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
                        child: TextField(
                          controller: controller.tanggalMulaiController,
                          decoration:
                              const InputDecoration(labelText: 'Tanggal Mulai'),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              locale: const Locale('id', 'ID'),
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              initialEntryMode: DatePickerEntryMode.calendar,
                            );
                            if (pickedDate != null) {
                              controller.tanggalMulaiController.text =
                                  formatter.format(pickedDate);
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
                                  formatter.format(pickedDate);
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
                          child: Obx(() => DropdownButton<String?>(
                                value: controller.jenisSP2D.value,
                                onChanged: controller.responOutput.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        controller.jenisSP2D.value = newValue!;
                                        // update tampilan pada listView card dengan memfilter jenis SP2D dari data json yang sudah ada pada item['jenis']
                                        controller
                                            .filterDetails(); // Call the filter function
                                      },
                                items: const [
                                  DropdownMenuItem<String?>(
                                    value: '*',
                                    child: Text('Semua'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'LS',
                                    child: Text('Pengajuan - LS'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'UP',
                                    child: Text('Pengajuan - UP'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'TU',
                                    child: Text('Pengajuan - TU'),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(width: 8.0),
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
                                controller
                                    .filterDetails(); // Call the filter function
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Center(
                        child: IconButton(
                          onPressed: () => controller.previewReport(1),
                          icon: const Icon(
                            Icons.pageview,
                            color: Colors.blue,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: controller.pageNo.value > 1
                                ? () {
                                    controller.pageNo.value--;
                                    controller.previewReport(
                                        controller.pagePrev.value);
                                  }
                                : null,
                          ),
                          Text(
                              'Page ${controller.pageNo.value} of ${controller.totalPages.value}'),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: controller.pageNo.value <
                                    controller.totalPages.value
                                ? () {
                                    controller.pageNo.value++;
                                    controller.previewReport(
                                        controller.pageNext.value);
                                  }
                                : null,
                          ),
                        ],
                      )),
                  const SizedBox(height: 8.0),
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
                var details = controller.jenisSP2D.value == '*'
                    ? controller.responOutput[0]['body']
                    // ignore: invalid_use_of_protected_member
                    : controller.filteredDetails.value;
                if (details is List && details.isNotEmpty) {
                  return ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      var item = details[index];
                      /* Color? tileColor =
                          item['kondisi_selesai'] == 'belum_ada_pengembalian'
                              ? Colors.pinkAccent
                              : item['kondisi_selesai'] == 'menunggu-ver-peng'
                                  ? Colors.amber
                                  : Colors.green; */
                      return Card(
                        child: ListTile(
                          //tileColor: tileColor,
                          title: Text(
                              '${formatter.format(DateTime.parse(item['tanggal_spp']))}, Pengajuan - ${item['jenis_spp']}'),
                          subtitle: Text(
                              'TBP: ${item['nomor_spp']}\nNilai: ${controller.formatCurrency(item['nilai_spp'].toDouble())}'),
                          leading: Icon(
                            item['nomor_sp2d'] == '-'
                                ? Icons.hourglass_empty
                                : item['nomor_spm'] == '-'
                                    ? Icons.hourglass_empty
                                    : Icons.price_check,
                          ),
                          trailing: const Icon(Icons.visibility),
                          onTap: () {
                            // show sub listview to display detail
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    '${item['jenis_spp']} Pada ${item['spp_skpd']}\n\nSPP >> SPM >> SP2D:',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.keyboard_double_arrow_down),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: item['nomor_spp']));
                                            Get.snackbar(
                                              'Salin Nomor SPP',
                                              'Nomor SPP sudah disalin',
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                          tooltip: 'Salin Nomor SPP',
                                          iconSize: 20,
                                          color: Colors.blue,
                                          hoverColor: Colors.lightBlueAccent,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'No SPP: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(text: item['nomor_spp']),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Tanggal SPP: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: formatter.format(
                                                      DateTime.parse(item[
                                                          'tanggal_spp']))),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Nilai SPP: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      controller.formatCurrency(
                                                          item['nilai_spp']
                                                              .toDouble())),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            item['nomor_spm'] == '-'
                                                ? Icons.question_mark
                                                : Icons
                                                    .keyboard_double_arrow_down,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: item['nomor_spm']));
                                            Get.snackbar(
                                              'Salin Nomor SPM',
                                              'Nomor SP2D sudah disalin',
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                          tooltip: 'Salin Nomor SPM',
                                          iconSize: 20,
                                          color: item['nomor_spm'] == '-'
                                              ? Colors.red
                                              : Colors.blue,
                                          highlightColor:
                                              Colors.lightBlueAccent,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'No SPM: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(text: item['nomor_spm']),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Tanggal SPM: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:
                                                    item['tanggal_spm'] != null
                                                        ? formatter.format(
                                                            DateTime.parse(item[
                                                                'tanggal_spm']))
                                                        : '-',
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Nilai SPM: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      controller.formatCurrency(
                                                          item['nilai_spm']
                                                              .toDouble())),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            item['nomor_sp2d'] == '-'
                                                ? Icons.question_mark
                                                : Icons
                                                    .keyboard_double_arrow_down,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: item['nomor_sp2d']));
                                            Get.snackbar(
                                              'Salin Nomor SP2D',
                                              'Nomor SP2D sudah disalin',
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                          tooltip: 'Salin Nomor SP2D',
                                          iconSize: 20,
                                          color: item['nomor_sp2d'] == '-'
                                              ? Colors.red
                                              : Colors.blue,
                                          highlightColor:
                                              Colors.lightBlueAccent,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'No SP2D: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: item['nomor_sp2d']),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Tanggal SP2D: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: item['tanggal_sp2d'] !=
                                                        null
                                                    ? formatter.format(
                                                        DateTime.parse(item[
                                                            'tanggal_sp2d']))
                                                    : '-',
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Nilai SP2D: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      controller.formatCurrency(
                                                          item['nilai_sp2d']
                                                              .toDouble())),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
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
