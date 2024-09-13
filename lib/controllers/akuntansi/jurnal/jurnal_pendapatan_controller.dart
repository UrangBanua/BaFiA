import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../auth_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/logger_service.dart';

class JRPendapatanController extends GetxController {
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();

  final RxInt jenisStatus = 5.obs;
  final RxInt jenisJurnal = 1.obs;

  final RxList selectedIds = [].obs;
  final RxList<bool> checkboxStatus = <bool>[].obs;

  final Rx<Uint8List> filePdf = Uint8List(0).obs;

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  // set variabel responData
  RxList<Map<String, dynamic>> responOutput = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; // Add loading state
  RxList<Map<String, dynamic>> filteredDetails =
      <Map<String, dynamic>>[].obs; // Add filteredDetails
  final searchQuery = ''.obs; // Add search query variable
  final TextEditingController searchQueryController = TextEditingController();

// set var userData from get autenticator controller
  var refreshToken = Get.find<AuthController>().userData['refresh_token'];
  var idSkpd = Get.find<AuthController>().userData['id_skpd'];
  var isDemo = Get.find<AuthController>().isDemo.value;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    tanggalMulaiController.text = "${now.year}-01-01";
    tanggalSampaiController.text = "${now.year}-${now.month}-${now.day}";
  }

  // Fungsi updateCheckboxStatus untuk mengupdate status checkbox
  void updateCheckboxStatus(int index, bool value, int id) {
    // set checkboxStatus[index] to value
    checkboxStatus[index] = value;
    // get value from item['id_stbp'] / item['id_sts'] to selectedIds
    if (value == true) {
      selectedIds.add(id);
    } else {
      selectedIds.remove(id);
    }
    LoggerService.logger.i(selectedIds);
  }

  // Fungsi filterDetails untuk menampilkan data Pendapatan berdasarkan jenis Pendapatan
  void filterDetails() {
    RxList<Map<String, dynamic>> detailFilter;
    if (jenisJurnal.value == 1 || jenisJurnal.value == 3) {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput[0]['data']);
    } else {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput[0]['data']
          .where((item) => item['jenis'] == jenisJurnal.value)
          .toList());
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      detailFilter = RxList<Map<String, dynamic>>.from(detailFilter
          .where((item) =>
              item['nomor_dokumen']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['keterangan']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList());
    }

    filteredDetails.value = detailFilter;
  }

  // Fungsi previewReport untuk menampilkan data Pendapatan
  void previewReport() async {
    isLoading.value = true; // Set loading state to true
    const jenisDokumen = 0;
    final tanggalMulai = tanggalMulaiController.text;
    final tanggalSampai = tanggalSampaiController.text;
    const filterKey = 'no_dokumen';
    var responData = await ApiService.postListJurnalPendapatan(
        jenisDokumen,
        jenisJurnal.value,
        jenisStatus.value,
        filterKey,
        searchQuery.value,
        idSkpd,
        1,
        1000,
        tanggalMulai,
        tanggalSampai,
        refreshToken,
        isDemo);
    responOutput.clear();
    responOutput.value = [responData ?? {}];
    // add checkbox status index based on the length of the data
    checkboxStatus.clear();
    for (var i = 0; i < responOutput[0]['data'].length; i++) {
      checkboxStatus.add(false);
    }
    selectedIds.clear();
    filterDetails();

    LoggerService.logger.i('Preview Respon: $responData');
    LoggerService.logger.i('Checkbox Data: $checkboxStatus');
    update(); // Update the state
    isLoading.value = false; // Set loading state to false
  }

  // Fungsi printPdf untuk mencetak PDF
  Future<void> printPdf(List<Map<String, dynamic>> dataToPdf) async {
    // Check if dataToPdf is null or contains null values
    if (dataToPdf.isEmpty) {
      Get.snackbar('Error', 'Error printing PDF: Data is null or invalid');
      LoggerService.logger.e('Error printing PDF: Data is null or invalid');
      return;
    }

    try {
      final pdf = pw.Document();

      // Add a title
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Register Pendapatan - ${jenisJurnal.value == 1 || jenisJurnal.value == 3 ? 'Semua' : jenisJurnal.value}\n Periode: ${tanggalMulaiController.text} s/d ${tanggalSampaiController.text}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(
                        500), // Custom width for 'nomor_dokumen'
                    1: const pw.FixedColumnWidth(
                        80), // Custom width for 'jenis'
                    2: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_bruto'
                    3: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_potongan'
                    4: const pw.FixedColumnWidth(
                        220), // Custom width for 'nilai_netto'
                    5: const pw.FixedColumnWidth(
                        200), // Custom width for 'tanggal_pembuatan'
                    6: const pw.FixedColumnWidth(
                        200), // Custom width for 'tanggal_pencairan'
                    7: const pw.FixedColumnWidth(
                        650), // Custom width for 'keterangan'
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        'nomor_dokumen',
                        'jenis',
                        'nilai_bruto',
                        'nilai_potongan',
                        'nilai_netto',
                        'tanggal_pembuatan',
                        'tanggal_pencairan',
                        'keterangan'
                      ].map((header) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                    ...dataToPdf.map((item) {
                      return pw.TableRow(
                        children: [
                          item['nomor_dokumen'].toString(),
                          item['jenis'].toString(),
                          formatCurrency(item['nilai_bruto'].toDouble()),
                          formatCurrency(item['nilai_potongan'].toDouble()),
                          formatCurrency(item['nilai_netto'].toDouble()),
                          formatter
                              .format(DateTime.parse(item['tanggal_pembuatan']))
                              .toString(),
                          formatter
                              .format(DateTime.parse(item['tanggal_pencairan']))
                              .toString(),
                          item['keterangan'].toString(),
                        ].map((value) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(value),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Convert the PDF document to bytes
      final pdfBytes = await pdf.save();

      // Print the PDF
      LoggerService.logger.i('Printing PDF'); // Add logging statement
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      LoggerService.logger.e('Error printing PDF: $e'); // Log the error
    }
  }

  // Fungsi formatCurrency untuk menampilkan format mata uang
  String formatCurrency(double value) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: 'id-ID',
    ).format(value);
  }
}
