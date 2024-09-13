import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'auth_controller.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class UserController extends GetxController {
  final RxBool isBiometricEnabled = false.obs;
  final RxString saldoBank = '0,00'.obs;
  final RxString saldoTunai = '0,00'.obs;
  RxString fotoProfile = ''.obs;
  RxString fcmToken = ''.obs;

  // GetStorage instance for storing FCM token
  static final GetStorage _storageFcmToken = GetStorage('fcm_token');

  // set var userData from get autenticator controller
  final RxMap<dynamic, dynamic> userProfile = {}.obs;
  late var isDemo = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    isDemo.value = Get.find<AuthController>().isDemo.value;
    LoggerService.logger.i('Profile photo: ${userProfile['profile_photo']}');
    if (userProfile['profile_photo'] != '-' ||
        userProfile['profile_photo'].isNotEmpty) {
      _setFotoProfile();
    }
    //fetchBalanceData();
    getFcmToken();
  }

  // fungsi untuk mengambil token fcm
  Future<void> getFcmToken() async {
    final String? token = _storageFcmToken.read('fcm_token');
    if (token != null) {
      fcmToken.value = token;
    }
  }

  Future<void> _setFotoProfile() async {
    var profilePhoto = await userProfile['profile_photo'];

    if (profilePhoto == null) {
      // Load the default profile image from assets
      ByteData imageData =
          await rootBundle.load('assets/images/default_profile.png');
      Uint8List bytes = imageData.buffer.asUint8List();

      // Convert the image bytes to a base64 string
      String base64String = base64Encode(bytes);

      fotoProfile.value = base64String;
    } else {
      fotoProfile.value = profilePhoto;
    }
  }

  // fungsi untuk mengambil data user
  Future<void> fetchUserData() async {
    LoggerService.logger.i('Fetching user data...');
    var data = await LocalStorageService.getUserData();
    if (data != null) {
      LoggerService.logger.i('User data fetched successfully.');
      userProfile.value = data;
    } else {
      LoggerService.logger.i('No user data found.');
    }
  }

  // fungsi untuk mengambil data saldo bendahara
  Future<void> fetchBalanceData() async {
    LoggerService.logger.i('Fetching balance data... is $isDemo');
    if (userProfile['nama_role'] != null &&
        userProfile['nama_role'].contains('BENDAHARA')) {
      try {
        var response = await ApiService.getCekSaldoBendahara(
            userProfile['refresh_token'], isDemo.value);
        if (response != null) {
          LoggerService.logger.i('Balance data fetched successfully.');
          saldoBank.value =
              formatCurrency((response['saldo_bank'] as num).toDouble());
          saldoTunai.value =
              formatCurrency((response['saldo_tunai'] as num).toDouble());
        } else {
          LoggerService.logger.i('No balance data found.');
        }
      } catch (e) {
        LoggerService.logger.e('Error fetching balance data: $e');
      }
    } else {
      LoggerService.logger
          .w('Access denied: User does not have BENDAHARA role.');
    }
  }

  // fungsi maskString untuk menyembunyikan sebagian data
  String maskString(String input) {
    if (input.length <= 3) return input;
    return input.substring(0, 3) + '*' * (input.length - 3);
  }

  // Fungsi formatCurrency untuk menampilkan format mata uang
  String formatCurrency(double value) {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: 'id-ID',
    ).format(value);
  }

  // fungsi untuk mengupdate foto profil
  Future<void> updateProfilePhoto(String imageHash) async {
    fotoProfile.value = imageHash;
    try {
      // Save the updated user data to local storage
      await LocalStorageService.saveUserData({
        'profile_photo': fotoProfile.value,
        'id_user': userProfile['id_user'],
      });
      // Update userData with the new imageHash
      //userProfile.update('profile_photo', (value) => imageHash,
      //    ifAbsent: () => imageHash);
    } catch (e) {
      LoggerService.logger.i('Error updating profile photo: $e');
    }
  }

  // fungsi untuk mengupdate tema
  Future<void> saveTheme(int idUser, bool isDarkMode) async {
    final db = await LocalStorageService.database;
    LoggerService.logger
        .i('Updating user theme. User ID: $idUser, Dark Mode: $isDarkMode');
    await db.update(
      'User',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id_user = ?',
      whereArgs: [idUser],
    );
  }

  // fungsi untuk mengambil tema
  Future<bool> getTheme() async {
    final db = await LocalStorageService.database;
    final user = await db.query('User',
        where: 'id_user = ?', whereArgs: [userProfile['id_user']]);
    if (user.isNotEmpty) {
      return user.first['isDarkMode'] == 1;
    }
    return false; // Default to light mode
  }

  // fungsi untuk mempilih foto dari galeri
  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final bytes = await File(pickedFile.path).readAsBytes();
        // Resize and compress image
        final img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          final resizedImage =
              img.copyResize(image, width: 300); // Resize to 300px width
          final compressedBytes = img.encodeJpg(resizedImage,
              quality: 85); // Compress with 85% quality
          final base64String = base64Encode(compressedBytes);
          await updateProfilePhoto(base64String);
        }
      } catch (e) {
        LoggerService.logger.i('Error processing image: $e');
      }
    } else {
      LoggerService.logger.i('No image selected.');
    }
  }

  // fungsi Future untuk mengambil foto profil
  Future<ImageProvider> getProfileImage1(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      LoggerService.logger.i('ambil data default_profile.png');
      return const AssetImage('assets/images/default_profile.png');
    }
  }

  // fungsi untuk mengambil foto profil
  ImageProvider getProfileImage2(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      LoggerService.logger.i('ambil data default_profile.png');
      return const AssetImage('assets/images/default_profile.png');
    }
  }

  // fungsi untuk Enable/Disable biometric
  void setBiometricEnabled(bool value) {
    isBiometricEnabled.value = value;
    // Save to local storage or database
    LocalStorageService.saveUserData({'isBiometricEnabled': value});
  }
}
