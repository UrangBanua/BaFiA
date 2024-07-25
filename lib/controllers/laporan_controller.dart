import 'package:get/get.dart';

class LaporanController extends GetxController {
  var searchResult = ''.obs;

  void searchByName(String name) {
    // Implement your search logic here
    // For demonstration, let's assume we just set the search result to the name
    searchResult.value = name;
  }
}
