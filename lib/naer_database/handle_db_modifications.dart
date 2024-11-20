import 'dart:io';
import 'package:NAER/naer_database/sql_database.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:sqflite/sqflite.dart';

/// Handles the logging, querying, and deletion of file modifications
/// (i.e., setups) in the database. This class interacts with the `file_modifications`
/// table in the database.
///
/// The `file_modifications` table stores records of files that have been modified
/// during the setup installation process. This allows the application to track
/// changes and potentially roll them back if needed.
class DatabaseModificationHandler {
  /// The path to the file that was modified.
  final String filePath;

  /// The type of action performed on the file (e.g., "create", "delete", "modify").
  final String action;

  /// A list that keeps track of all modifications made to files in memory.
  static List<DatabaseModificationHandler> modifications = [];

  DatabaseModificationHandler(this.filePath, this.action);

  /// Logs a file modification in memory for later database insertion.
  ///
  /// Checks if a modification record for the specified [filePath]
  /// and [action] already exists in the in-memory [modifications] list. If it
  /// doesn't exist, it adds it to the list.
  ///
  /// The actual database insertion is deferred until [batchInsertModificationsToDatabase]
  /// is called.
  static Future<void> logModificationForDatabase(
      final String filePath, final String action) async {
    final existingModification = modifications.firstWhere(
      (final modification) =>
          modification.filePath == filePath && modification.action == action,
      orElse: () => DatabaseModificationHandler('', ''),
    );

    if (existingModification.filePath.isEmpty) {
      final modification = DatabaseModificationHandler(filePath, action);
      modifications.add(modification);
    }
  }

  /// Deletes file modifications from the database and from the file system.
  ///
  /// This method queries the database for all modifications and attempts to delete
  /// each associated file from the file system. If the file deletion is successful,
  /// the corresponding database record is also deleted. The in-memory list of
  /// modifications is updated to reflect these deletions.
  static Future<void> deleteModifications() async {
    await queryModificationsFromDatabase();

    final db = await SqlDataBase().instance;
    List<DatabaseModificationHandler> modificationsToRemove = [];

    for (DatabaseModificationHandler modification in modifications.reversed) {
      try {
        var file = File(modification.filePath);

        if (await file.exists()) {
          try {
            await file.delete();
          } catch (deleteError, stackTrace) {
            ExceptionHandler().handle(deleteError, stackTrace);
            continue;
          }

          modificationsToRemove.add(modification);
          await db.delete(
            'file_modifications',
            where: 'filePath = ? AND action = ?',
            whereArgs: [modification.filePath, modification.action],
          );
        }
      } catch (e, stackTrace) {
        ExceptionHandler().handle(e, stackTrace,
            extraMessage:
                'Error during undoing modification for ${modification.filePath}');
      }
    }

    // Remove deleted modifications from the in-memory list.
    modifications.removeWhere(
        (final modification) => modificationsToRemove.contains(modification));
  }

  /// Queries all file modifications from the database and loads them into memory.
  ///
  /// This method retrieves all records from the `file_modifications` table and
  /// populates the in-memory [modifications] list with these records.
  static Future<void> queryModificationsFromDatabase() async {
    final db = await SqlDataBase().instance;
    final List<Map<String, dynamic>> maps =
        await db.query('file_modifications');

    // Populate the in-memory list with the results from the database query.
    modifications = List.generate(maps.length, (final i) {
      return DatabaseModificationHandler(
        maps[i]['filePath'],
        maps[i]['action'],
      );
    });
  }

  /// Inserts all in-memory modifications into the database in a single batch transaction.
  /// This method ensures that all modifications are saved efficiently, minimizing database overhead.
  static Future<void> batchInsertModificationsToDatabase() async {
    final db = await SqlDataBase().instance;

    if (modifications.isEmpty) {
      return;
    }

    try {
      await db.transaction((final txn) async {
        for (final modification
            in List<DatabaseModificationHandler>.from(modifications)) {
          await txn.insert(
            'file_modifications',
            modification._toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      modifications.clear();
    } catch (e, stackTrace) {
      ExceptionHandler()
          .handle(e, stackTrace, extraMessage: 'Batch insert failed');
    }
  }

  Map<String, dynamic> _toMap() {
    return {
      'filePath': filePath,
      'action': action,
    };
  }
}
