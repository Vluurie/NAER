import 'dart:io';
import 'package:NAER/naer_database/sql_database.dart';
import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Handles the logging, querying, and deletion of file additions
/// in the database. This class interacts with the `file_additions` table
/// in the database.
///
/// The `file_additions` table stores records of files that have been added
/// during the addition installation process. This allows the application to track
/// these changes and potentially roll them back if needed.
class DatabaseAdditionHandler {
  /// The path to the file that was added.
  final String filePath;

  /// The type of action performed on the file (e.g., "create", "delete", "modify").
  final String action;

  /// A list that keeps track of all additions made to files in memory.
  static List<DatabaseAdditionHandler> additions = [];

  DatabaseAdditionHandler(this.filePath, this.action);

  /// Logs a file addition in memory for later database insertion.
  ///
  /// Checks if an addition record for the specified [filePath]
  /// and [action] already exists in the in-memory [additions] list. If it
  /// doesn't exist, it adds it to the list.
  ///
  /// The actual database insertion is deferred until [batchInsertAdditionsToDatabase]
  /// is called.
  static Future<void> logAdditionForDatabase(
      final String filePath, final String action) async {
    final existingAddition = additions.firstWhere(
      (final addition) =>
          addition.filePath == filePath && addition.action == action,
      orElse: () => DatabaseAdditionHandler('', ''),
    );

    if (existingAddition.filePath.isEmpty) {
      final addition = DatabaseAdditionHandler(filePath, action);
      additions.add(addition);
    }
    if (!DatabaseIgnoredFilesHandler.ignoredFiles
        .contains(path.basename(filePath))) {
      String ignoredAdditionFiles = path.basename(filePath);
      DatabaseIgnoredFilesHandler.ignoredFiles.add(ignoredAdditionFiles);
      await DatabaseIgnoredFilesHandler.insertIgnoredFile(ignoredAdditionFiles);
    }
  }

  /// Deletes file additions from the database and from the file system.
  ///
  /// This method queries the database for all additions and attempts to delete
  /// each associated file from the file system. If the file deletion is successful,
  /// the corresponding database record is also deleted. The in-memory list of
  /// additions is updated to reflect these deletions.
  static Future<void> deleteAdditions() async {
    await queryAdditionsFromDatabase();
    await DatabaseIgnoredFilesHandler.queryIgnoredFilesFromDatabase();

    final db = await SqlDataBase().instance;
    List<DatabaseAdditionHandler> additionsToRemove = [];

    for (DatabaseAdditionHandler addition in additions.reversed) {
      try {
        if (!DatabaseIgnoredFilesHandler.ignoredFiles
            .contains(addition.filePath)) {
          var file = File(addition.filePath);

          if (await file.exists()) {
            try {
              await file.delete();
            } catch (deleteError, stackTrace) {
              ExceptionHandler().handle(deleteError, stackTrace);
              continue;
            }

            if (!await file.exists()) {
              String ignoredAdditionFile = path.basename(addition.filePath);
              DatabaseIgnoredFilesHandler.ignoredFiles
                  .remove(ignoredAdditionFile);
            }
          }
          additionsToRemove.add(addition);
          await db.delete(
            'file_additions',
            where: 'filePath = ? AND action = ?',
            whereArgs: [addition.filePath, addition.action],
          );
        }
      } catch (e, stackTrace) {
        ExceptionHandler().handle(e, stackTrace);
      }
    }

    additions
        .removeWhere((final addition) => additionsToRemove.contains(addition));

    await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();
  }

  /// Queries all file additions from the database and loads them into memory.
  ///
  /// This method retrieves all records from the `file_additions` table and
  /// populates the in-memory [additions] list with these records.
  static Future<void> queryAdditionsFromDatabase() async {
    final db = await SqlDataBase().instance;
    final List<Map<String, dynamic>> maps = await db.query('file_additions');

    additions = List.generate(maps.length, (final i) {
      return DatabaseAdditionHandler(
        maps[i]['filePath'],
        maps[i]['action'],
      );
    });
  }

  /// Inserts all in-memory additions into the database in a single batch transaction.
  /// This method ensures that all additions are saved efficiently, minimizing database overhead.
  static Future<void> batchInsertAdditionsToDatabase() async {
    final db = await SqlDataBase().instance;

    if (additions.isEmpty) {
      return;
    }

    try {
      await db.transaction((final txn) async {
        for (final addition in List<DatabaseAdditionHandler>.from(additions)) {
          await txn.insert(
            'file_additions',
            addition._toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      additions.clear();
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace);
    }
  }

  /// Deletes matching rows from `file_modifications` if they exist in `file_additions`.
  static Future<void> deleteMatchingModifications() async {
    final db = await SqlDataBase().instance;

    try {
      final List<Map<String, dynamic>> additions = await db.query(
        'file_additions',
        orderBy: 'LOWER(filePath), LOWER(action)',
      );

      final List<Map<String, dynamic>> modifications = await db.query(
        'file_modifications',
        orderBy: 'LOWER(filePath), LOWER(action)',
      );

      for (var addition in additions) {
        try {
          final matchingModification = modifications.firstWhere(
            (final mod) =>
                mod['filePath'].toString().trim().toLowerCase() ==
                    addition['filePath'].toString().trim().toLowerCase() &&
                mod['action'].toString().trim().toLowerCase() ==
                    addition['action'].toString().trim().toLowerCase(),
            orElse: () => {},
          );

          if (matchingModification.isNotEmpty) {
            await db.delete(
              'file_modifications',
              where: 'LOWER(filePath) = ? AND LOWER(action) = ?',
              whereArgs: [
                addition['filePath'].toString().trim().toLowerCase(),
                addition['action'].toString().trim().toLowerCase()
              ],
            );
          }
        } catch (e, stackTrace) {
          ExceptionHandler().handle(e, stackTrace,
              extraMessage:
                  'Error deleting modification for filePath: ${addition['filePath']} and action: ${addition['action']}.');
        }
      }
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace,
          extraMessage:
              'Error querying file_additions or file_modifications table.');
    }
  }

  Map<String, dynamic> _toMap() {
    return {
      'filePath': filePath,
      'action': action,
    };
  }
}
