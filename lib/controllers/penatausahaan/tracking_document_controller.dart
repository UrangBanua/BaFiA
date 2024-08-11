import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../auth_controller.dart';
import '../../services/api_service.dart';
import '../../services/logger_service.dart';

class RBTrackingDocumentController extends GetxController {
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();
  final RxInt pageNo = 1.obs;
  final RxInt pagePrev = 0.obs;
  final RxInt pageNext = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxString jenisSP2D = '*'.obs;
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
    tanggalMulaiController.text =
        formatter.format(DateTime(now.year, now.month, 1));
    tanggalSampaiController.text =
        formatter.format(DateTime(now.year, now.month, now.day));
  }

  // Fungsi filterDetails untuk menampilkan detail TBP berdasarkan jenis TBP
  void filterDetails() {
    RxList<Map<String, dynamic>> detailFilter;
    if (jenisSP2D.value == '*') {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput[0]['body']);
    } else {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput[0]['body']
          .where((item) => item['jenis_spp'] == jenisSP2D.value)
          .toList());
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      detailFilter = RxList<Map<String, dynamic>>.from(detailFilter
          .where((item) =>
              item['nomor_spp']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['nomor_spm']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['nomor_sp2d']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              item['spp_skpd']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList());
    }

    filteredDetails.value = detailFilter;
  }

  // Fungsi previewReport untuk menampilkan data SP2D
  void previewReport(int setPage) async {
    isLoading.value = true;
    final tanggalMulai = tanggalMulaiController.text;
    final tanggalSampai = tanggalSampaiController.text;
    var responData = await ApiService.postTrackingDocument(
        setPage, tanggalMulai, tanggalSampai, idSkpd, refreshToken, isDemo);
    responOutput.value = [responData ?? {}];

    if (responData != null && responData.containsKey('headers')) {
      totalPages.value =
          int.parse(responData['headers']['x-pagination-page-count']);
      pagePrev.value =
          responData['headers']['x-pagination-previous-page'] != null
              ? int.parse(responData['headers']['x-pagination-previous-page'])
              : 0;
      pageNext.value = responData['headers']['x-pagination-next-page'] != null
          ? int.parse(responData['headers']['x-pagination-next-page'])
          : 0;
      LoggerService.logger.i('Total Pages: ${totalPages.value}');
    }
    LoggerService.logger.i('Preview Respon: $responData');
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
                  'Tracking Document - ${jenisSP2D.value == '*' ? 'Semua' : jenisSP2D.value}\n Periode: ${tanggalMulaiController.text} s/d ${tanggalSampaiController.text}',
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
