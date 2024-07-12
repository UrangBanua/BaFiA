import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

import 'logger_service.dart';

final _logger = Logger('LocalStorageService');

class LocalStorageService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    LoggerService.logger.i('Initializing database...');
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      LoggerService.logger.i("Using web database");
      return await factory.openDatabase('bafia.db',
          options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi; // Tambahkan inisialisasi ini
        var factory = databaseFactoryFfi;
        String path = join(await getDatabasesPath(), 'bafia.db');
        LoggerService.logger.i("Using FFI database");
        return await factory.openDatabase(path,
            options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));
      } else {
        String path = join(await getDatabasesPath(), 'bafia.db');
        LoggerService.logger.i("Using mobile database");
        return await openDatabase(path, version: 1, onCreate: _onCreate);
      }
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    LoggerService.logger.i('Creating tables...');
    await db.execute('''
      CREATE TABLE user (
        id_user INTEGER PRIMARY KEY,
        username TEXT,
        password TEXT,
        tahun INTEGER,
        id_pegawai INTEGER,
        nama_pegawai TEXT DEFAULT '-',
        id_role INTEGER,
        nama_role TEXT,
        id_skpd INTEGER,
        kode_skpd INTEGER,
        nama_skpd TEXT,
        id_daerah INTEGER,
        nama_daerah TEXT DEFAULT '-',
        token TEXT,
        refresh_token TEXT,
        profile_photo TEXT DEFAULT '/assets/images/default_profile.png',
        isDarkMode INTEGER DEFAULT 0,
        time_update datetime DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE dashboard (
        id_daerah INTEGER,
        tahun INTEGER,
        id_skpd INTEGER,
        kode_skpd TEXT,
        nama_skpd TEXT,
        anggaran REAL,
        realisasi_rencana REAL,
        realisasi_rill REAL,
        time_update datetime DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    LoggerService.logger.i('Tables created.');
    await _logTableStructure(db, 'user');
    await _logTableStructure(db, 'dashboard');
  }

  static Future<void> deleteDatabase() async {
    final db = await database;
    await db.close();
    final path = await getDatabasesPath();
    final file = File('$path/bafia.db');
    await file.delete();
    LoggerService.logger.i("Database deleted.");
  }

  static Future<void> _logTableStructure(Database db, String tableName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    LoggerService.logger.i('Structure of $tableName:');
    for (var row in result) {
      LoggerService.logger.i(row);
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final db = await database;
    LoggerService.logger.i("Fetching user data...");
    final List<Map<String, dynamic>> maps = await db.query('user');
    if (maps.isNotEmpty) {
      LoggerService.logger.i("Get Data from DB - User");
      return maps.first;
    }
    LoggerService.logger.i("No data found in DB.");
    return null;
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final db = await database;
    LoggerService.logger.i("Saving user data");

    // Periksa apakah user dengan id_user sudah ada
    List<Map<String, dynamic>> existingUser = await db.query(
      'user',
      where: 'id_user = ?',
      whereArgs: [userData['id_user']],
    );

    if (existingUser.isNotEmpty) {
      // Jika user dengan id_user sudah ada, lakukan update
      await db.update(
        'user',
        userData,
        where: 'id_user = ?',
        whereArgs: [userData['id_user']],
      );
      LoggerService.logger.i("User data updated.");
    } else {
      // Jika user dengan id_user belum ada, lakukan insert
      await db.insert(
        'user',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.logger.i("User data inserted.");
    }
  }

  static Future<void> deleteUserData() async {
    final db = await database;
    await db.delete('user');
    LoggerService.logger.i("User data deleted.");
  }

  static Future<void> saveDashboardData(
      Database db, List<dynamic> dashboardData) async {
    for (var data in dashboardData) {
      await db.insert('dashboard', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      LoggerService.logger.i("Dashboard data saved: $data");
    }
  }

  static Future<void> deleteDashboardData() async {
    final db = await database;
    await db.delete('dashboard');
    LoggerService.logger.i("Dashboard data cleared.");
  }
}
