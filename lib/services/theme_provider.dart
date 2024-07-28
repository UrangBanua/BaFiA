import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void loadTheme(isDarkMode) {
    //UserController userController = UserController();
    _isDarkMode = isDarkMode == 1;
    notifyListeners();
  }

  void toggleTheme(idUser) {
    _isDarkMode = !_isDarkMode;
    UserController userController = UserController();
    userController.saveTheme(idUser, _isDarkMode);
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}
