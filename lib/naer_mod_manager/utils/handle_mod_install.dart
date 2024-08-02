// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/change_tracker.dart';

class ModInstallHandler {
  final CLIArguments cliArguments;
  ModStateManager? modStateManager;

  ModInstallHandler({
    required this.cliArguments,
    this.modStateManager,
  });

  Future<String> computeFileHash(File file) async {
    try {
      var contents = await file.readAsBytes();
      var digest = sha256.convert(contents);
      return digest.toString();
    } catch (e) {
      print("Error computing file hash: $e");
      return "ERROR_COMPUTING_HASH";
    }
  }

  Future<void> storeFileHashInPreferences(
      String modId, String filePath, String fileHash) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('hash_$modId${path.basename(filePath)}', fileHash);
  }

  Future<String?> getFileHashFromPreferences(
      String modId, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('hash_$modId${path.basename(filePath)}');
  }

  Future<void> copyModToInstallPath(String modId) async {
    List<String> filePaths = await extractFilePathsFromMetadata(modId);
    String directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";

    for (String filePath in filePaths) {
      String sourceFilePath = path.join(directoryPath, filePath);
      File sourceFile = File(sourceFilePath);
      String destinationFilePath = await createModInstallPath(filePath);
      File destinationFile = File(destinationFilePath);

      await destinationFile.parent.create(recursive: true);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationFilePath);
        String fileHash = await computeFileHash(destinationFile);
        await storeFileHashInPreferences(modId, filePath, fileHash);
      }
    }
  }

  Future<void> uninstallMod(String modId) async {
    List<String> filePaths = await extractFilePathsFromMetadata(modId);
    List<String> installPaths = await createModInstallPaths(filePaths);

    for (String filePath in installPaths) {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        await _deleteEmptyParentDirectories(file.parent);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    var keysToRemove = prefs.getKeys().where((k) => k.contains('hash_$modId'));
    for (var key in keysToRemove) {
      prefs.remove(key);
    }
  }

  Future<List<String>> extractFilePathsFromMetadata(String modId) async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final String metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final String metadataContent = await metadataFile.readAsString();
      final List<dynamic> modsData = jsonDecode(metadataContent)['mods'];
      for (var mod in modsData) {
        if (mod['id'] == modId) {
          return mod['files'].map<String>((file) {
            final path = file['path'];
            if (path is String) {
              return path;
            } else {
              throw Exception("File path is not a string");
            }
          }).toList();
        }
      }
    }
    return [];
  }

  Future<String> getMetaDataPath() async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final metadataPath = path.join(directoryPath, 'mod_metadata.json');
    print("Found metadata at $metadataPath");
    return metadataPath;
  }

  Future<List<String>> verifyModFiles(String modId) async {
    List<String> filePaths = await extractFilePathsFromMetadata(modId);
    List<String> invalidFiles = [];

    for (String filePath in filePaths) {
      String installPath = await createModInstallPath(filePath);
      File fileToCheck = File(installPath);
      if (await fileToCheck.exists()) {
        String currentHash = await computeFileHash(fileToCheck);
        String? storedHash = await getFileHashFromPreferences(modId, filePath);
        if (currentHash != storedHash) {
          invalidFiles.add(filePath);
        }
      } else {
        invalidFiles.add(filePath);
      }
    }

    return invalidFiles;
  }

  Future<void> removeModFiles(String modId, List<String> invalidFiles) async {
    print(
        'Attempting to remove mod files for modId: $modId, except explicitly modified files.');

    final prefs = await SharedPreferences.getInstance();
    List<String> filePaths = await extractFilePathsFromMetadata(modId);

    bool deletedFiles = false;
    for (String filePath in filePaths) {
      String installPath = await createModInstallPath(filePath);

      if (!invalidFiles.contains(filePath)) {
        File file = File(installPath);
        if (await file.exists()) {
          try {
            await file.delete();
            print(
                "Deleted file: $installPath as it matched modId's file list.");
            deletedFiles = true;
          } catch (e) {
            print("Error deleting file $installPath: $e");
          }
        }
      }
    }

    if (deletedFiles) {
      var keysToRemove =
          prefs.getKeys().where((k) => k.contains('hash_$modId'));
      for (var key in keysToRemove) {
        prefs.remove(key);
      }
      print(
          "Completed cleanup for modId: $modId, preserving user-modified files.");
    } else {
      print(
          "No files were deleted for modId: $modId. Possibly already clean or files were user-modified.");
    }
  }

  Future<void> _deleteEmptyParentDirectories(Directory directory) async {
    if (directory.path == cliArguments.specialDatOutputPath) {
      return;
    }
    if (await directory.list().isEmpty) {
      await directory.delete();
      await _deleteEmptyParentDirectories(directory.parent);
    }
  }

  Future<String> createModInstallPath(String filePath) async {
    List<String> parts = path.split(filePath);
    if (parts.isNotEmpty) {
      parts.removeAt(0);
      String modifiedPath =
          path.join(cliArguments.specialDatOutputPath, path.joinAll(parts));
      return modifiedPath;
    }
    return '';
  }

  Future<List<String>> createModInstallPaths(List<String> filePaths) async {
    List<String> modifiedPaths = [];
    for (String filePath in filePaths) {
      List<String> parts = path.split(filePath);
      if (parts.isNotEmpty) {
        parts.removeAt(0);
        String modifiedPath =
            path.join(cliArguments.specialDatOutputPath, path.joinAll(parts));
        modifiedPaths.add(modifiedPath);
      }
    }
    return modifiedPaths;
  }

  Future<void> saveHashesForModFiles(String modId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> filePaths = await extractFilePathsFromMetadata(modId);

    for (String filePath in filePaths) {
      String installPath = await createModInstallPath(filePath);
      File fileToCheck = File(installPath);
      if (await fileToCheck.exists()) {
        String currentHash = await computeFileHash(fileToCheck);
        String hashKey = 'hash_${modId}_$filePath';
        await prefs.setString(hashKey, currentHash);
        print("Saved hash for file: $filePath");
      } else {
        print(
            "File does not exist at install path: $installPath, skipping hash saving.");
      }
    }
    print("Completed saving hashes for modId: $modId.");
  }

  Future<bool> deleteModMetadata(String modId) async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      String metadataContent = await metadataFile.readAsString();
      Map<String, dynamic> metadata = jsonDecode(metadataContent);
      List<dynamic> mods = metadata['mods'];
      mods.removeWhere((mod) => mod['id'] == modId);
      metadata['mods'] = mods;

      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String prettyJson = encoder.convert(metadata);

      await metadataFile.writeAsString(prettyJson, mode: FileMode.write);
      print("Mod metadata for $modId deleted successfully.");
    } else {
      print("Mod metadata file not found.");
      return false;
    }
    return true;
  }

  Future<bool> deleteModDirectory(String modId) async {
    final String modDirectoryPath = path.join(
      await FileChange.ensureSettingsDirectory(),
      "ModPackage",
      modId,
    );

    final Directory modDirectory = Directory(modDirectoryPath);
    if (await modDirectory.exists()) {
      await modDirectory.delete(recursive: true);
      return true;
    }
    return false;
  }

  Future<void> printAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('All Shared Preferences:');
    prefs.getKeys().forEach((key) {
      var value = prefs.get(key);
      print('$key: $value');
    });
  }

  Future<void> deleteAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('All Shared Preferences:');
    prefs.getKeys().forEach((key) {
      var value = prefs.clear();
      print('$key: $value');
    });
  }
}
