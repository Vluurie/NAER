import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class SharedPreferencesUtils {
  static Future<void> storeFileHash(
      final String modId, final String filePath, final String fileHash) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hash_$modId${path.basename(filePath)}', fileHash);
  }

  static Future<String?> getFileHash(
      final String modId, final String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hash_$modId${path.basename(filePath)}');
  }

  static Future<void> removeModHashes(final String modId) async {
    final prefs = await SharedPreferences.getInstance();
    var keysToRemove =
        prefs.getKeys().where((final k) => k.contains('hash_$modId'));
    for (var key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  static Future<void> printAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('All Shared Preferences:');
    prefs.getKeys().forEach((final key) {
      var value = prefs.get(key);
      print('$key: $value');
    });
  }

  static Future<void> deleteAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
