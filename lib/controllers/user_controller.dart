import 'package:bafia/controllers/auth_controller.dart';
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

  void updateProfilePhotoAndReplaceDefault(String imagePath) {
    // Implement logic to update the profile photo and replace the default image
    // For example, you can save the new image path to user data
  }

  Future<void> saveTheme(bool isDarkMode) async {
    final db = await LocalStorageService.database;
    await db.update(
      'User',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userData['id']],
    );
  }

  Future<bool> getTheme() async {
    final db = await LocalStorageService.database;
    final user =
        await db.query('User', where: 'id = ?', whereArgs: [userData['id']]);
    if (user.isNotEmpty) {
      return user.first['isDarkMode'] == 1;
    }
    return false; // Default to light mode
  }
}
