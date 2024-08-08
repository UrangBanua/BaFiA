import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../auth_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/logger_service.dart';

class RBTbpGUController extends GetxController {
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();
  final RxString jenisKriteria = 'semua'.obs;
  final RxString jenisSP2D = '*'.obs;
  final Rx<Uint8List> filePdf = Uint8List(0).obs;
  // set variabel responData
  RxList<Map<String, dynamic>> responOutput = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; // Add loading state
  RxList<Map<String, dynamic>> filteredDetails =
      <Map<String, dynamic>>[].obs; // Add filteredDetails

// set var userData from get autenticator controller
  var refreshToken = Get.find<AuthController>().userData['refresh_token'];
  var idSkpd = Get.find<AuthController>().userData['id_skpd'];

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    tanggalMulaiController.text = "${now.year}-01-01";
    tanggalSampaiController.text = "${now.year}-${now.month}-${now.day}";
  }

  // Fungsi filterDetails untuk menampilkan detail SP2D berdasarkan jenis SP2D
  void filterDetails() {
    RxList<Map<String, dynamic>> detailFilter;
    if (jenisSP2D.value == '*') {
      detailFilter =
          RxList<Map<String, dynamic>>.from(responOutput[0]['detail']);
    } else {
      detailFilter = RxList<Map<String, dynamic>>.from(responOutput[0]['detail']
          .where((item) => item['jenis'] == jenisSP2D.value)
          .toList());
    }
    filteredDetails.value = detailFilter;
    /* responOutput.value = [
      {'detail': detailFilter}
    ]; // Update responOutput with filtered details */
  }

  // Fungsi previewReport untuk menampilkan data SP2D
  void previewReport() async {
    isLoading.value = true; // Set loading state to true
    const jenisDokumen = 'tbp';
    final tanggalMulai = tanggalMulaiController.text;
    final tanggalSampai = tanggalSampaiController.text;
    const jenisRegister = 'transaksi';
    var responData = await ApiService.postRegisterTuTbpSppSpmSp2d(
      jenisDokumen,
      tanggalMulai,
      tanggalSampai,
      jenisRegister,
      idSkpd,
      jenisKriteria.value,
      refreshToken,
    );
    responOutput.value = [responData ?? {}];
    if (kDebugMode) {
      print('Preview Respon: $responData');
    }
    update(); // Update the state
    isLoading.value = false; // Set loading state to false
  }

  // Fungsi printPdf untuk mencetak PDF
  Future<void> printPdf() async {
    try {
      if (filePdf.value.isNotEmpty) {
        LoggerService.logger.i('Printing PDF'); // Add logging statement
        Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => filePdf.value,
        );
      } else {
        Get.snackbar('Error',
            'Error printing PDF: File is empty'); // Show snackbar with title and message
        LoggerService.logger
            .e('Error printing PDF: File is empty'); // Log the error
      }
    } catch (e) {
      LoggerService.logger.e('Error printing PDF: $e'); // Log the error
    }
  }

  // Fungsi formatCurrency untuk menampilkan format mata uang
  String formatCurrency(double value, BuildContext context) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    ).format(value);
  }
}
