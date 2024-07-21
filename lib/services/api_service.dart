import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';
import 'local_storage_service.dart';
import 'logger_service.dart';

class ApiService {
  static final client = http.Client();
  static final bool isDevelopmentMode = dotenv.env['DEVELOPMENT_MODE'] == 'ON';
  static final String apiServiceUrl = isDevelopmentMode
      ? dotenv.env['API_SERVICE_FAKE'] ?? ''
      : dotenv.env['API_SERVICE_URL'] ?? '';
  static final String? fakeXApiKey = dotenv.env['FAKE_X_API_KEY'];

  static void checkDevelopmentModeWarning() {
    if (isDevelopmentMode) {
      LoggerService.logger.w('DEVELOPMENT_MODE IS ON');
    }
  }

  static Future<Map<String, dynamic>?> login(
      String year, String username, String password, String captcha) async {
    LoggerService.logger.i('Attempting to login with username: $username');
    try {
      final pHeaders =
          isDevelopmentMode ? {'x-api-key': fakeXApiKey ?? ''} : {};
      final response = await client.post(
          Uri.parse('$apiServiceUrl/auth/auth/pre-login'),
          headers: pHeaders as Map<String, String>?,
          body: {
            'username': username,
            'password': password,
            'tahun': year
          }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerService.logger.i('Login successful for username: $username');
        final data = (json.decode(response.body) as List).first;
        return data;
      } else {
        LoggerService.logger.e(
            'Login failed for username: $username. Status code: ${response.statusCode}');
        Get.snackbar('Error', 'Login failed');
        throw Exception(
            'Login failed'); // Throw an exception instead of rethrowing
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Login request timeout for from service server');
        Get.snackbar('Timeout', 'Login request timeout');
        // Handle the TimeoutException accordingly
      } else {
        LoggerService.logger.e('Login request failed for from service server');
        Get.snackbar(
            'Failed', 'Login request failed'); // Handle other exceptions
      }
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserToken({
    required int idDaerah,
    required int idRole,
    required int idSkpd,
    required int idPegawai,
    required String password,
    required int year,
    required String username,
    required String captchaId,
    required String captchaSolution,
  }) async {
    LoggerService.logger.i('Attempting to get user token');
    try {
      final pHeaders = isDevelopmentMode
          ? {'x-api-key': fakeXApiKey ?? '', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};
      final response = await client
          .post(
            Uri.parse('$apiServiceUrl/auth/auth/login'),
            body: json.encode({
              'id_daerah': idDaerah,
              'id_role': idRole,
              'id_skpd': idSkpd,
              'id_pegawai': idPegawai,
              'password': password,
              'tahun': year,
              'username': username,
              'captcha_id': captchaId,
              'captcha_solution': captchaSolution,
              'remember_me': 'true'
            }),
            headers: pHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerService.logger.i('User token fetched successfully');
        return json.decode(response.body);
      } else {
        LoggerService.logger
            .e('Failed to get user token. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Login request timeout for from service server');
        Get.snackbar('Timeout', 'User token request timeout');
        // Handle the TimeoutException accordingly
      } else {
        LoggerService.logger.e('Login request failed for from service server');
        Get.snackbar(
            'Failed', 'User token request failed'); // Handle other exceptions
      }
    }
    return null;
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    LoggerService.logger.i('Attempting to sync dashboard data to local db');
    try {
      final pHeaders = isDevelopmentMode
          ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
          : {'Authorization': 'Bearer $token'};
      final response = await client
          .get(
            Uri.parse(
                '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja'),
            headers: pHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerService.logger
            .i('Dashboard data synced to local db successfully');
        await LocalStorageService.deleteDashboardData();
        await LocalStorageService.saveDashboardData(
            db, json.decode(response.body));
      } else {
        LoggerService.logger.e(
            'Failed to sync dashboard data to local db. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Login request timeout for from service server');
        Get.snackbar('Timeout', 'Sync dashboard to local db');
        // Handle the TimeoutException accordingly
      } else {
        LoggerService.logger.e('Login request failed for from service server');
        Get.snackbar(
            'Failed', 'Sync dashboard to local db'); // Handle other exceptions
      }
    }
  }

  static Future<Map<String, dynamic>?> getCaptchaImage() async {
    LoggerService.logger.i('Attempting to get captcha image');
    try {
      final pHeaders = isDevelopmentMode
          ? {'x-api-key': fakeXApiKey ?? '', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};
      final response = await client
          .get(
            Uri.parse('$apiServiceUrl/auth/captcha/new'),
            headers: pHeaders,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        LoggerService.logger.i('Captcha image fetched successfully');
        return json.decode(response.body);
      } else {
        LoggerService.logger.e(
            'Failed to get captcha image. Status code: ${response.statusCode}');
        throw Exception('Failed to get captcha image');
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Login request timeout for from service server');
        Get.snackbar('Error', 'Load captcha image request timeout');
        // Handle the TimeoutException accordingly
      } else {
        LoggerService.logger.e('Login request failed for from service server');
        Get.snackbar('Error',
            'Load captcha image request failed'); // Handle other exceptions
      }
    }
    return null;
  }
}
