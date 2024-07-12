import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import 'package:logging/logging.dart';

final _logger = Logger('UserController');

class UserController extends GetxController {
  var userData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    _logger.info('Fetching user data...');
    var data = await LocalStorageService.getUserData();
    if (data != null) {
      _logger.info('User data fetched: $data');
      userData.value = data;
    } else {
      _logger.info('No user data found.');
    }
  }

  String maskString(String input) {
    if (input.length <= 3) return input;
    return input.substring(0, 3) + '*' * (input.length - 3);
  }

  Future<void> updateProfilePhotoAndReplaceDefault(String imageHash) async {
    _logger.info('Image hash: $imageHash');

    // Save the updated user data to local storage
  }

  Future<void> saveTheme(int idUser, bool isDarkMode) async {
    final db = await LocalStorageService.database;
    _logger
        .info('Updating user theme. User ID: $idUser, Dark Mode: $isDarkMode');
    await db.update(
      'User',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id_user = ?',
      whereArgs: [idUser],
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
