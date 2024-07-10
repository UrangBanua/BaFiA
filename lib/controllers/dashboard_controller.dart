import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:logging/logging.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  var userData = {}.obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  final Logger _logger = Logger('DashboardController');

  @override
  void onInit() async {
    super.onInit();
    await _checkUserData();
    _logger.fine('[DashboardController] onInit');
    await fetchDashboardData();
  }

  Future<void> _checkUserData() async {
    try {
      var dataU = await LocalStorageService.getUserData();
      if (dataU != null) {
        userData.value = dataU;
      }
    } catch (e) {
      _logger.severe('Error getting user data: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      _logger.fine('[DashboardController] fetchDashboardData');
      isLoading(true);
      var db = await LocalStorageService.database;
      var refreshToken = userData['refresh_token'];
      _logger.fine(
          '[DashboardController] Database fetched with token: $refreshToken');
      await ApiService.syncDashboardToLocalDB(db, refreshToken);
      _logger.fine('[DashboardController] Dashboard synced to local DB');
      var data = await db.query('dashboard');
      _logger.fine('[DashboardController] Dashboard data fetched');
      dashboardData.assignAll(data);
      _logger.fine('[DashboardController] Dashboard data assigned');
    } catch (e) {
      _logger.severe('Error fetching dashboard data: $e');
      hasError(true);
      Get.snackbar('Error', 'Connection problem, data loaded from local DB');
    } finally {
      isLoading(false);
      _logger.fine('[DashboardController] isLoading set to false');
    }
  }
}
