import 'package:NAER/naer_database/sql_database.dart';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseModificationTimeHandler {
  static Future<void> savePreModificationTime() async {
    final db = await SqlDataBase().instance;
    var bufferTime = const Duration(minutes: 60);
    var preRandomizationTime = DateTime.now().subtract(bufferTime);
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(preRandomizationTime);

    await db.insert(
        'preferences', {'key': 'pre_modification_time', 'value': formattedTime},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> saveLastModificationTime() async {
    final db = await SqlDataBase().instance;
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);

    await db.insert('preferences',
        {'key': 'last_modification_time', 'value': formattedTime},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<DateTime> getPreModificationTime() async {
    final db = await SqlDataBase().instance;
    final List<Map<String, dynamic>> result = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['pre_modification_time'],
    );

    if (result.isNotEmpty) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(result.first['value']);
    } else {
      return DateTime.now();
    }
  }
}
