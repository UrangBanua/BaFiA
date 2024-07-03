import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    print('Database not initialized, initializing now...');
    _database = await _initDB();
    print('Database initialized');
    return _database!;
  }

  static Future<Database> _initDB() async {
    if (kIsWeb) {
      print('Initializing database for web');
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase('bafia.db',
          options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        print('Initializing database for desktop');
        sqfliteFfiInit();
        var factory = databaseFactoryFfi;
        String path = join(await getDatabasesPath(), 'bafia.db');
        return await factory.openDatabase(path,
            options: OpenDatabaseOptions(version: 1, onCreate: _onCreate));
      } else {
        print('Initializing database for mobile');
        String path = join(await getDatabasesPath(), 'bafia.db');
        return await openDatabase(path, version: 1, onCreate: _onCreate);
      }
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    print('Creating tables');
    await db.execute('''
      CREATE TABLE user (
        username TEXT PRIMARY KEY,
        password TEXT,
        id_pegawai INTEGER,
        nama_pegawai TEXT,
        id_role INTEGER,
        nama_role TEXT,
        id_skpd INTEGER,
        nama_skpd TEXT,
        id_daerah INTEGER,
        nama_daerah TEXT,
        token TEXT,
        refresh_token TEXT
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
        realisasi_rill REAL
      )
    ''');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    print('Getting user data');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    print('Saving user data');
    final db = await database;
    await db.insert('user', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> saveDashboardData(
      Database db, List<dynamic> dashboardData) async {
    print('Saving dashboard data');
    for (var data in dashboardData) {
      await db.insert('dashboard', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
