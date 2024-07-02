import 'package:get/get.dart';
import 'package:bafia/models/user_model.dart';
import 'package:bafia/services/auth_service.dart';
import 'package:bafia/services/db_helper.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();
  final DBHelper _dbHelper = DBHelper();
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      var localUser = await _dbHelper.getUser();
      if (localUser != null) {
        user.value = localUser;
      } else {
        var fetchedUser = await _authService.getUserProfile();
        user.value = fetchedUser;
        await _dbHelper.insertUser(fetchedUser.toJson());
      }
    } catch (e) {
      // Handle fetch error
      print('Failed to fetch user profile: $e');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }
}
