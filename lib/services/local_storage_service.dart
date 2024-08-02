import 'dart:io';
import 'package:flutter/foundation.dart';
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'logger_service.dart';

class LocalStorageService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // fungsi inisialisasi database
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
        databaseFactory = databaseFactoryFfi;
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

  // fungsi pembuatan tabel
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
        profile_photo TEXT DEFAULT '-',
        isDarkMode INTEGER DEFAULT 0,
        isBiometricEnabled INTEGER DEFAULT 0,
        time_update DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE dashboard (
        id_daerah INTEGER,
        tahun INTEGER,
        id_skpd INTEGER,
        kode_skpd TEXT,
        nama_skpd TEXT,
        anggaran_p REAL DEFAULT 0,
        anggaran_b REAL DEFAULT 0,
        realisasi_rencana_b REAL DEFAULT 0,
        realisasi_rill_p REAL DEFAULT 0,
        realisasi_rill_b REAL DEFAULT 0,
        time_update DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE notification (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        category TEXT,
        action TEXT DEFAULT 'n/a',
        link TEXT DEFAULT '#',
        date DATETIME DEFAULT CURRENT_TIMESTAMP,
        isRead TEXT DEFAULT 'false',
        time_update DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    LoggerService.logger.i('Tables created.');
    await _logTableStructure(db, 'user');
    await _logTableStructure(db, 'dashboard');
    await _logTableStructure(db, 'notification');
  }

  // fungsi penghapusan database
  static Future<void> deleteDatabase() async {
    final db = await database;
    await db.close();
    final path = await getDatabasesPath();
    final file = File('$path/bafia.db');
    await file.delete();
    LoggerService.logger.i("Database deleted.");
  }

  // fungsi logging struktur tabel
  static Future<void> _logTableStructure(Database db, String tableName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    LoggerService.logger.i('Structure of $tableName:');
    for (var row in result) {
      print(row);
    }
  }

  // fungsi pengambilan data user
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

  // fungsi penyimpanan data user
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final db = await database;
    LoggerService.logger.i("Saving user data");
    List<Map<String, dynamic>> existingUser = await db.query(
      'user',
      where: 'id_user = ?',
      whereArgs: [userData['id_user']],
    );
    if (existingUser.isNotEmpty) {
      await db.update(
        'user',
        userData,
        where: 'id_user = ?',
        whereArgs: [userData['id_user']],
      );
      LoggerService.logger.i("User data updated.");
    } else {
      await db.insert(
        'user',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.logger.i("User data inserted.");
    }
  }

  // fungsi penghapusan data user
  static Future<void> deleteUserData() async {
    final db = await database;
    await db.delete('user');
    LoggerService.logger.i("User data deleted.");
  }

  // fungsi penyimpanan data dashboard
  static Future<void> saveDashboardData(
      Database db, List<dynamic> dashboardData) async {
    for (var data in dashboardData) {
      await db.insert('dashboard', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      LoggerService.logger.i("Dashboard data saved: $data");
    }
  }

  // fungsi pengambilan data dashboard
  static Future<void> deleteDashboardData() async {
    final db = await database;
    await db.delete('dashboard');
    LoggerService.logger.i("Dashboard data cleared.");
  }

  // fungsi penyimpanan data notifikasi
  static Future<void> saveMessageData(Map<String, dynamic> messageData) async {
    final db = await database;
    LoggerService.logger.i("Saving message data");

    // Periksa apakah `messageData` memiliki `id`
    if (messageData.containsKey('id') && messageData['id'] != null) {
      List<Map<String, dynamic>> existingMessage = await db.query(
        'notification',
        where: 'id = ?',
        whereArgs: [messageData['id']],
      );

      if (existingMessage.isNotEmpty) {
        // Update data jika `id` sudah ada di database
        await db.update(
          'notification',
          messageData,
          where: 'id = ?',
          whereArgs: [messageData['id']],
        );
        LoggerService.logger.i("Message data updated.");
      } else {
        // Hapus `id` dari `messageData` sebelum insert
        messageData.remove('id');
        await db.insert(
          'notification',
          messageData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        LoggerService.logger.i("Message data inserted.");
      }
    } else {
      // Hapus `id` dari `messageData` sebelum insert
      messageData.remove('id');
      await db.insert(
        'notification',
        messageData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.logger.i("Message data inserted.");
    }
  }

  // fungsi penandaan notifikasi sebagai sudah dibaca
  static Future<void> markAsRead(int id) async {
    final db = await database;
    await db.update('notification', {'isRead': 'true'},
        where: 'id = ?', whereArgs: [id]);
    LoggerService.logger.i("Message data updated.");
  }

  // fungsi pengambilan data notifikasi
  static Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await database;
    LoggerService.logger.i("Fetching message data...");
    final List<Map<String, dynamic>> messages = await db.query('notification');
    if (messages.isNotEmpty) {
      LoggerService.logger.i("Get Data from DB - Message");
      return messages;
    }
    LoggerService.logger.i("No data found in DB.");
    return [];
  }

  // fungsi pengambilan data notifikasi yg belum dibaca
  static Future<List<Map<String, dynamic>>> getUnreadMessages() async {
    final db = await database;
    LoggerService.logger.i("Fetching unread message data...");
    final List<Map<String, dynamic>> messages = await db
        .query('notification', where: 'isRead = ?', whereArgs: ['false']);
    if (messages.isNotEmpty) {
      LoggerService.logger.i("Get Data from DB - Unread Message");
      return messages;
    }
    LoggerService.logger.i("No data found in DB.");
    return [];
  }

  // fungsi penghapusan data notifikasi
  static Future<void> deleteMessageData(int id) async {
    final db = await database;
    try {
      await db.delete('notification', where: 'id = ?', whereArgs: [id]);
      LoggerService.logger.i("Message data deleted.");
    } catch (e) {
      LoggerService.logger.e("Failed to delete message: $e");
    }
  }
}
