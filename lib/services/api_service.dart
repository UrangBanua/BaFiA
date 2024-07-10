import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqlite_api.dart';
import 'local_storage_service.dart';

class ApiService {
  static final client = http.Client();

  static Future<Map<String, dynamic>?> login(
      String year, String username, String password) async {
    final response = await client.post(
        Uri.parse('https://service.sipd.kemendagri.go.id/auth/auth/pre-login'),
        body: {
          'username': username,
          'password': password,
          'tahun': year
        }).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = (json.decode(response.body) as List).first;
      return data;
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
  }) async {
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
      }),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return null;
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    final response = await client.get(
      Uri.parse(
          'https://service.sipd.kemendagri.go.id/pengeluaran/strict/dashboard/statistik-belanja'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      await LocalStorageService.deleteDashboardData();
      await LocalStorageService.saveDashboardData(
          db, json.decode(response.body));
    }
  }
}
