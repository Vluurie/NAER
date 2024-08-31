import 'package:NAER/naer_database/sql_database.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseIgnoredFilesHandler {
  /// The in memory ignored files list.
  static List<String> ignoredFiles = [];

  /// Saves the current list of ignored files to the database.
  ///First deletes any existing entries in the 'ignored_files' table,
  /// then inserts each file name from the in-memory list into the database,
  /// ensuring that the database accurately reflects the current ignored files.
  static Future<void> saveIgnoredFilesToDatabase() async {
    final db = await SqlDataBase().instance;

    await db.transaction((final txn) async {
      await txn.delete('ignored_files');

      for (final file in ignoredFiles) {
        await txn.insert(
          'ignored_files',
          {'fileName': file},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  ///Queries the database to retrieve the list of ignored files.
  /// Fetches all records from the 'ignored_files' table,
  /// converts them into a list of strings representing the file names,
  /// and updates the in-memory list to reflect the current state of the database.
  static Future<List<String>> queryIgnoredFilesFromDatabase() async {
    final db = await SqlDataBase().instance;
    final List<Map<String, dynamic>> maps = await db.query('ignored_files');

    return ignoredFiles =
        List.generate(maps.length, (final i) => maps[i]['fileName'] as String);
  }

  /// Removes files from the ignored files list both in memory and in the database.
  /// First loads the current ignored files from the database,
  /// then removes the specified files from the in-memory list,
  /// and finally updates the database to reflect these changes.
  static Future<void> queryAndRemoveIgnoredFiles(
      final List<String> filesToRemove) async {
    await queryIgnoredFilesFromDatabase();
    ignoredFiles.removeWhere((final file) => filesToRemove.contains(file));
    await saveIgnoredFilesToDatabase();
  }

  /// Inserts a new file into the ignored files list in the database.
  /// Before insertion, it checks if the file already exists in the database
  /// to avoid duplicates. If the file does not exist, it is added to the
  /// 'ignored_files' table.
  static Future<int> insertIgnoredFile(final String fileName) async {
    final db = await SqlDataBase().instance;

    final existing = await db.query(
      'ignored_files',
      where: 'fileName = ?',
      whereArgs: [fileName],
    );

    if (existing.isNotEmpty) {
      return 0;
    }

    return await db.insert('ignored_files', {'fileName': fileName});
  }
}
