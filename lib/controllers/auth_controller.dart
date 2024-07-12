import 'dart:convert';

import 'package:get/get.dart';
import 'package:logging/logging.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

final Logger _logger = Logger('ApiService');

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var userData = {}.obs;
  var userToken = {}.obs;
  var captchaData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserData();
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
      //_logger.info('User token: ' + userToken['refresh_token']);
    }
  }

  Future<void> _fetchCaptchaImage() async {
    var response = await ApiService.getCaptchaImage();
    if (response != null && response['base64'] != null) {
      captchaData.value = response;
    } else {
      _logger.severe('Captcha image fetch failed');
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

      _logger.info('Login successful: $username');

      // Set variable userData
      userData.value = response;
      _logger.info('Set variable userData');

      // // User data pre-login saved to db
      // await LocalStorageService.saveUserData({
      //   'id_pegawai': id_pegawai,
      //   'username': username,
      //   'password': password,
      //   'tahun': tahun
      // });
      //_logger.info('User data pre-login saved to db: $response');

      // ambil captcha image
      await _fetchCaptchaImage();
      // ignore: prefer_interpolation_to_compose_strings
      _logger.info('Captcha image fetched id: ' + captchaData['id'].toString());

      Get.dialog(
        AlertDialog(
          title: const Text('Konfirmasi Login'),
          content: Column(
            children: [
              Text('Role: $namaRole\nKode SKPD: $kodeSkpd\nSKPD: $namaSkpd\n'),
              Image.memory(base64Decode(captchaData['base64'])),
              TextField(
                decoration: const InputDecoration(labelText: 'Masukkan Captcha'),
                onChanged: (value) => captcha = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                _logger.info('Login cancelled: $username');
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
                  _logger.info('userData Merger: ');
                  userToken = (tokenResponse).obs;
                  _logger.info('Simpan variable data user token');
                  isLoggedIn.value = true;
                  Get.offAllNamed('/dashboard');
                  _logger.info('Login completed: $username');
                } else {
                  Get.snackbar('Login Failed', 'Unable to retrieve token');
                  _logger.severe('Token fetch failed for: $username');
                }
              },
              child: const Text('Pilih'),
            ),
          ],
        ),
      );
    } else {
      _logger.severe('Login failed: Invalid username or password');
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
    _logger.info('Fetching user token for: $username');
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
      _logger.info('Token fetched successfully for: $username');
      return response;
    } else {
      _logger.severe('Token fetch failed for: $username');
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
              _logger.info('Logout completed');
            },
            child: const Text('Yakin'),
          ),
        ],
      ),
    );
  }
}
