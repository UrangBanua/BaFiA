import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../auth_controller.dart';
import '../../services/logger_service.dart'; // Import LoggerService

class DokumenKendaliController extends GetxController {
  var kendaliSkpd = [].obs;
  var kendaliUrusan = [].obs;
  var kendaliProgram = [].obs;
  var kendaliKegiatan = [].obs;
  var kendaliSubKegiatan = [].obs;
  var kendaliRekening = [].obs;

  // set var userData from get autenticator controller
  var refreshToken = Get.find<AuthController>().userData['refresh_token'];
  var idSkpd = Get.find<AuthController>().userData['id_skpd'];

  // Fetch kendali SKPD data
  void fetchKendaliSkpd() async {
    var token = refreshToken;
    var kSkpd = idSkpd;
    LoggerService.logger.i('Fetching kendali SKPD data for idSkpd: $kSkpd');
    var data = await ApiService.getKendaliSkpd(kSkpd, token);
    kendaliSkpd.value = data;
  }

  // Fetch kendali Urusan data
  void fetchKendaliUrusan(int idSkpd, int idSubSkpd) async {
    LoggerService.logger.i(
        'Fetching kendali Urusan data for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd');
    var token = refreshToken;
    var data = await ApiService.getKendaliUrusan(idSkpd, idSubSkpd, token);
    kendaliUrusan.value = data;
  }

  // Fetch kendali Program data
  void fetchKendaliProgram(
      int idSkpd, int idSubSkpd, int idBidangUrusan) async {
    LoggerService.logger.i(
        'Fetching kendali Program data for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan');
    var token = refreshToken;
    var data = await ApiService.getKendaliProgram(
        idSkpd, idSubSkpd, idBidangUrusan, token);
    kendaliProgram.value = data;
  }

  // Fetch kendali Kegiatan data
  void fetchKendaliKegiatan(
      int idSkpd, int idSubSkpd, int idBidangUrusan, int idProgram) async {
    LoggerService.logger.i(
        'Fetching kendali Kegiatan data for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram');
    var token = refreshToken;
    var data = await ApiService.getKendaliKegiatan(
        idSkpd, idSubSkpd, idBidangUrusan, idProgram, token);
    kendaliKegiatan.value = data;
  }

  // Fetch kendali Sub Kegiatan data
  void fetchKendaliSubKegiatan(int idSkpd, int idSubSkpd, int idBidangUrusan,
      int idProgram, int idGiat) async {
    LoggerService.logger.i(
        'Fetching kendali Sub Kegiatan data for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat');
    var token = refreshToken;
    var data = await ApiService.getKendaliSubKegiatan(
        idSkpd, idSubSkpd, idBidangUrusan, idProgram, idGiat, token);
    kendaliSubKegiatan.value = data;
  }

  // Fetch kendali Rekening data
  void fetchKendaliRekening(int idSkpd, int idSubSkpd, int idBidangUrusan,
      int idProgram, int idGiat, int idSubGiat) async {
    LoggerService.logger.i(
        'Fetching kendali Rekening data for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat, idSubGiat: $idSubGiat');
    var token = refreshToken;
    var data = await ApiService.getKendaliRekening(
        idSkpd, idSubSkpd, idBidangUrusan, idProgram, idGiat, idSubGiat, token);
    kendaliRekening.value = data;
  }

  String formatCurrency(double value, BuildContext context) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    ).format(value);
  }
}
