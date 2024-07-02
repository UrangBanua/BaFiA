import 'package:get/get.dart';
import 'package:baFia/models/item_model.dart';
import 'package:baFia/services/api_service.dart';

class ItemController extends GetxController {
  final ApiService _apiService = ApiService();
  var items = <Item>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      var fetchedItems = await _apiService.fetchItems();
      items.value = fetchedItems;
    } catch (e) {
      // Handle fetch error
    }
  }
}
