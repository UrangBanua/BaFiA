import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  void login(String year, String username, String password) async {
    var response = await ApiService.login(year, username, password);
    if (response != null) {
      var role = response['nama_role'];
      var skpd = response['nama_skpd'];

      Get.dialog(
        AlertDialog(
          title: Text('Konfirmasi Login'),
          content: Text('Role: $role\nSKPD: $skpd'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
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
                  response['token'] = tokenResponse['token'];
                  response['refresh_token'] = tokenResponse['refresh_token'];
                  LocalStorageService.saveUserData(response);
                  isLoggedIn.value = true;
                  Get.offAllNamed('/dashboard');
                } else {
                  Get.snackbar('Login Failed', 'Unable to retrieve token');
                }
              },
              child: Text('Pilih'),
            ),
          ],
        ),
      );
    } else {
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
      return response;
    }
    return null;
  }

  void logout() {
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
