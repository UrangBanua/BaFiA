//import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/penatausahaan/register_belanja/spm_controller.dart';
import '../../../widgets/custom/animations/custom_loading_animation.dart';

class RBSpmPage extends StatelessWidget {
  final RBSpmController controller = Get.put(RBSpmController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  RBSpmPage() {
    final String formattedDate = formatter.format(DateTime.now());
    controller.tanggalSampaiController.text = formattedDate;
  }

  // Fungsi menampilkan Total Nilai SPM, Potongan, dan Netto dari SP2D
  void showTotalSnackbar(BuildContext context, Map<String, dynamic> item) {
    final snackBar = SnackBar(
      //buat background color lebih agak transparan dan sahpe lebih bulat dengan border color hijau dan tambahkan Close Icon
      backgroundColor: Colors.transparent.withOpacity(0.85),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: Colors.lightGreenAccent)),
      showCloseIcon: true,
      closeIconColor: Colors.red,
      content: Text(
          'TOTAL ${controller.jenisKriteria.value.toUpperCase()} dari SPM\n'
          'Bruto: ${controller.formatCurrency(item['total_bruto'].toDouble())}\n'
          'Potongan: ${controller.formatCurrency(item['total_potongan'].toDouble())}\n'
          'Netto: ${controller.formatCurrency(item['total_netto'].toDouble())}'),
      duration: const Duration(minutes: 60),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          return true; // Allow the pop to happen
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Register SPM',
              style: TextStyle(fontSize: 20),
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
                              decoration: const InputDecoration(
                                  labelText: 'Tanggal Mulai'),
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  locale: const Locale('id', 'ID'),
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  initialEntryMode:
                                      DatePickerEntryMode.calendar,
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
                                  initialEntryMode:
                                      DatePickerEntryMode.calendar,
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
                                            controller.jenisSP2D.value =
                                                newValue!;
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
                                        child: Text('SPM - LS'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'TU',
                                        child: Text('SPM - TU'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'GU',
                                        child: Text('SPM - GU'),
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
                    var details = controller.jenisSP2D.value == '*'
                        ? controller.responOutput[0]['detail']
                        // ignore: invalid_use_of_protected_member
                        : controller.filteredDetails.value;
                    var totals = controller.responOutput[0];
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (details is List && details.isNotEmpty) {
                      if (controller.jenisSP2D.value == '*' &&
                          controller.searchQuery.value.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showTotalSnackbar(context, totals);
                        });
                      }
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
                            // set shape lebih bulat dan renggang and shape color
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(
                                    color: Colors.lightBlueAccent)),
                            child: ListTile(
                              //tileColor: tileColor,
                              title: Text(
                                  '${formatter.format(DateTime.parse(item['tanggal_pembuatan']))}, SPM - ${item['jenis']} ${item['keterangan'].toLowerCase().contains('gaji') ? ' Gaji' : ''}'),
                              subtitle: Text(
                                  'SPM: ${item['nomor_dokumen']}\nNilai: ${controller.formatCurrency(item['nilai_bruto'].toDouble())}'),
                              leading: Icon(
                                item['kondisi_selesai'] ==
                                        'belum_ada_pengembalian'
                                    ? Icons.hourglass_empty
                                    : item['kondisi_selesai'] ==
                                            'menunggu-ver-peng'
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
                                        '${item['nomor_dokumen']}\n\nDengan Uraian:',
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
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text: 'Jenis: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(text: item['jenis']),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text: 'Nilai\nBruto: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: controller
                                                          .formatCurrency(item[
                                                                  'nilai_bruto']
                                                              .toDouble())),
                                                ],
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text: 'Potongan: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: controller
                                                          .formatCurrency(item[
                                                                  'nilai_potongan']
                                                              .toDouble())),
                                                ],
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text: 'Netto: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: controller
                                                          .formatCurrency(item[
                                                                  'nilai_netto']
                                                              .toDouble())),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text:
                                                        'Tanggal\nPembuatan: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: formatter.format(
                                                          DateTime.parse(item[
                                                              'tanggal_pembuatan']))),
                                                ],
                                              ),
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: [
                                                  const TextSpan(
                                                    text: 'Pencairan: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: formatter.format(
                                                          DateTime.parse(item[
                                                              'tanggal_pencairan']))),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8.0,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    DefaultTextStyle.of(context)
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
                                                          '\n${item['keterangan']}\n\n'),
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
        ));
  }
}
