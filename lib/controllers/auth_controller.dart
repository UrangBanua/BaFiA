import 'package:get/get.dart';
import 'package:bafia/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      isLoggedIn.value = true;
      // Navigate to dashboard or other page
      Get.offAllNamed('/dashboard');
    } catch (e) {
      // Handle login error
      Get.snackbar('Error', 'Failed to login: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    isLoggedIn.value = await _authService.isLoggedIn();
    if (isLoggedIn.value) {
      // Navigate to dashboard or other page
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn.value = false;
    // Navigate to login page
    Get.offAllNamed('/login');
  }
}
