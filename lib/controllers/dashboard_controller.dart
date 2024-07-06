import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  var userData = {}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _checkUserData();
    print('[DashboardController] onInit');
    await fetchDashboardData();
  }

  Future<void> _checkUserData() async {
    var dataU = await LocalStorageService.getUserData();
    if (dataU != null) {
      userData.value = dataU;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      print('[DashboardController] fetchDashboardData');
      isLoading(true);
      var db = await LocalStorageService.database;
      var refreshToken = userData['refresh_token'];
      //print('[DashboardController] Database fetched with token: $refreshToken');
      await ApiService.syncDashboardToLocalDB(db, refreshToken);
      print('[DashboardController] Dashboard synced to local DB');
      var data = await db.query('dashboard');
      print('[DashboardController] Dashboard data fetched');
      dashboardData.assignAll(data);
      print('[DashboardController] Dashboard data assigned');
    } catch (e) {
      print('[DashboardController] Error: $e');
      hasError(true);
      //var db = await LocalStorageService.database;
      //var data = await db.query('dashboard');
      //print('[DashboardController] Dashboard data loaded from local DB');
      //dashboardData.assignAll(data);
      //print('[DashboardController] Dashboard data local DB assigned');
      Get.snackbar('Error', 'Connection problem, data loaded from local DB');
    } finally {
      isLoading(false);
      print('[DashboardController] isLoading set to false');
    }
  }
}
