import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'local_storage_service.dart';

class ApiService {
  static var client = http.Client();

  static const _timeoutUserDuration =
      Duration(seconds: 30); // Set timeout to 30 detik

  static Future<Map<String, dynamic>?> login(
      String year, String username, String password) async {
    print('Login started');
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    try {
      var response = await client.post(
        Uri.parse('https://service.sipd.kemendagri.go.id/auth/auth/pre-login'),
        body: {
          'username': username,
          'password': password,
          'tahun': year,
        },
      ).timeout(_timeoutUserDuration);
      Get.back(); // Close loading progress

      if (response.statusCode == 200) {
        // Assume response is a list and take the first item
        var data = json.decode(response.body);
        print('Login successful');
        return data.isNotEmpty ? data[0] : null;
      }
    } on TimeoutException {
      Get.back(); // Close loading progress
      print('Login timed out');
      Get.snackbar('Error', 'Service belum bisa merespon, coba lagi nanti.');
    }
    print('Login failed');
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
    print('Getting user token');
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    try {
      var response = await client.post(
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
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutUserDuration);
      Get.back(); // Close loading progress

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('User token obtained');
        return data;
      }
    } on TimeoutException {
      Get.back(); // Close loading progress
      print('Getting user token timed out');
      Get.snackbar('Error', 'Service timeout, coba lagi nanti.');
    }
    print('Failed to get user token');
    return null;
  }

  static Future<void> syncDashboardToLocalDB(Database db, String token) async {
    print('Syncing Dashboard to local DB');
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    try {
      var response = await client.get(
        Uri.parse(
            'https://service.sipd.kemendagri.go.id/pengeluaran/strict/dashboard/statistik-belanja'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeoutUserDuration);
      Get.back(); // Close loading progress

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Data synced to local DB');
        LocalStorageService.saveDashboardData(db, data);
      }
    } on TimeoutException {
      Get.back(); // Close loading progress
      print('Syncing data to local DB timed out');
      Get.snackbar('Error', 'Service timeout, coba lagi nanti.');
    }
  }
}
