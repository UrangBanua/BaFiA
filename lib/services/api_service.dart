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
  static final String? apiVersionUrl = dotenv.env['API_DEMO_URL'];
  static final String apiServiceUrl = isDevelopmentMode
      ? dotenv.env['API_SERVICE_FAKE'] ?? ''
      : dotenv.env['API_SERVICE_URL'] ?? '';
  static final String? apiDemoUrl = dotenv.env['API_DEMO_URL'];
  static final String? fakeXApiKey = dotenv.env['FAKE_X_API_KEY'];
  static const int timeoutDuration = 20;
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
    LoggerService.logger.i('url: $url');
    LoggerService.logger.i('headers: $headers');
    LoggerService.logger.i('body: $body');
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
    LoggerService.logger.i('url: $url');
    LoggerService.logger.i('headers: $headers');
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
    LoggerService.logger.i('url: $url');
    LoggerService.logger.i('headers: $headers');
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
      Get.snackbar('Info',
          'singkron data service timeout - gunakan data lokal terakhir');
    } else {
      LoggerService.logger.e('$message: $e');
      Get.snackbar(
          'Info', 'singkron data service gagal - gunakan data lokal terakhir');
    }
  }

  // fungsi merge and save dashboard data
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

  // rest api get app release version
  static Future<Map<String, dynamic>?> getAppReleaseVersion() async {
    LoggerService.logger.i('Attempting to get captcha image');
    try {
      final response = await _getRequest(
          '$apiVersionUrl/release.json', {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        LoggerService.logger.i(response.body);
        LoggerService.logger.i('Get data release version fetched successfully');
        return json.decode(response.body);
      } else {
        _handleError(response, 'Failed to get data release version');
      }
    } catch (e) {
      _handleException(
          e as Exception, 'Get data request failed with exception');
    }
    return null;
  }

  // rest api get nama daerah
  static Future<Map<String, dynamic>?> getNamaDaerah(
      int idDaerah, bool isDemo) async {
    LoggerService.logger
        .i('Attempting to get Nama Daerah ${isDemo ? 'DEMO' : ''}');

    try {
      final response = isDemo
          ? await _getRequest('$apiDemoUrl/masterdata/daerah/demo.json',
              {'Content-Type': 'application/json'})
          : await _getRequest('$apiServiceUrl/masterdata/daerah/$idDaerah',
              {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        LoggerService.logger.i(response.body);
        LoggerService.logger.i('Get data Nama Daerah fetched successfully');
        return json.decode(response.body);
      } else {
        _handleError(response, 'Failed to get data Nama Daerah');
      }
    } catch (e) {
      _handleException(
          e as Exception, 'Get data request failed with exception');
    }
    return null;
  }

  // rest api get captcha image
  static Future<Map<String, dynamic>?> getCaptchaImage(bool isDemo) async {
    LoggerService.logger
        .i('Attempting to get captcha image ${isDemo ? 'DEMO' : ''}');

    try {
      final response = isDemo
          ? await _getRequest('$apiDemoUrl/auth/captcha/new.json',
              {'Content-Type': 'application/json'})
          : await _getRequest('$apiServiceUrl/auth/captcha/new',
              {'Content-Type': 'application/json'});

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
  static Future<Map<String, dynamic>?> login(String year, String username,
      String password, String captcha, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to login with username: $username ${isDemo ? 'DEMO' : ''}');
    try {
      final pHeaders =
          isDevelopmentMode ? {'x-api-key': fakeXApiKey ?? ''} : {};
      final response = isDemo
          ? await _getRequest('$apiDemoUrl/auth/auth/pre-login.json',
              {'Content-Type': 'application/json'})
          : await client.post(Uri.parse('$apiServiceUrl/auth/auth/pre-login'),
              headers:
                  isDevelopmentMode ? pHeaders as Map<String, String>? : null,
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

  // rest api get user token
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
    required bool isDemo,
  }) async {
    LoggerService.logger
        .i('Attempting to get user token ${isDemo ? 'DEMO' : ''}');
    try {
      final response = isDemo
          ? await _getRequest('$apiDemoUrl/auth/auth/login.json',
              {'Content-Type': 'application/json'})
          : await _postRequest(
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

  // rest api Sync Dashboard to Local DB
  static Future<void> syncDashboardToLocalDB(
      Database db, String token, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to sync dashboard data to local db ${isDemo ? 'DEMO' : ''}');
    try {
      final pHeaders = isDevelopmentMode
          ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
          : {'Authorization': 'Bearer $token'};

      /* final responsePend = await _getRequest(
        '$apiServiceUrl/penerimaan/strict/dashboard/statistik-pendapatan',
        pHeaders,
      ); */

      // set dummy data responsePend
      /* final responsePend = http.Response(
          '[{"id_daerah":295,"tahun":2024,"id_skpd":65,"kode_skpd":"5.02.0.00.0.00.01.0000","nama_skpd":"Badan Pengelola Keuangan dan Aset Daerah","anggaran":1504449542000,"realisasi_rill":687174554632.7098}]',
          200); */

      final responseBela = isDemo
          ? await _getRequest(
              '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja.json',
              {'Content-Type': 'application/json'})
          : await _getRequest(
              '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja',
              pHeaders,
            );

      // set dummy data responsePend = responseBela
      final responsePend = responseBela;

      if (responsePend.statusCode == 200 && responseBela.statusCode == 200) {
        LoggerService.logger
            .i('Dashboard data synced to local db successfully');
        await _mergeAndSaveDashboardData(db, responsePend, responseBela);
      } else if (responsePend.statusCode == 503 &&
          responseBela.statusCode == 503) {
        LoggerService.logger.e(
            'Failed to sync dashboard data [Service Temporarily Unavailable]');
        Get.snackbar('Info',
            'singkron data service tidak tersedia saat ini - gunakan data lokal terakhir');
      } else if (responseBela.statusCode != 200 &&
          responsePend.statusCode != 200) {
        LoggerService.logger.e(
            'Failed to sync dashboard data code: ${responseBela.statusCode} and ${responsePend.statusCode}');
        Get.snackbar('Info',
            'singkron data service gagal - gunakan data lokal terakhir');
      } else {
        LoggerService.logger.e('Failed to sync dashboard data to local db');
      }
    } catch (e) {
      _handleException(e as Exception, 'Sync dashboard to local db failed');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliSkpd(
      int idSkpd, String token, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali skpd for idSkpd: $idSkpd ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/skpd.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
            '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd?tanggal_akhir=$getDateNow',
            pHeaders);
    if (response.statusCode == 200) {
      LoggerService.logger
          .i('Kendali skpd fetched successfully for idSkpd: $idSkpd');
      return json.decode(response.body);
    } else {
      LoggerService.logger.e('Failed to load kendali skpd for idSkpd: $idSkpd');
      Get.snackbar('Info',
          'singkron data pohon kendali gagal pada idSKPD: $idSkpd - cek koneksi internet anda.');
      throw Exception('Failed to load kendali skpd');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliUrusan(
      int idSkpd, int idSubSkpd, String token, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali urusan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/urusan.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
            '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd?tanggal_akhir=$getDateNow',
            pHeaders);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      LoggerService.logger.e(
          'Failed to load kendali urusan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd');
      throw Exception('Failed to load kendali urusan');
    }
  }

  // API Service untuk Dokumen Kendali
  static Future<List<dynamic>> getKendaliProgram(int idSkpd, int idSubSkpd,
      int idBidangUrusan, String token, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali program for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/program.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
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
      int idBidangUrusan, int idProgram, String token, bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/kegiatan.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
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
  static Future<List<dynamic>> getKendaliSubKegiatan(
      int idSkpd,
      int idSubSkpd,
      int idBidangUrusan,
      int idProgram,
      int idGiat,
      String token,
      bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali sub kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/subkegiatan.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
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
      String token,
      bool isDemo) async {
    LoggerService.logger.i(
        'Attempting to get kendali sub kegiatan for idSkpd: $idSkpd, idSubSkpd: $idSubSkpd, idBidangUrusan: $idBidangUrusan, idProgram: $idProgram, idGiat: $idGiat, Rekening ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final response = isDemo
        ? await _getRequest(
            '$apiDemoUrl/pengeluaran/strict/dashboard/statistik-belanja/rekening.json',
            {
                'Content-Type': 'application/json'
              })
        : await _getRequest(
            '$apiServiceUrl/pengeluaran/strict/dashboard/statistik-belanja/$idSkpd/$idSubSkpd/$idBidangUrusan/$idProgram/$idGiat/$idSubGiat?tanggal_akhir=$getDateNow',
            pHeaders);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load kendali rekening');
    }
  }

  // API Service untuk Laporan Keuagan - LRA Periode
  static Future<Uint8List> getLraReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
    bool isDemo,
  ) async {
    LoggerService.logger.i(
        'Attempting to get Laporan Keuagan - LRA Periode ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetaklra?searchparams={"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","formatFile":"pdf","level":$klasifikasi,"is_combine":"$konsolidasiSKPD","skpd":$idSkpd}&formatFile=pdf';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger.i('LRA fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger.e('Failed to load LRA skpd for idSkpd: $idSkpd');
      Get.snackbar('Info', 'singkron data LRA berhasil pada idSKPD: $idSkpd.');
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Laporan Keuagan - LRA Prognosis
  static Future<Uint8List> getLraPrognosisReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
    bool isDemo,
  ) async {
    LoggerService.logger.i(
        'Attempting to get Laporan Keuagan - LRA Prognosis ${isDemo ? 'DEMO' : ''}');
    int? klevel;
    if (klasifikasi == 0) {
      klevel = null;
    } else {
      klevel = klasifikasi;
    }
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetak-prognosis?searchparams={"idSkpd":$idSkpd,"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","formatFile":"pdf","level":$klevel,"is_anggaran":"false","tahapan":{"id_jadwal":null,"id_jadwal_sipd":null,"id_tahap":null},"is_combine":"$konsolidasiSKPD"}&formatFile=pdf';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger
          .i('LRA Prognosis fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger
          .e('Failed to load LRA Prognosis skpd for idSkpd: $idSkpd');
      Get.snackbar(
          'Info', 'singkron data LRA Prognosis berhasil pada idSKPD: $idSkpd.');
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Laporan Keuagan - LRA Program
  static Future<Uint8List> getLraProgramReport(
    String tanggalMulai,
    String tanggalSampai,
    int klasifikasi,
    String konsolidasiSKPD,
    int idSkpd,
    String token,
    bool isDemo,
  ) async {
    LoggerService.logger.i(
        'Attempting to get Laporan Keuagan - LRA Program ${isDemo ? 'DEMO' : ''}');
    int? klevel;
    if (klasifikasi == 0) {
      klevel = null;
    } else {
      klevel = klasifikasi;
    }
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetak-lra-per-program?searchparams={"id_skpd":$idSkpd,"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","uraian":$klevel,"klasifikasi":null,"filter":0,"is_combine":"$konsolidasiSKPD","formatFile":"pdf"}';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger
          .i('LRA Program fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger
          .e('Failed to load LRA Program skpd for idSkpd: $idSkpd');
      Get.snackbar(
          'Info', 'singkron data LRA Program berhasil pada idSKPD: $idSkpd.');
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
    bool isDemo,
  ) async {
    LoggerService.logger
        .i('Attempting to get Laporan Keuagan - LO ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/cetaklo?id_skpd=$idSkpd&tanggalFrom=$tanggalMulai&tanggalTo=$tanggalSampai&level=$klasifikasi&is_combine=$konsolidasiSKPD&filetype=pdf';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger.i('LO fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger.e('Failed to load LO skpd for idSkpd: $idSkpd');
      Get.snackbar('Info', 'singkron data LO berhasil pada idSKPD: $idSkpd.');
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
    bool isDemo,
  ) async {
    LoggerService.logger
        .i('Attempting to get Laporan Keuagan - LPE ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/lpe/cetak?tanggalFrom=$tanggalMulai&tanggalTo=$tanggalSampai&format=$klasifikasi&konsolidasi_unit=$konsolidasiSKPD&filetype=pdf';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger.i('LPE fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger.e('Failed to load LPE skpd for idSkpd: $idSkpd');
      Get.snackbar('Info', 'singkron data LPE berhasil pada idSKPD: $idSkpd.');
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
    bool isDemo,
  ) async {
    LoggerService.logger.i(
        'Attempting to get Laporan Keuagan - Neraca ${isDemo ? 'DEMO' : ''}');
    final pHeaders = isDevelopmentMode
        ? {'x-api-key': fakeXApiKey ?? '', 'Authorization': 'Bearer $token'}
        : {'Authorization': 'Bearer $token'};
    final url =
        '$apiServiceUrl/aklap/api/report/load-report-konsolidasi-neraca??searchparams={"tanggalFrom":"$tanggalMulai","tanggalTo":"$tanggalSampai","formatFile":"pdf","level":$klasifikasi,"is_combine":"$konsolidasiSKPD","skpd":$idSkpd}&formatFile=pdf';
    final response = isDemo
        ? await _getRequest('$apiDemoUrl/aklap/api/report/demo.pdf', {})
        : await _getRequestReports(url, pHeaders);
    // Show the URL in the console
    LoggerService.logger.i(url);
    //final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      LoggerService.logger.i('Neraca fetched successfully for idSkpd: $idSkpd');
      // return data as Uint8List
      return Uint8List.fromList(response.body.codeUnits);
      //return response.body; // Assuming the API returns the URL of the PDF
    } else {
      LoggerService.logger.e('Failed to load Neraca skpd for idSkpd: $idSkpd');
      Get.snackbar(
          'Info', 'singkron data Neraca berhasil pada idSKPD: $idSkpd.');
      throw Exception('Failed to load report');
    }
  }

  // API Service untuk Register TU-TBP-SPP-SPM-SP2D
  static Future<dynamic> postRegisterTuTbpSppSpmSp2d(
    String jenisDokumen,
    String tanggalMulai,
    String tanggalSampai,
    String jenisRegister,
    int idSkpd,
    String jenisKriteria,
    String token,
    bool isDemo,
  ) async {
    LoggerService.logger.i(
        'Attempting to get Register Jenis: $jenisDokumen ${isDemo ? 'DEMO' : ''}');
    try {
      final pHeaders = isDevelopmentMode
          ? {
              'x-api-key': fakeXApiKey ?? '',
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            }
          : {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            };
      final response = isDemo
          ? await _getRequest(
              '$apiDemoUrl/pengeluaran/strict/laporan/register/cetak_$jenisDokumen.json',
              {'Content-Type': 'application/json'})
          : await _postRequest(
              '$apiServiceUrl/pengeluaran/strict/laporan/register/cetak',
              {
                'jenis_dokumen': jenisDokumen,
                'tanggal_awal': tanggalMulai,
                'tanggal_akhir': tanggalSampai,
                'jenis_register': jenisRegister,
                'id_skpd': idSkpd,
                'jenis_kriteria': jenisKriteria,
              },
              pHeaders);

      LoggerService.logger.i('response: $pHeaders');

      if (response.statusCode == 200) {
        LoggerService.logger.i('Register berhasil diambil');
        return json.decode(response.body);
      }
      if (response.statusCode == 400 &&
          response.body.contains('Anda tidak dapat mengakses fitur ini')) {
        LoggerService.logger
            .i('Anda tidak memiliki akses untuk mengakses data ini');
        Get.snackbar(
            'Alert', 'Anda tidak memiliki akses untuk mengakses data ini');
      }
      if (response.statusCode == 401 &&
          response.body.contains('Token anda expired')) {
        LoggerService.logger.i('Token anda expired, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      }
      if (response.statusCode == 401 &&
          response.body.contains('signature is invalid')) {
        LoggerService.logger.i('Token anda salah, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      } else {
        _handleError(response, 'Gagal mengambil data Register');
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Register: Request timeout');
        Get.snackbar('Info', 'Singkron data service timeout');
      } else {
        LoggerService.logger.e('Register: $e');
        Get.snackbar(
            'Info', 'Singkron data service gagal'); // Handle other exceptions
      }
    }
    return null;
  }

  // API Service untuk Tracking Document
  static Future<dynamic> postTrackingDocument(
    int pageNo,
    String tanggalMulai,
    String tanggalSampai,
    int idSkpd,
    String token,
    bool isDemo,
  ) async {
    try {
      LoggerService.logger
          .i('Attempting to get Tracking Document ${isDemo ? 'DEMO' : ''}');
      final pHeaders = isDevelopmentMode
          ? {
              'x-api-key': fakeXApiKey ?? '',
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            }
          : {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            };
      final response = isDemo
          ? await _getRequest(
              '$apiDemoUrl/pengeluaran/strict/laporan/register/tracking-document.json',
              {'Content-Type': 'application/json'})
          : await _postRequest(
              '$apiServiceUrl/pengeluaran/strict/laporan/register/tracking-document?page=$pageNo&limit=10',
              {
                'tanggal_awal': tanggalMulai,
                'tanggal_akhir': tanggalSampai,
                'id_skpd': idSkpd,
              },
              pHeaders);

      LoggerService.logger.i('response: $pHeaders');

      if (response.statusCode == 200) {
        LoggerService.logger.i('Tracking Document berhasil diambil');
        // Parse response body to map
        final responseBody = json.decode(response.body);
        // Combine headers and body into one map
        final combinedResponse = {
          'headers': response.headers,
          'body': responseBody,
        };
        // Return the combined map
        return combinedResponse;
      }
      if (response.statusCode == 400 &&
          response.body.contains('Anda tidak dapat mengakses fitur ini')) {
        LoggerService.logger
            .i('Anda tidak memiliki akses untuk mengakses data ini');
        Get.snackbar(
            'Alert', 'Anda tidak memiliki akses untuk mengakses data ini');
      }
      if (response.statusCode == 401 &&
          response.body.contains('Token anda expired')) {
        LoggerService.logger.i('Token anda expired, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      }
      if (response.statusCode == 401 &&
          response.body.contains('signature is invalid')) {
        LoggerService.logger.i('Token anda salah, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      } else {
        _handleError(response, 'Gagal mengambil data Register');
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Tracking Document: Request timeout');
        Get.snackbar('Info', 'Singkron data service timeout');
      } else {
        LoggerService.logger.e('Tracking Document: $e');
        Get.snackbar(
            'Info', 'Singkron data service gagal'); // Handle other exceptions
      }
    }
    return null;
  }

  // API Service untuk Tracking Realisasi
  static Future<dynamic> postTrackingRealisasi(
    int pilihBulan,
    int idSkpd,
    String token,
    bool isDemo,
  ) async {
    try {
      LoggerService.logger
          .i('Attempting to get Tracking Document ${isDemo ? 'DEMO' : ''}');
      final pHeaders = isDevelopmentMode
          ? {
              'x-api-key': fakeXApiKey ?? '',
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            }
          : {
              'Content-Type': 'application/json',
              'authorization': 'Bearer $token'
            };
      final response = isDemo
          ? await _getRequest(
              '$apiDemoUrl/pengeluaran/strict/laporan/register/tracking-realisasi.json',
              {
                  'Content-Type': 'application/json'
                })
          : await _getRequest(
              '$apiServiceUrl/pengeluaran/strict/laporan/realisasi/cetak?tipe=bulan&skpd=$idSkpd&bulan=$pilihBulan',
              pHeaders);

      LoggerService.logger.i('response: $pHeaders');

      if (response.statusCode == 200) {
        LoggerService.logger.i('Tracking Document berhasil diambil');
        return json.decode(response.body);
      }
      if (response.statusCode == 400 &&
          response.body.contains('Anda tidak dapat mengakses fitur ini')) {
        LoggerService.logger
            .i('Anda tidak memiliki akses untuk mengakses data ini');
        Get.snackbar(
            'Alert', 'Anda tidak memiliki akses untuk mengakses data ini');
      }
      if (response.statusCode == 401 &&
          response.body.contains('Token anda expired')) {
        LoggerService.logger.i('Token anda expired, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      }
      if (response.statusCode == 401 &&
          response.body.contains('signature is invalid')) {
        LoggerService.logger.i('Token anda salah, harap login ulang');
        Get.snackbar('Alert', 'Token anda expired');
      } else {
        _handleError(response, 'Gagal mengambil data Register');
      }
    } catch (e) {
      if (e is TimeoutException) {
        LoggerService.logger.e('Tracking Document: Request timeout');
        Get.snackbar('Info', 'Singkron data service timeout');
      } else {
        LoggerService.logger.e('Tracking Document: $e');
        Get.snackbar(
            'Info', 'Singkron data service gagal'); // Handle other exceptions
      }
    }
    return {};
  }
}
