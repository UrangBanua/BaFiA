import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var userData = {}.obs;
  var userToken = {}.obs;

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
      print('User token: ' + userToken['refresh_token']);
    }
  }

  Future<void> login(String year, String username, String password) async {
    var response = await ApiService.login(year, username, password);
    if (response != null) {
      var id_pegawai = response['id_pegawai'];
      var tahun = year;
      var role = response['nama_role'];
      var skpd = response['nama_skpd'];

      print('Login successful: $username');
      LocalStorageService.saveUserData(response);
      LocalStorageService.saveUserData({
        'id_pegawai': id_pegawai,
        'username': username,
        'password': password,
        'tahun': tahun
      });
      print('User data pre-login saved to db: $response');
      userData.value = response;
      print('Simpan variable data user login');

      Get.dialog(
        AlertDialog(
          title: Text('Konfirmasi Login'),
          content: Text('Role: $role\nSKPD: $skpd'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                print('Login cancelled: $username');
              },
              child: Text('Cancel'),
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
                );

                if (tokenResponse != null) {
                  // Merge token response with user data and save to local storage
                  response['username'] = username;
                  response['password'] = password;
                  response['tahun'] = int.parse(tahun);
                  response['token'] = tokenResponse['token'];
                  response['refresh_token'] = tokenResponse['refresh_token'];
                  await LocalStorageService.saveUserData(response);
                  userData.value = response;
                  print('userData Merger: ' + userData.obs.toString());
                  userToken = (tokenResponse).obs;
                  print('Simpan variable data user token');
                  isLoggedIn.value = true;
                  Get.offAllNamed('/dashboard');
                  print('Login completed: $username');
                } else {
                  Get.snackbar('Login Failed', 'Unable to retrieve token');
                  print('Token fetch failed for: $username');
                }
              },
              child: Text('Pilih'),
            ),
          ],
        ),
      );
    } else {
      print('Login failed: Invalid username or password');
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
      String username) async {
    print('Fetching user token for: $username');
    var response = await ApiService.getUserToken(
      idDaerah: idDaerah,
      idRole: idRole,
      idSkpd: idSkpd,
      idPegawai: idPegawai,
      password: password,
      year: year,
      username: username,
    );
    if (response != null &&
        response['token'] != null &&
        response['refresh_token'] != null) {
      print('Token fetched successfully for: $username');
      return response;
    } else {
      print('Token fetch failed for: $username');
      return null;
    }
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Apakah Anda yakin ingin logout?'),
        content: Text('token yg lama akan hilang❗ diperlukan login kembali'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Tutup dialog jika pengguna memilih 'Tidak'
            },
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Tutup dialog jika pengguna memilih 'Yakin'
              await LocalStorageService.deleteUserData(); // Hapus data user
              isLoggedIn = false.obs;
              userData.value = {}.obs; // Mengosongkan userData
              Get.offAllNamed('/login');
              print('Logout completed');
            },
            child: Text('Yakin'),
          ),
        ],
      ),
    );
  }
}
