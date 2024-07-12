import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';
import 'local_storage_service.dart';
import 'logger_service.dart';

class ApiService {
  static final client = http.Client();

  static Future<Map<String, dynamic>?> login(
      String year, String username, String password, String captcha) async {
    LoggerService.logger.i('Attempting to login with username: $username');
    try {
      final response = await client.post(
          Uri.parse(
              'https://service.sipd.kemendagri.go.id/auth/auth/pre-login'),
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
        Get.snackbar('Error', 'Login request timeout');
        // Handle the TimeoutException accordingly
      } else {
        // Handle other exceptions
        rethrow; // Rethrow the exception if it's not a TimeoutException
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
      final response = await client.post(
        Uri.parse('https://service.sipd.kemendagri.go.id/auth/auth/login'),
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
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

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
        Get.snackbar('Error', 'User token request timeout');
        // Handle the TimeoutException accordingly
      } else {
        // Handle other exceptions
        rethrow; // Rethrow the exception if it's not a TimeoutException
      }
    }
    return null;
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    LoggerService.logger.i('Attempting to sync dashboard data to local db');
    try {
      final response = await client.get(
        Uri.parse(
            'https://service.sipd.kemendagri.go.id/pengeluaran/strict/dashboard/statistik-belanja'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

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
        Get.snackbar('Error', 'Sync dashboard request timeout');
        // Handle the TimeoutException accordingly
      } else {
        // Handle other exceptions
        rethrow; // Rethrow the exception if it's not a TimeoutException
      }
    }
  }

  static Future<Map<String, dynamic>?> getCaptchaImage() async {
    LoggerService.logger.i('Attempting to get captcha image');
    try {
      final response = await client.get(
        Uri.parse('https://service.sipd.kemendagri.go.id/auth/captcha/new'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

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
        // Handle other exceptions
        rethrow; // Rethrow the exception if it's not a TimeoutException
      }
    }
    return null;
  }
}
