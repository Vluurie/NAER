import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class SharedPreferencesUtils {
  static Future<void> storeFileHash(
      String modId, String filePath, String fileHash) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('hash_$modId${path.basename(filePath)}', fileHash);
  }

  static Future<String?> getFileHash(String modId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hash_$modId${path.basename(filePath)}');
  }

  static Future<void> removeModHashes(String modId) async {
    final prefs = await SharedPreferences.getInstance();
    var keysToRemove = prefs.getKeys().where((k) => k.contains('hash_$modId'));
    for (var key in keysToRemove) {
      prefs.remove(key);
    }
  }

  static Future<void> printAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('All Shared Preferences:');
    prefs.getKeys().forEach((key) {
      var value = prefs.get(key);
      print('$key: $value');
    });
  }

  static Future<void> deleteAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
