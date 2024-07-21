import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var userData = {}.obs;
  var userToken = {}.obs;
  var captchaData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserData();
    ApiService.checkDevelopmentModeWarning();
  }

  Future<void> _checkUserData() async {
    var data = await LocalStorageService.getUserData();
    if (data != null) {
      userData.value = data;
      isLoggedIn.value = true;
      userToken = ({
        'token': userData['token'],
        'refresh_token': userData['refresh_token']
      }).obs;
      //LoggerService.logger.i('User token: ' + userToken['refresh_token']);
    }
  }

  Future<void> _fetchCaptchaImage() async {
    var response = await ApiService.getCaptchaImage();
    if (response != null && response['base64'] != null) {
      captchaData.value = response;
    } else {
      LoggerService.logger.e('Captcha image fetch failed');
    }
  }

  Future<void> login(
      String year, String username, String password, String captcha) async {
    var response = await ApiService.login(year, username, password, captcha);
    if (response != null) {
      var kodeSkpd = response['kode_skpd'];
      var namaSkpd = response['nama_skpd'];
      var namaRole = response['nama_role'];
      var tahun = year;

      LoggerService.logger.i('Login successful: $username');

      // Set variable userData
      userData.value = response;
      LoggerService.logger.i('Set variable userData');

      // // User data pre-login saved to db
      // await LocalStorageService.saveUserData({
      //   'id_pegawai': id_pegawai,
      //   'username': username,
      //   'password': password,
      //   'tahun': tahun
      // });
      //LoggerService.logger.i('User data pre-login saved to db: $response');

      // ambil captcha image
      await _fetchCaptchaImage();
      LoggerService.logger.i('Captcha image fetched id: ${captchaData['id']}');

      Get.dialog(
        AlertDialog(
          title: const Text('Konfirmasi Login'),
          content: Column(
            children: [
              Text('Role: $namaRole\nKode SKPD: $kodeSkpd\nSKPD: $namaSkpd\n'),
              Image.memory(base64Decode(captchaData['base64'])),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Masukkan Captcha'),
                onChanged: (value) => captcha = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                LoggerService.logger.i('Login cancelled: $username');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var tokenResponse = await fetchUserToken(
                    response['id_daerah'],
                    response['id_role'],
                    response['id_skpd'],
                    response['id_pegawai'],
                    password,
                    int.parse(year), // Convert year to integer
                    username,
                    captchaData['id'],
                    captcha);

                if (tokenResponse != null) {
                  // Merge token response with user data and save to local storage
                  response['username'] = username;
                  response['password'] = password;
                  response['tahun'] = int.parse(tahun);
                  response['token'] = tokenResponse['token'];
                  response['refresh_token'] = tokenResponse['refresh_token'];
                  await LocalStorageService.saveUserData(response);
                  userData.value = response;
                  LoggerService.logger.i('userData Merger: ');
                  userToken = (tokenResponse).obs;
                  LoggerService.logger.i('Simpan variable data user token');
                  isLoggedIn.value = true;
                  Get.offAllNamed('/dashboard');
                  LoggerService.logger.i('Login completed: $username');
                } else {
                  Get.snackbar('Login Failed', 'Unable to retrieve token');
                  LoggerService.logger.e('Token fetch failed for: $username');
                }
              },
              child: const Text('Pilih'),
            ),
          ],
        ),
      );
    } else {
      LoggerService.logger.e('Login failed: Invalid username or password');
      Get.snackbar('Login Failed', 'Invalid username or password');
    }
  }

  Future<Map<String, dynamic>?> fetchUserToken(
      int idDaerah,
      int idRole,
      int idSkpd,
      int idPegawai,
      String password,
      int year,
      String username,
      String capcaptchaId,
      String capcaptchaSolution) async {
    LoggerService.logger.i('Fetching user token for: $username');
    var response = await ApiService.getUserToken(
        idDaerah: idDaerah,
        idRole: idRole,
        idSkpd: idSkpd,
        idPegawai: idPegawai,
        password: password,
        year: year,
        username: username,
        captchaId: capcaptchaId,
        captchaSolution: capcaptchaSolution);
    if (response != null &&
        response['token'] != null &&
        response['refresh_token'] != null) {
      LoggerService.logger.i('Token fetched successfully for: $username');
      return response;
    } else {
      LoggerService.logger.e('Token fetch failed for: $username');
      return null;
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Apakah Anda yakin ingin logout?'),
        content:
            const Text('token yg lama akan hilang❗ diperlukan login kembali'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog jika pengguna memilih 'Tidak'
            },
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Tutup dialog jika pengguna memilih 'Yakin'
              await LocalStorageService.deleteUserData(); // Hapus data user
              isLoggedIn = false.obs;
              userData.value = {}.obs; // Mengosongkan userData
              Get.offAllNamed('/login');
              LoggerService.logger.i('Logout completed');
            },
            child: const Text('Yakin'),
          ),
        ],
      ),
    );
  }
}
