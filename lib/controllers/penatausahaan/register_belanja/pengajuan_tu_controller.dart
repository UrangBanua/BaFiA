import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../auth_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/logger_service.dart';

class RBPengajuanTuController extends GetxController {
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();
  final RxString jenisKriteria = 'semua'.obs;
  final Rx<Uint8List> filePdf = Uint8List(0).obs;
  // set variabel responData
  RxList<Map<String, dynamic>> responOutput = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs; // Add loading state

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

  void previewReport() async {
    isLoading.value = true; // Set loading state to true
    const jenisDokumen = 'pengajuan-tu';
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
    LoggerService.logger.i('Preview Respon: $responData');
    update(); // Update the state
    isLoading.value = false; // Set loading state to false
  }

  // Add printPdf function
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

  String formatCurrency(double value, BuildContext context) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    ).format(value);
  }
}
