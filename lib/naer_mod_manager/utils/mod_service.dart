import 'dart:convert';
import 'dart:io';

import 'package:NAER/naer_mod_manager/ui/mod_list.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:NAER/naer_utils/change_tracker.dart';

class ModService {
  Future<Set<String>> loadInstalledMods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> modIds = prefs.getStringList('installedModsIds') ?? [];
    return modIds.toSet();
  }

  Future<void> saveInstalledMods(List<String> modIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('installedModsIds', modIds);
  }

  Future<List<Mod>> fetchMods() async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final metadataPath = p.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final String metadataContent = await metadataFile.readAsString();
      final decoded = jsonDecode(metadataContent);

      List<dynamic> modsJson = decoded['mods'];
      return modsJson.map((modJson) => Mod.fromJson(modJson)).toList();
    } else {
      return [];
    }
  }
}
