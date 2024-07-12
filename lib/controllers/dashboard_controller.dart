import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  var userData = {}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _checkUserData();
    LoggerService.logger.i('[DashboardController] onInit');
    await fetchDashboardData();
  }

  Future<void> _checkUserData() async {
    try {
      var dataU = await LocalStorageService.getUserData();
      if (dataU != null) {
        userData.value = dataU;
      }
    } catch (e) {
      LoggerService.logger.e('Error getting user data: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      LoggerService.logger.i('[DashboardController] fetchDashboardData');
      isLoading(true);
      var db = await LocalStorageService.database;
      var refreshToken = userData['refresh_token'];
      LoggerService.logger.i(
          '[DashboardController] Database fetched with token: $refreshToken');
      await ApiService.syncDashboardToLocalDB(db, refreshToken);
      LoggerService.logger
          .i('[DashboardController] Dashboard synced to local DB');
      var data = await db.query('dashboard');
      LoggerService.logger.i('[DashboardController] Dashboard data fetched');
      dashboardData.assignAll(data);
      LoggerService.logger.i('[DashboardController] Dashboard data assigned');
    } catch (e) {
      LoggerService.logger.e('Error fetching dashboard data: $e');
      hasError(true);
      Get.snackbar('Error', 'Connection problem, data loaded from local DB');
    } finally {
      isLoading(false);
      LoggerService.logger.i('[DashboardController] isLoading set to false');
    }
  }
}
