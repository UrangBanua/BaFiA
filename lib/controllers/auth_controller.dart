import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var refreshToken = '';

  get userData => null;

  void login(String year, String username, String password) async {
    print('Login started: $username');
    var response = await ApiService.login(year, username, password);
    if (response != null) {
      var role = response['nama_role'];
      var skpd = response['nama_skpd'];
      var tahun = year;

      print('Login successful: $username');
      LocalStorageService.saveUserData(response);
      LocalStorageService.saveUserData({
        'id_pegawai': response['id_pegawai'],
        'username': username,
        'password': password,
        'tahun': tahun
      });
      print('User data pre-login saved to db: $response');

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
                  response['token'] = tokenResponse['token'];
                  response['refresh_token'] = tokenResponse['refresh_token'];
                  try {
                    LocalStorageService.saveUserData(response);
                    print('Save User data login to db success');
                  } catch (error) {
                    print('Error saveUserData: $error');
                  }
                  isLoggedIn.value = true;
                  Get.offAllNamed('/dashboard');
                  print('Login completed: $username');
                  //print('User data: $response');
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
      print('Login failed: $username');
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
      //print('Token response: $response');
      refreshToken = response['refresh_token'];
      return response;
    } else {
      print('Token fetch failed for: $username');
      return null;
    }
  }

  void logout() {
    print('Logout started');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
    print('Logout completed');
  }
}
