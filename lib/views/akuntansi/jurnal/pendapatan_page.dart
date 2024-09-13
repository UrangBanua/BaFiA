//import 'package:bafia/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/akuntansi/jurnal/jurnal_pendapatan_controller.dart';
import '../../../widgets/custom/animations/custom_loading_animation.dart';
import '../../../services/logger_service.dart';

class JRPendapatanPage extends StatelessWidget {
  final JRPendapatanController controller = Get.put(JRPendapatanController());
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  JRPendapatanPage({super.key}) {
    final String formattedDate = formatter.format(DateTime.now());
    controller.tanggalSampaiController.text = formattedDate;
  }

  // Fungsi menampilkan Total dan Tombol CheckAll, UnCheckAll, Approve, UnApprove
  void showTotalSnackbar(BuildContext context, Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        //buat background color lebih agak transparan dan sahpe lebih bulat dengan border color hijau dan tambahkan Close Icon
        backgroundColor: Colors.transparent.withOpacity(0.85),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Colors.lightGreenAccent)),
        showCloseIcon: true,
        closeIconColor: Colors.red,
        content: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // add textButton if controller.jenisStatus.value 0 to show Approve
                if (controller.responOutput.isNotEmpty &&
                    controller.jenisStatus.value == 0)
                  TextButton(
                    onPressed: () {
                      LoggerService.logger
                          .i('Approve: ${controller.selectedIds}');
                      // Add your Approve logic here
                    },
                    child: const Text('Approve',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                // add textButton if controller.jenisStatus.value = 3 to show Approve
                if (controller.responOutput.isNotEmpty &&
                    controller.jenisStatus.value == 3)
                  TextButton(
                    onPressed: () {
                      LoggerService.logger
                          .i('Unapprove: ${controller.selectedIds}');
                      // Add your Approve logic here
                    },
                    child: Text('UnApprove',
                        style: TextStyle(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.bold)),
                  ),
                // add textButton if controller.jenisStatus.value == 0 to show CheckAll
                if (controller.responOutput.isNotEmpty &&
                    (controller.jenisStatus.value == 0 ||
                        controller.jenisStatus.value == 3))
                  TextButton(
                    onPressed: () {
                      // set controller.checkboxStatus index all to true
                      controller.checkboxStatus.assignAll(List<bool>.filled(
                          controller.checkboxStatus.length, true));
                      // add all items selectedIds
                      controller.selectedIds.assignAll(List<int>.from(controller
                          .responOutput[0]['data']
                          .map((e) => e['id_stbp'] ?? e['id_sts'])));
                      LoggerService.logger.i(controller.selectedIds);
                    },
                    child: const Text('CheckAll',
                        style: TextStyle(color: Colors.blue)),
                  ),
                // add textButton if controller.jenisStatus.value == 0 to show UnCheckAll
                if (controller.responOutput.isNotEmpty &&
                    (controller.jenisStatus.value == 0 ||
                        controller.jenisStatus.value == 3))
                  TextButton(
                    onPressed: () {
                      // set controller.checkboxStatus index all to false
                      controller.checkboxStatus.assignAll(List<bool>.filled(
                          controller.checkboxStatus.length, false));
                      // remove all items selectedIds
                      controller.selectedIds.clear();
                      LoggerService.logger.i(controller.selectedIds);
                    },
                    child: const Text('UnCheckAll',
                        style: TextStyle(color: Colors.blueAccent)),
                  ),
                if (controller.responOutput.isNotEmpty &&
                    controller.jenisStatus.value == 5)
                  Text('Total ${controller.responOutput[0]['count']} data'),
              ],
            )),
        duration:
            const Duration(minutes: 60), // Extended duration to 10 seconds
      ),
    );
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
            'Jurnal Pendapatan',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.print, color: Colors.blue),
              onPressed: () {
                var dataToPdf = controller.jenisJurnal.value == 1
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
                            child: Obx(() => DropdownButton<int?>(
                                  value: controller.jenisJurnal.value,
                                  onChanged: (int? newValue) {
                                    controller.jenisJurnal.value = newValue!;
                                    controller.responOutput.clear();
                                  },
                                  items: const [
                                    DropdownMenuItem<int?>(
                                      value: 1,
                                      child: Text('Penerimaan'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 3,
                                      child: Text('Setoran'),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: SizedBox(
                            width: 200,
                            child: Obx(() => DropdownButton<int?>(
                                  value: controller.jenisStatus.value,
                                  onChanged: (int? newValue) {
                                    controller.jenisStatus.value = newValue!;
                                    controller.responOutput.clear();
                                  },
                                  items: const [
                                    DropdownMenuItem<int?>(
                                      value: 5,
                                      child: Text('Semua'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 3,
                                      child: Text('Approve'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 4,
                                      child: Text('Reject'),
                                    ),
                                    DropdownMenuItem<int?>(
                                      value: 0,
                                      child: Text('Belum'),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
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
                                /* controller
                                  .filterDetails(); */ // Call the filter function
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
                    ]),
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
                  var details = controller.jenisJurnal.value == 1 ||
                          controller.jenisJurnal.value == 3
                      ? controller.responOutput[0]['data']
                      // ignore: invalid_use_of_protected_member
                      : controller.filteredDetails.value;
                  var totals = controller.responOutput[0];
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (details is List && details.isNotEmpty) {
                    if (controller.searchQuery.value.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showTotalSnackbar(context, totals);
                      });
                    }
                    return ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        var item = details[index];
                        return Card(
                          // set shape lebih bulat dan renggang and shape color
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Colors.lightBlueAccent)),
                          child: ListTile(
                            //tileColor: tileColor,
                            title: Text(
                                '${item['jenis'] == '1' ? (item['tanggal_stbp'] != null && item['tanggal_stbp'] != '' ? formatter.format(DateTime.parse(item['tanggal_stbp'])) : '') : (item['tanggal_sts'] != null && item['tanggal_sts'] != '' ? formatter.format(DateTime.parse(item['tanggal_sts'])) : '')}, ${item['jenis'] == '1' ? 'Penerimaan' : 'Setoran'}'),
                            subtitle: Text(
                                '${item['jenis'] == '1' ? item['nomor_stbp'] ?? '' : item['nomor_sts'] ?? ''}\nNilai: ${controller.formatCurrency(double.parse(item['jenis'] == '1' ? item['nilai_stbp'] ?? '0' : item['nilai_sts'] ?? '0'))}'),
                            leading: Icon(
                              item['status_aklap'] == 0
                                  ? Icons.hourglass_empty
                                  : item['status_aklap'] == 4
                                      ? Icons.cancel
                                      : Icons.price_check,
                            ),
                            //trailing: const Icon(Icons.bolt),
                            trailing: Obx(() {
                              if (controller.jenisStatus.value != 5) {
                                return Checkbox(
                                  value: controller.checkboxStatus[index],
                                  // set shape lebih bulat
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  onChanged: (bool? value) {
                                    controller.updateCheckboxStatus(
                                        index,
                                        value!,
                                        item['id_stbp'] ?? item['id_sts']);
                                  },
                                );
                              } else {
                                return const SizedBox
                                    .shrink(); // Return an empty widget if condition is not met
                              }
                            }),
                            onTap: () {
                              // show sub listview to display detail
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'NoJurnal:\n${item['nomor_jurnal']}\n\nDengan Rincian:',
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
                                                TextSpan(
                                                  text: item['jenis'] == '1'
                                                      ? 'Jenis:'
                                                      : 'Bank Tujuan: ',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text: item['jenis'] == '1'
                                                        ? 'STBP'
                                                        : '(${item['no_rekening']}) - ${item['nama_rekening']}'),
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
                                                TextSpan(
                                                  text:
                                                      'Nilai\n${item['jenis'] == '1' ? 'Penerimaan' : 'Setoran'}:',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text: controller.formatCurrency(
                                                        double.parse(item[
                                                                    'jenis'] ==
                                                                '1'
                                                            ? item['nilai_stbp']
                                                            : item[
                                                                'nilai_sts']))),
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
                                                  text: 'Tanggal\nPembuatan: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text: formatter.format(
                                                        DateTime.parse(item[
                                                                    'jenis'] ==
                                                                '1'
                                                            ? item[
                                                                'tanggal_stbp']
                                                            : item[
                                                                'tanggal_sts']))),
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
                                                        '\n${item['keterangan_stbp']}\n\n'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text('Lihat Jurnal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Tutup'),
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
      ),
    );
  }
}
