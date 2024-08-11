//import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/penatausahaan/register_belanja/pengajuan_tu_controller.dart';
import '../../../widgets/custom/custom_loading_animation.dart';

class RBPengajuanTuPage extends StatelessWidget {
  final RBPengajuanTuController controller = Get.put(RBPengajuanTuController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  RBPengajuanTuPage() {
    final String formattedDate = formatter.format(DateTime.now());
    controller.tanggalSampaiController.text = formattedDate;
  }

  // Fungsi menampilkan Total SP2D, Total Pertanggungjawaban, dan Total Pengembalian
  void showTotalSnackbar(BuildContext context, Map<String, dynamic> item) {
    final snackBar = SnackBar(
      content: Text(
          'TOTAL ${controller.jenisKriteria.value.toUpperCase()} dari Pengajuan TU\n'
          'SP2D: ${controller.formatCurrency(item['total_sp2d'].toDouble())}\n'
          'Pertanggungjawaban: ${controller.formatCurrency(item['total_pertanggungjawaban'].toDouble())}\n'
          'Pengembalian: ${controller.formatCurrency(item['total_pengembalian'].toDouble())}'),
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
          'Register Pengajuan TU',
          style: TextStyle(fontSize: 20),
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
                                value: controller.jenisKriteria.value,
                                onChanged: (String? newValue) {
                                  controller.jenisKriteria.value = newValue!;
                                },
                                items: const [
                                  DropdownMenuItem<String?>(
                                    value: 'semua',
                                    child: Text('Semua'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'belum-pengembalian',
                                    child: Text('Belum Pengembalian'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'menunggu-ver-peng',
                                    child: Text('Belum Verifikasi'),
                                  ),
                                  DropdownMenuItem<String?>(
                                    value: 'selesai',
                                    child: Text('Selesai'),
                                  ),
                                ],
                              )),
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
                var details = controller.responOutput[0]['detail'];
                var totals = controller.responOutput[0];
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (details is List && details.isNotEmpty) {
                  // Tampilkan Total dari list Pengajuan TU
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showTotalSnackbar(context, totals);
                  });
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
                              '${formatter.format(DateTime.parse(item['tanggal_sp2d']))}, ${item['kondisi_selesai']} - ${item['umur']} hari'),
                          subtitle: Text(
                              'SP2D: ${item['nomor_sp2d']}\nNilai: ${controller.formatCurrency(item['nilai_sp2d'].toDouble())}'),
                          leading: Icon(
                            item['kondisi_selesai'] == 'belum_ada_pengembalian'
                                ? Icons.hourglass_empty
                                : item['kondisi_selesai'] == 'menunggu-ver-peng'
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
                                    '${item['nomor_sp2d']}\n\nDengan Uraian:',
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
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Nilai\nSP2D: ',
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
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Pertanggungjawaban: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: controller.formatCurrency(
                                                      item['nilai_pertanggungjawaban']
                                                          .toDouble())),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Pengembalian: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: controller.formatCurrency(
                                                      item['nilai_pengembalian']
                                                          .toDouble())),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Tanggal\nSP2D: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: formatter.format(
                                                      DateTime.parse(item[
                                                          'tanggal_sp2d']))),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Terima: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: formatter.format(
                                                      DateTime.parse(item[
                                                          'transfer_sp2d_at']))),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Pengembalian: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: formatter.format(
                                                      DateTime.parse(item[
                                                          'tanggal_sts']))),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8.0,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              const TextSpan(
                                                text: 'Keterangan: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      '\n${item['keterangan_sp2d']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: item['nomor_dokumen']));
                                        Get.snackbar(
                                          'Salin Nomor',
                                          'Nomor Dokumen sudah disalin',
                                          snackPosition: SnackPosition.TOP,
                                        );
                                      },
                                      tooltip: 'Salin Nomor SP2D',
                                    ),
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
