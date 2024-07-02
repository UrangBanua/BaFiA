import 'package:get/get.dart';
import 'package:bafia/models/item_model.dart';
import 'package:bafia/services/api_service.dart';
import 'package:bafia/services/db_helper.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();
  final DBHelper _dbHelper = DBHelper();
  var items = <Item>[].obs;
  var isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkStatus();
    fetchItems();
  }

  Future<void> checkStatus() async {
    int status = await _dbHelper.getStatus();
    isOnline.value = status == 1;
  }

  Future<void> fetchItems() async {
    if (isOnline.value) {
      try {
        var fetchedItems = await _apiService.fetchItems();
        items.value = fetchedItems;
        await _dbHelper.db.then((db) => db.delete('items'));
        for (var item in fetchedItems) {
          await _dbHelper.insertItem(item.toJson());
        }
      } catch (e) {
        // Handle fetch error
      }
    } else {
      var localItems = await _dbHelper.fetchItems();
      items.value = localItems.map((item) => Item.fromJson(item)).toList();
    }
  }

  void synchronize() async {
    if (isOnline.value) {
      await fetchItems();
    }
  }
}
