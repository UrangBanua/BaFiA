import 'package:get/get.dart';
import 'auth_controller.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[DashboardController] onInit');
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      print('[DashboardController] fetchDashboardData');
      isLoading(true);
      var db = await LocalStorageService.database;
      var refreshToken = await Get.find<AuthController>().refreshToken;
      print('[DashboardController] Database fetched with token: $refreshToken');
      await ApiService.syncDashboardToLocalDB(db, refreshToken);
      print('[DashboardController] Dashboard synced to local DB');
      var data = await db.query('dashboard');
      print('[DashboardController] Dashboard data fetched');
      dashboardData.assignAll(data);
      print('[DashboardController] Dashboard data assigned');
    } catch (e) {
      print('[DashboardController] Error: $e');
      hasError(true);
    } finally {
      isLoading(false);
      print('[DashboardController] isLoading set to false');
    }
  }
}
