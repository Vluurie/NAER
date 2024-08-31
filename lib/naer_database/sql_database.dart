import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:io';

class SqlDataBase {
  static final SqlDataBase _instance = SqlDataBase._internal();
  static Database? _database;

  factory SqlDataBase() {
    return _instance;
  }

  SqlDataBase._internal();

  Future<Database> get instance async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbDirectory;

    dbDirectory = File(Platform.resolvedExecutable).parent.path;

    final path = join(dbDirectory, 'NAER.db');

    print('Database path: $path');
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (final db, final version) async {
        await db.execute('''
        CREATE TABLE file_modifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          filePath TEXT UNIQUE,
          action TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE file_additions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          filePath TEXT UNIQUE,
          action TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE ignored_files (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fileName TEXT UNIQUE
        )
      ''');

        await db.execute('''
        CREATE TABLE preferences (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
      },
    );

// Write-Ahead Logging (WAL) mode in SQLite for faster and more efficient database operations.
// WAL mode improves performance by allowing concurrent read and write operations.
// Changes are written to a separate WAL file before being committed to the main database,
// reducing the need for database locking and ensuring that reads are not blocked by writes.
    await database.execute('PRAGMA journal_mode=WAL;');

    return database;
  }
}
