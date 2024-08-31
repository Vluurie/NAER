import 'package:NAER/naer_database/sql_database.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseDLCHandler {
  /// Loads the DLC option from the database and updates the global state based on the result.
  static Future<void> loadDLCOption(final WidgetRef ref) async {
    final db = await SqlDataBase().instance;
    final result = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: ['dlc'],
    );

    final hasDLC = result.isNotEmpty && result.first['value'] == 'true';
    ref.watch(globalStateProvider.notifier).updateDLCOption(update: hasDLC);
  }

  /// Saves the DLC option to the database and updates the global state.
  static Future<void> saveDLCOption(final WidgetRef ref,
      {required final bool shouldSave}) async {
    final db = await SqlDataBase().instance;

    await db.insert(
        'preferences', {'key': 'dlc', 'value': shouldSave.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace);

    ref.watch(globalStateProvider.notifier).updateDLCOption(update: shouldSave);
  }
}
