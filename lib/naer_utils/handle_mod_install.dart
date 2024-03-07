// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/change_tracker.dart';

import 'package:crypto/crypto.dart';

class ModInstallHandler {
  final CLIArguments cliArguments;
  ModStateManager? modStateManager;

  ModInstallHandler({
    required this.cliArguments,
    this.modStateManager,
  });

  Future<String> computeFileHash(File file) async {
    var contents = await file.readAsBytes();
    var digest = sha256.convert(contents);
    return digest.toString();
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

  Future<void> markFilesRandomized(
      String modId, List<String> randomizedFilesPaths) async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final String metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      String metadataContent = await metadataFile.readAsString();
      Map<String, dynamic> metadata = jsonDecode(metadataContent);

      List<dynamic> mods = metadata['mods'];
      for (var mod in mods) {
        if (mod['id'] == modId) {
          List<dynamic> files = mod['files'];
          for (var file in files) {
            String adjustedFilePath = file['path'].contains('/')
                ? file['path'].substring(file['path'].indexOf('/') + 1)
                : file['path'];
            String fullPath =
                path.join(cliArguments.specialDatOutputPath, adjustedFilePath);
            String fileHash = await computeFileHash(File(fullPath));
            file['hash'] = fileHash;
            file['isRandomized'] = randomizedFilesPaths.contains(fullPath);
            file['isCopied'] = !randomizedFilesPaths.contains(fullPath);
          }
        }
      }

      await metadataFile.writeAsString(jsonEncode(metadata),
          mode: FileMode.write);
    }
  }

  Future<List<String>> verifyModFiles(String modId) async {
    List<String> filePaths = await extractFilePathsFromMetadata(modId);
    List<String> invalidFiles =
        []; // Tracks files that don't match their stored hashes

    for (String filePath in filePaths) {
      String installPath = await createModInstallPath(filePath);
      File fileToCheck = File(installPath);
      if (await fileToCheck.exists()) {
        String currentHash = await computeFileHash(fileToCheck);
        String? storedHash = await getFileHashFromPreferences(modId, filePath);
        if (currentHash != storedHash) {
          invalidFiles.add(filePath); // Add to list instead of breaking
        }
      } else {
        invalidFiles.add(filePath); // File doesn't exist
      }
    }

    return invalidFiles; // Return the list of invalid or missing files
  }

  Future<void> removeModFiles(String modId, List<String> invalidFiles) async {
    print(
        'Attempting to remove mod files for modId: $modId, except explicitly modified files.');

    final prefs = await SharedPreferences.getInstance();
    List<String> filePaths = await extractFilePathsFromMetadata(modId);

    bool deletedFiles = false;
    for (String filePath in filePaths) {
      String installPath = await createModInstallPath(filePath);
      // Convert the logic: if file is NOT in the invalidFiles, then delete
      if (!invalidFiles.contains(filePath)) {
        File file = File(installPath);
        if (await file.exists()) {
          try {
            await file.delete();
            print("Deleted file: $installPath as it's not modified by user.");
            deletedFiles = true;
          } catch (e) {
            print("Error deleting file $installPath: $e");
          }
        }
      }
    }

    if (deletedFiles) {
      // Remove related SharedPreferences entries for the mod
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
      parts.removeAt(
          0); // Assuming the first part is a common root to be replaced
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
        parts.removeAt(
            0); // Assuming the first part is a common root to be replaced
        String modifiedPath =
            path.join(cliArguments.specialDatOutputPath, path.joinAll(parts));
        modifiedPaths.add(modifiedPath);
      }
    }
    return modifiedPaths;
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
      // Filter out the mod with the given modId
      mods.removeWhere((mod) => mod['id'] == modId);
      // Update the metadata with the removed mod
      metadata['mods'] = mods;

      // Save the updated metadata back to the file
      await metadataFile.writeAsString(jsonEncode(metadata),
          mode: FileMode.write);
      print("Mod metadata for $modId deleted successfully.");
    } else {
      print("Mod metadata file not found.");
      return false;
    }
    return true;
  }

  Future<bool> deleteModDirectory(String modId) async {
    // Construct the path to the specific mod directory within the ModPackage folder
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
