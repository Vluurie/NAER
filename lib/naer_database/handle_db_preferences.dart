import 'package:NAER/naer_database/sql_database.dart';
import 'package:NAER/naer_utils/global_log.dart';

class DatabasePreferenceHandler {
  static Future<void> deleteAllPreferences() async {
    final db = await SqlDataBase().instance;
    final List<String> keys = (await db.query('preferences'))
        .map((final e) => e['key'] as String)
        .toList();

    bool undoPossible = true;

    for (String key in keys) {
      final int result = await db.delete(
        'preferences',
        where: 'key = ?',
        whereArgs: [key],
      );

      String formattedKey = _formatKey(key);
      globalLog(
          '$formattedKey: ${result > 0 ? "Successfully deleted." : "Failed to delete."}');

      if (key == 'file_changes' && result > 0) {
        undoPossible = false;
      }
    }

    globalLog(
        'All data cleared and state removed: ${keys.isNotEmpty ? "Yes" : "Failed to clear all data."}');

    if (!undoPossible) {
      globalLog(
          'Undo functionality is no longer up to date as "File Changes" data has been deleted.');
    }
  }

  static String _formatKey(final String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((final word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
