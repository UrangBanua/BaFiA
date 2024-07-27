import 'dart:typed_data';

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
  static const int timeoutDuration = 10;
  static const int timeoutDurationReports = 60;

  static get getDateNow {
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";
    return formattedDate;
  }

  static void checkDevelopmentModeWarning() {
    if (isDevelopmentMode) {
      LoggerService.logger.w('DEVELOPMENT_MODE IS ON');
    } else {
      LoggerService.logger.i('API_SERVICE_URL : $apiServiceUrl');
    }
  }

  // fungsi post request with header
  static Future<http.Response> _postRequest(
      String url, Map<String, dynamic> body, Map<String, String> headers) {
    return client
        .post(
          Uri.parse(url),
          headers: headers,
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: timeoutDuration));
  }

  // fungsi get request
  static Future<http.Response> _getRequest(
      String url, Map<String, String> headers) {
    return client
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: timeoutDuration));
  }

  // fungsi get request reports
  static Future<http.Response> _getRequestReports(
      String url, Map<String, String> headers) {
    return client
        .get(
          Uri.parse(url),
          headers: headers,
        )
        .timeout(const Duration(seconds: timeoutDurationReports));
  }

  // fungsi handle error
  static void _handleError(http.Response response, String message) {
    LoggerService.logger.e('$message. Status code: ${response.statusCode}');
    Get.snackbar('Error', message);
  }

  // fungsi handle exception
  static void _handleException(Exception e, String message) {
    if (e is TimeoutException) {
      LoggerService.logger.e('$message: Request timeout');
      Get.snackbar('Timeout', '$message: Request timeout');
    } else {
      LoggerService.logger.e('$message: $e');
      Get.snackbar('Error', message);
    }
  }

  // rest api get captcha image
  static Future<Map<String, dynamic>?> getCaptchaImage() async {
    LoggerService.logger.i('Attempting to get captcha image');
    try {
      final response = await _getRequest(
        '$apiServiceUrl/auth/captcha/new',
        isDevelopmentMode
            ? {
                'x-api-key': fakeXApiKey ?? '',
                'Content-Type': 'application/json'
              }
            : {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        LoggerService.logger.i('Captcha image fetched successfully');
        return json.decode(response.body);
      } else {
        _handleError(response, 'Failed to get captcha image');
      }
    } catch (e) {
      _handleException(e as Exception, 'Captcha image request failed');
    }
    return null;
  }

  // rest api login
  static Future<Map<String, dynamic>?> login(
      String year, String username, String password, String captcha) async {
    LoggerService.logger.i('Attempting to login with username: $username');
    try {
      final pHeaders =
          isDevelopmentMode ? {'x-api-key': fakeXApiKey ?? ''} : {};
      final response = await client.post(
          Uri.parse('$apiServiceUrl/auth/auth/pre-login'),
          headers: isDevelopmentMode ? pHeaders as Map<String, String>? : null,
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
      final response = await _postRequest(
        '$apiServiceUrl/auth/auth/login',
        {
          'id_daerah': idDaerah,
          'id_role': idRole,
          'id_skpd': idSkpd,
          'id_pegawai': idPegawai,
          'password': password,
          'tahun': year,
          'username': username,
          'captcha_id': captchaId,
          'captcha_solution': captchaSolution,
          'remember_me': 'true',
        },
        isDevelopmentMode
            ? {
                'x-api-key': fakeXApiKey ?? '',
                'Content-Type': 'application/json'
              }
            : {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        LoggerService.logger.i('User token fetched successfully');
        return json.decode(response.body);
      } else {
        _handleError(response, 'Failed to get user token');
      }
    } catch (e) {
      _handleException(e as Exception, 'User token request failed');
    }
    return null;
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    LoggerService.logger.i('Attempting to sync dashboard data to local db');
    try {
      final pHeaders = isDevelopmentMode
          ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
          : {'Authorization': 'Bearer $token'};

      final responsePend = await _getRequest(
        '$apiServiceUrl/penerimaan/strict/dashboard/statistik-pendapatan',
        pHeaders,
      );

      final responseBela = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja',
        pHeaders,
      );

      if (responsePend.statusCode == 200 && responseBela.statusCode == 200) {
        LoggerService.logger
            .i('Dashboard data synced to local db successfully');
        await _mergeAndSaveDashboardData(db, responsePend, responseBela);
      } else {
        LoggerService.logger.e('Failed to sync dashboard data to local db');
      }
    } catch (e) {
      _handleException(e as Exception, 'Sync dashboard to local db failed');
    }
  }

  static Future<void> _mergeAndSaveDashboardData(Database db,
      http.Response responsePend, http.Response responseBela) async {
    try {
      await LocalStorageService.deleteDashboardData();
      final List<dynamic> dataPend = json.decode(responsePend.body);
      final List<dynamic> dataBela = json.decode(responseBela.body);

      final List<Map<String, dynamic>?> dashboardGab = dataPend
          .map((pend) {
            final bela = dataBela.firstWhere(
                (b) =>
                    b['id_daerah'] == pend['id_daerah'] &&
                    b['tahun'] == pend['tahun'] &&
                    b['id_skpd'] == pend['id_skpd'],
                orElse: () => null);
            if (bela != null) {
              return {
                'id_daerah': pend['id_daerah'],
                'tahun': pend['tahun'],
                'id_skpd': pend['id_skpd'],
                'kode_skpd': pend['kode_skpd'],
                'nama_skpd': pend['nama_skpd'],
                'anggaran_p': pend['anggaran'],
                'anggaran_b': bela['anggaran'],
                'realisasi_rencana_b': bela['realisasi_rencana'],
                'realisasi_rill_p': pend['realisasi_rill'],
                'realisasi_rill_b': bela['realisasi_rill'],
              };
            } else {
              return null;
            }
          })
          .where((item) => item != null)
          .toList();

      await LocalStorageService.saveDashboardData(db, dashboardGab);
    } catch (e) {
      LoggerService.logger.e('Failed to merge pendapatan and belanja: $e');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliSkpd(int idSkpd, String token) async {
    LoggerService.logger
        .i('Attempting to get kendali skpd for idSkpd: $idSkpd');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger
          .i('Kendali skpd fetched successfully for idSkpd: $idSkpd');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e('Failed to load kendali skpd for idSkpd: $idSkpd');
      throw Exception('Failed to load kendali skpd');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliUrusan(
      int idSkpd, int idSubSkpd, String token) async {
    LoggerService.logger.i(
        'Attempting to get kendali urusan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger.i(
          'Kendali urusan fetched successfully for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e(
          'Failed to load kendali urusan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd');
      throw Exception('Failed to load kendali urusan');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliProgram(
      int idSkpd, int idSubSkpd, int idBidangUrusan, String token) async {
    LoggerService.logger.i(
        'Attempting to get kendali program for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd/$idBidangUrusan?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger.i(
          'Kendali program fetched successfully for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e(
          'Failed to load kendali program for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan');
      throw Exception('Failed to load kendali program');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliKegiatan(int idSkpd, int idSubSkpd,
      int idBidangUrusan, int idProgram, String token) async {
    LoggerService.logger.i(
        'Attempting to get kendali kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd/$idBidangUrusan/$idProgram?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger.i(
          'Kendali kegiatan fetched successfully for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e(
          'Failed to load kendali kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram');
      throw Exception('Failed to load kendali kegiatan');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliSubKegiatan(int idSkpd, int idSubSkpd,
      int idBidangUrusan, int idProgram, int idGiat, String token) async {
    LoggerService.logger.i(
        'Attempting to get kendali sub kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd/$idBidangUrusan/$idProgram/$idGiat?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger.i(
          'Kendali sub kegiatan fetched successfully for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e(
          'Failed to load kendali sub kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat');
      throw Exception('Failed to load kendali sub kegiatan');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliRekening(
      int idSkpd,
      int idSubSkpd,
      int idBidangUrusan,
      int idProgram,
      int idGiat,
      int idSubGiat,
      String token) async {
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = await _getRequest(
        '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd/$idBidangUrusan/$idProgram/$idGiat/$idSubGiat?tanggal_akhir=$getDateNow',
        pHeaders);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load kendali rekening');
    }
  }

  // API Service untuk Laporan Keuagan - LRA
  static Future<Uint8List> getLraReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
  ) async {
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetaklra?searchparams={"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","formatFile":"pdf","level":$klasifikasi,"is_combine":"$konsolidasiSKPD","skpd":$idSkpd}&formatFile=pdf';
    final response = await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Laporan Keuagan - LO
  static Future<Uint8List> getLoReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
  ) async {
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetaklo?id_skpd=$idSkpd&tanggalFrom=$tanggalMulai&tanggalTo=$tanggalSampai&level=$klasifikasi&is_combine=$konsolidasiSKPD&filetype=pdf';
    final response = await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Laporan Keuagan - LPE
  static Future<Uint8List> getLpeReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
  ) async {
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/lpe/cetak?tanggalFrom=$tanggalMulai&tanggalTo=$tanggalSampai&format=$klasifikasi&konsolidasi_unit=$konsolidasiSKPD&filetype=pdf';
    final response = await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Laporan Keuagan - Neraca
  static Future<Uint8List> getNeracaReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
  ) async {
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/load-report-konsolidasi-neraca??searchparams={"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","formatFile":"pdf","level":$klasifikasi,"is_combine":"$konsolidasiSKPD","skpd":$idSkpd}&formatFile=pdf';
    final response = await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      throw Exception('Failed to load report');
    }
  }
}
