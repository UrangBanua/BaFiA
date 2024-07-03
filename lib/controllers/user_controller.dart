import 'package:get/get.dart';
import '../services/local_storage_service.dart';

class UserController extends GetxController {
  var userData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print("Fetching user data...");
    var data = await LocalStorageService.getUserData();
    if (data != null) {
      print("User data fetched: $data");
      userData.value = data;
    } else {
      print("No user data found.");
    }
  }

  String maskString(String input) {
    if (input.length <= 3) return input;
    return input.substring(0, 3) + '*' * (input.length - 3);
  }
}
