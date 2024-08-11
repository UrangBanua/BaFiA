import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';
import 'auth_controller.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  //var userData = {}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var showGauge = false.obs;
  var catatanPengajuan = '';
  var dnotifications = <Map<String, dynamic>>[].obs;
  var isDemo = Get.find<AuthController>().isDemo.value;

  final AuthController authController = Get.put(AuthController());

  @override
  void onInit() async {
    super.onInit();
    LoggerService.logger.i('[DashboardController] onInit');

    //await fetchDashboardData();
    await _loadReadNotifications();
  }

  String formatCurrency(double value, BuildContext context) {
    return NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    ).format(value);
  }

  String formatDate(String date) {
    return DateFormat('dd MMMM y', 'id').format(DateTime.parse(date));
  }

  Future<void> fetchDashboardData() async {
    try {
      LoggerService.logger.i('[DashboardController] fetchDashboardData');
      isLoading(true);
      var db = await LocalStorageService.database;
      var refreshToken = authController.userData['refresh_token'];
      LoggerService.logger.i(
          '[DashboardController] Database fetched with token: $refreshToken');
      await ApiService.syncDashboardToLocalDB(db, refreshToken, isDemo);
      LoggerService.logger
          .i('[DashboardController] Dashboard synced to local DB');
      var data = await db.query('dashboard');
      LoggerService.logger.i('[DashboardController] Dashboard data fetched');
      dashboardData.assignAll(data);
      LoggerService.logger.i('[DashboardController] Dashboard data assigned');
      updateCatatanPengajuan();
      // Load notifications unread from local storage
      //await _loadReadNotifications();
    } catch (e) {
      LoggerService.logger.e('Error fetching dashboard data: $e');
      hasError(true);
      Get.snackbar(
          'Info', 'singkron data service gagal - gunakan data lokal terakhir');
    } finally {
      isLoading(false);
      LoggerService.logger.i('[DashboardController] isLoading set to false');
    }
  }

  void updateCatatanPengajuan() {
    if (dashboardData.isNotEmpty) {
      var realisasiRencanaB = dashboardData[0]['realisasi_rencana_b'] ?? 0;
      var realisasiRillB = dashboardData[0]['realisasi_rill_b'] ?? 0;
      if ((realisasiRencanaB - realisasiRillB) > 0) {
        catatanPengajuan =
            'Cek Kendali untuk memastikan pengajuan realisasi tidak terkendala dalam proses atau hanya lupa dihapus/dibatalkan,\n nilai ini juga termasuk dari jumlah pengembalian belanja';
      } else {
        catatanPengajuan = 'Rencana anda sama dengan Realisai';
      }
    }
  }

  // Load notifications unread from local storage
  Future<void> _loadReadNotifications() async {
    var loadedNotifications = List<Map<String, dynamic>>.from(
        await LocalStorageService.getUnreadMessages());
    dnotifications.assignAll(loadedNotifications);
    LoggerService.logger.i('Get Unread Messages');
  }
}
