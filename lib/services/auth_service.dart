import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baFia/models/user_model.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'https://api.example.com/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Assume the response contains a token
        final token = response.data['token'];
        await _saveToken(token);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> getUserProfile() async {
    try {
      // Ganti URL dengan endpoint yang sesuai untuk mengambil profil pengguna
      Response response =
          await _dio.get('https://api.example.com/user/profile');
      return User.fromJson(response.data); // Ubah sesuai dengan respons API
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
