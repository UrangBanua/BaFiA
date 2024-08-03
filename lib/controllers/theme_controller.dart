import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class ThemeController extends GetxController {
  final isDarkMode = false.obs;
  final isUserData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme(0);
  }

  void toggleTheme(int idUser) {
    isDarkMode.value = !isDarkMode.value;
    saveTheme(idUser, isDarkMode.value);
  }

  Future<void> saveTheme(int idUser, bool isDarkMode) async {
    final db = await LocalStorageService.database;
    LoggerService.logger
        .i('Updating user theme. User ID: $idUser, Dark Mode: $isDarkMode');
    await db.update(
      'User',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id_user = ?',
      whereArgs: [idUser],
    );
  }

  Future<void> loadTheme(darkMode) async {
    if (darkMode == 1) {
      //set isUserData to true
      isUserData.value = true;
      isDarkMode.value = true;
    } else {
      //set isUserData to false
      isUserData.value = false;
      isDarkMode.value = false;
    }
  }
}
