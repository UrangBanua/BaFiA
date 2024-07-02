import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bafia/models/user_model.dart';

class DBHelper {
  late Database _db;

  Future<Database> get db async {
    if (_db.isOpen) {
      return _db;
    } else {
      return await initDB();
    }
  }

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'baFia.db');

    return await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          phone TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE items (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE status (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          is_online INTEGER
        )
      ''');
    });
  }

  // AppStat tabel

  Future<void> insertItem(Map<String, dynamic> item) async {
    var dbClient = await db;
    await dbClient.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    var dbClient = await db;
    return await dbClient.query('items');
  }

  Future<void> setStatus(bool isOnline) async {
    var dbClient = await db;
    await dbClient.insert('status', {'is_online': isOnline ? 1 : 0});
  }

  Future<int> getStatus() async {
    var dbClient = await db;
    var result = await dbClient.query('status', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return result.first['is_online'] as int;
    }
    return 0; // Default to offline
  }

// User tabel

  Future<void> insertUser(Map<String, dynamic> user) async {
    _db = await db;
    await _db.insert('user', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser() async {
    _db = await db;
    List<Map<String, dynamic>> result =
        await _db.query('user', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<int> deleteUser(int id) async {
    _db = await db;
    return await _db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllUser() async {
    _db = await db;
    return await _db.delete('user');
  }
}
