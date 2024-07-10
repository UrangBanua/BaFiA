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

  Future<void> updateProfilePhotoAndReplaceDefault(String imageHash) async {
    print(imageHash);

    // Save the updated user data to local storage
  }

  Future<void> saveTheme(id_user, bool isDarkMode) async {
    final db = await LocalStorageService.database;
    print('user_id update:' + id_user.toString());
    await db.update(
      'User',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id_user = ?',
      whereArgs: [id_user],
    );
  }

  Future<bool> getTheme() async {
    final db = await LocalStorageService.database;
    final user = await db
        .query('User', where: 'id_user = ?', whereArgs: [userData['id_user']]);
    if (user.isNotEmpty) {
      return user.first['isDarkMode'] == 1;
    }
    return false; // Default to light mode
  }
}
