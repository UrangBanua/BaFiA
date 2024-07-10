import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';
import 'local_storage_service.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('ApiService');

class ApiService {
  static final client = http.Client();

  static Future<Map<String, dynamic>?> login(
      String year, String username, String password, String captcha) async {
    _logger.info('Attempting to login with username: $username');
    final response = await client.post(
        Uri.parse('https://service.sipd.kemendagri.go.id/auth/auth/pre-login'),
        body: {
          'username': username,
          'password': password,
          'tahun': year
        }).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      _logger.info('Login successful for username: $username');
      final data = (json.decode(response.body) as List).first;
      return data;
    } else {
      _logger.severe(
          'Login failed for username: $username. Status code: ${response.statusCode}');
      return null;
    }
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
    _logger.info('Attempting to get user token');
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
      _logger.info('User token fetched successfully');
      return json.decode(response.body);
    } else {
      _logger.severe(
          'Failed to get user token. Status code: ${response.statusCode}');
      return null;
    }
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    _logger.info('Attempting to sync dashboard data to local db');
    final response = await client.get(
      Uri.parse(
          'https://service.sipd.kemendagri.go.id/pengeluaran/strict/dashboard/statistik-belanja'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      _logger.info('Dashboard data synced to local db successfully');
      await LocalStorageService.deleteDashboardData();
      await LocalStorageService.saveDashboardData(
          db, json.decode(response.body));
    } else {
      _logger.severe(
          'Failed to sync dashboard data to local db. Status code: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> getCaptchaImage() async {
    _logger.info('Attempting to get captcha image');
    final response = await client.get(
      Uri.parse('https://service.sipd.kemendagri.go.id/auth/captcha/new'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      _logger.info('Captcha image fetched successfully');
      return json.decode(response.body);
    } else {
      _logger.severe(
          'Failed to get captcha image. Status code: ${response.statusCode}');
      throw Exception('Failed to get captcha image');
    }
  }
}
