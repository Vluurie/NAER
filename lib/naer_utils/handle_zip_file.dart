import 'dart:convert';
import 'dart:io';
import 'package:NAER/custom_naer_ui/mod__ui/mod_list.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

class ModHandler {
  static Future<List<Mod>?> handleZipFile(List<String> filePaths) async {
    if (filePaths.isEmpty) return null;
    var zipFilePath = filePaths.first;
    var package = path.basename(zipFilePath).contains("ModPackage");
    var bytes = File(zipFilePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    if (!package || !validateModPackageWithKeyFromArchive(archive)) {
      return null;
    }
    final modsDirectoryPath = await FileChange.ensureSettingsDirectory();
    String modDirectoryName = path.basenameWithoutExtension(zipFilePath);
    final modDirectoryPath = path.join(modsDirectoryPath, modDirectoryName);
    if (await extractZipToDirectory(archive, modDirectoryPath)) {
      return await parseModMetadata(modDirectoryPath);
    } else {
      return null;
    }
  }

  static bool validateModPackageWithKeyFromArchive(Archive archive) {
    const String keyFileName = 'validate_key.bin';
    const String knownValidKey = "key";
    for (final file in archive) {
      if (file.name.endsWith(keyFileName)) {
        String key = String.fromCharCodes(file.content as List<int>);
        if (key == knownValidKey) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  static Future<bool> extractZipToDirectory(
      Archive archive, String directoryPath) async {
    final modDirectory = Directory(directoryPath);
    if (!await modDirectory.exists()) {
      await modDirectory.create(recursive: true);
    }
    for (final file in archive) {
      String filePath = file.name;
      if (filePath.startsWith('ModPackage/')) {
        filePath = filePath.substring('ModPackage/'.length);
      }
      final outputPath = path.join(directoryPath, filePath);
      if (file.isFile) {
        final outputFile = File(outputPath);
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
    return true;
  }

  static Future<List<dynamic>?> readModMetadata(String directoryPath) async {
    final metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final metadataFile = File(metadataPath);
    if (await metadataFile.exists()) {
      final metadataContent = await metadataFile.readAsString();
      final List<dynamic> modsData = jsonDecode(metadataContent)['mods'];
      return modsData;
    } else {
      return null;
    }
  }

  static Future<List<Mod>> parseModMetadata(String directoryPath) async {
    final List<dynamic>? modsData = await readModMetadata(directoryPath);
    if (modsData == null) {
      return [];
    } else {
      final List<Mod> mods =
          modsData.map((modJson) => Mod.fromJson(modJson)).toList();
      return mods;
    }
  }
}
