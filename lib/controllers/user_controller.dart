import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../services/local_storage_service.dart';
import '../services/logger_service.dart';

class UserController extends GetxController {
  var isBiometricEnabled = false.obs;
  var userData =
      RxMap<String, dynamic>(); // Ensure userData is a mutable observable map

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    LoggerService.logger.i('Fetching user data...');
    var data = await LocalStorageService.getUserData();
    if (data != null) {
      LoggerService.logger.i('User data fetched: $data');
      userData.value = data;
    } else {
      LoggerService.logger.i('No user data found.');
    }
  }

  String maskString(String input) {
    if (input.length <= 3) return input;
    return input.substring(0, 3) + '*' * (input.length - 3);
  }

  Future<void> updateProfilePhoto(String imageHash) async {
    try {
      // Save the updated user data to local storage
      await LocalStorageService.saveUserData({
        'profile_photo': imageHash,
        'id_user': userData['id_user'],
      });
      // Update userData with the new imageHash
      userData.update('profile_photo', (value) => imageHash,
          ifAbsent: () => imageHash);
    } catch (e) {
      LoggerService.logger.i('Error updating profile photo: $e');
    }
  }

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

  Future<bool> getTheme() async {
    final db = await LocalStorageService.database;
    final user = await db
        .query('User', where: 'id_user = ?', whereArgs: [userData['id_user']]);
    if (user.isNotEmpty) {
      return user.first['isDarkMode'] == 1;
    }
    return false; // Default to light mode
  }

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

  Future<ImageProvider> getProfileImage(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      LoggerService.logger.i('Error decoding image: $e');
      return const AssetImage('assets/images/default_profile.png');
    }
  }

  void setBiometricEnabled(bool value) {
    isBiometricEnabled.value = value;
    // Save to local storage or database
    LocalStorageService.saveUserData({'isBiometricEnabled': value});
  }
}
