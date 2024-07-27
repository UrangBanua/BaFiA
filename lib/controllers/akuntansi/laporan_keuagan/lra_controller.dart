import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../dashboard_controller.dart';
import '../../../services/api_service.dart';

class LKLraController extends GetxController {
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSampaiController = TextEditingController();
  final RxInt klasifikasi = RxInt(5);
  final RxString konsolidasiSKPD = RxString('skpd_unit');
  final Rx<Uint8List> filePdf = Uint8List(0).obs;
  final RxBool isLoading = false.obs; // Add loading state

  // set var userData from get dashboard controller
  var refreshToken = Get.find<DashboardController>().userData['refresh_token'];
  var idSkpd = Get.find<DashboardController>().userData['id_skpd'];

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    tanggalMulaiController.text = "${now.year}-01-01";
    tanggalSampaiController.text = "${now.year}-${now.month}-${now.day}";
  }

  void previewReport() async {
    isLoading.value = true; // Set loading state to true
    final tanggalMulai = tanggalMulaiController.text;
    final tanggalSampai = tanggalSampaiController.text;
    final responData = await ApiService.getLraReport(
      tanggalMulai,
      tanggalSampai,
      klasifikasi.value,
      konsolidasiSKPD.value,
      idSkpd,
      refreshToken,
    );
    filePdf.value = responData;
    isLoading.value = false; // Set loading state to false
  }
}
