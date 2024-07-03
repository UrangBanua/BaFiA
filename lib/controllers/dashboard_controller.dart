import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class DashboardController extends GetxController {
  var dashboardData = [].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      var db = await LocalStorageService.database;
      await ApiService.syncDataToLocalDB(db);
      var data = await db.query('dashboard');
      dashboardData.assignAll(data);
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
