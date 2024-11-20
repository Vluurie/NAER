import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/get_paths.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'file_utils.dart';
import 'shared_preferences_utils.dart';

class ModInstallHandler {
  final CLIArguments cliArguments;
  final ModStateManager? modStateManager;
  final FileUtils fileUtils;
  final SharedPreferencesUtils sharedPreferencesUtils;

  ModInstallHandler._internal({
    required this.cliArguments,
    this.modStateManager,
    required this.fileUtils,
    required this.sharedPreferencesUtils,
  });

  factory ModInstallHandler(final CLIArguments cliArguments,
      {final ModStateManager? modStateManager}) {
    final fileUtils = FileUtils();
    final sharedPreferencesUtils = SharedPreferencesUtils();
    return ModInstallHandler._internal(
      cliArguments: cliArguments,
      modStateManager: modStateManager,
      fileUtils: fileUtils,
      sharedPreferencesUtils: sharedPreferencesUtils,
    );
  }

  Future<List<String>> verifyModFiles(final String modId) async {
    final filePaths = await _extractFilePathsFromMetadata(modId);
    final fileHashes = await _fetchStoredFileHashes(modId, filePaths);

    final receivePort = ReceivePort();

    await Isolate.spawn(_verifyFilesInIsolate, [
      receivePort.sendPort,
      filePaths,
      fileHashes,
      cliArguments.specialDatOutputPath
    ]);

    return await receivePort.first;
  }

  Future<Map<String, String>> _fetchStoredFileHashes(
      final String modId, final List<String> filePaths) async {
    final fileHashes = <String, String>{};
    for (final filePath in filePaths) {
      final storedHash =
          await SharedPreferencesUtils.getFileHash(modId, filePath);
      if (storedHash != null) {
        fileHashes[filePath] = storedHash;
      }
    }
    return fileHashes;
  }

  Future<void> copyModToInstallPath(final String modId) async {
    final filePaths = await _extractFilePathsFromMetadata(modId);
    final directoryPath = "${await ensureSettingsDirectory()}/ModPackage";

    for (final filePath in filePaths) {
      final sourceFilePath = path.join(directoryPath, filePath);
      final sourceFile = File(sourceFilePath);
      final destinationFilePath = await createModInstallPath(filePath);
      final destinationFile = File(destinationFilePath);

      await destinationFile.parent.create(recursive: true);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationFilePath);
        final fileHash = await FileUtils.computeFileHash(destinationFile);
        await SharedPreferencesUtils.storeFileHash(modId, filePath, fileHash);
      }
    }
  }

  Future<void> uninstallMod(final String modId) async {
    final filePaths = await _extractFilePathsFromMetadata(modId);
    final installPaths = await createModInstallPaths(filePaths);

    for (final filePath in installPaths) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        await FileUtils.deleteEmptyParentDirectories(
            file.parent, cliArguments.specialDatOutputPath);
      }
    }

    await SharedPreferencesUtils.removeModHashes(modId);
  }

  Future<void> removeModFiles(
      final String modId, final List<String> invalidFiles) async {
    final filePaths = await _extractFilePathsFromMetadata(modId);
    var deletedFiles = false;

    for (final filePath in filePaths) {
      if (!invalidFiles.contains(filePath)) {
        final installPath = await createModInstallPath(filePath);
        final file = File(installPath);
        if (await file.exists()) {
          try {
            await file.delete();
            deletedFiles = true;
          } catch (e, stackTrace) {
            ExceptionHandler().handle(e, stackTrace,
                extraMessage: "Error deleting file $installPath");
          }
        }
      }
    }

    if (deletedFiles) {
      await SharedPreferencesUtils.removeModHashes(modId);
    }
  }

  Future<void> saveHashesForModFiles(final String modId) async {
    final filePaths = await _extractFilePathsFromMetadata(modId);

    for (final filePath in filePaths) {
      final installPath = await createModInstallPath(filePath);
      final fileToCheck = File(installPath);
      if (await fileToCheck.exists()) {
        final currentHash = await FileUtils.computeFileHash(fileToCheck);
        await SharedPreferencesUtils.storeFileHash(
            modId, filePath, currentHash);
      }
    }
  }

  Future<bool> deleteModMetadata(final String modId) async {
    final directoryPath = "${await ensureSettingsDirectory()}/ModPackage";
    final metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final metadataContent = await metadataFile.readAsString();
      final metadata = jsonDecode(metadataContent) as Map<String, dynamic>;
      final mods = metadata['mods'] as List<dynamic>;
      mods.removeWhere((final mod) => mod['id'] == modId);
      metadata['mods'] = mods;

      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(metadata);

      await metadataFile.writeAsString(prettyJson);
      return true;
    }
    return false;
  }

  Future<bool> deleteModDirectory(final String modId) async {
    final modDirectoryPath =
        path.join(await ensureSettingsDirectory(), "ModPackage", modId);
    final modDirectory = Directory(modDirectoryPath);
    if (await modDirectory.exists()) {
      await modDirectory.delete(recursive: true);
      return true;
    }
    return false;
  }

  Future<List<String>> _extractFilePathsFromMetadata(final String modId) async {
    final directoryPath = "${await ensureSettingsDirectory()}/ModPackage";
    final metadataPath = path.join(directoryPath, 'mod_metadata.json');
    final metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final metadataContent = await metadataFile.readAsString();
      final modsData = jsonDecode(metadataContent)['mods'] as List<dynamic>;
      for (final mod in modsData) {
        if (mod['id'] == modId) {
          return (mod['files'] as List<dynamic>).map<String>((final file) {
            final filePath = file['path'];
            if (filePath is String) {
              return filePath;
            } else {
              throw Exception("File path is not a string");
            }
          }).toList();
        }
      }
    }
    return [];
  }

  Future<String> createModInstallPath(final String filePath) async {
    final parts = path.split(filePath);
    if (parts.isNotEmpty) {
      parts.removeAt(0);
      return path.join(cliArguments.specialDatOutputPath, path.joinAll(parts));
    }
    return '';
  }

  Future<List<String>> createModInstallPaths(
      final List<String> filePaths) async {
    final modifiedPaths = <String>[];
    for (final filePath in filePaths) {
      final parts = path.split(filePath);
      if (parts.isNotEmpty) {
        parts.removeAt(0);
        final modifiedPath =
            path.join(cliArguments.specialDatOutputPath, path.joinAll(parts));
        modifiedPaths.add(modifiedPath);
      }
    }
    return modifiedPaths;
  }
}

// The function that runs in the isolate every 15 seconds.
void _verifyFilesInIsolate(final List<dynamic> args) async {
  final sendPort = args[0] as SendPort;
  final filePaths = args[1] as List<String>;
  final fileHashes = args[2] as Map<String, String>;
  final specialDatOutputPath = args[3] as String;

  final invalidFiles = <String>[];

  for (final filePath in filePaths) {
    final installPath = path.join(
        specialDatOutputPath, path.joinAll(path.split(filePath)..removeAt(0)));
    final fileToCheck = File(installPath);
    if (await fileToCheck.exists()) {
      final currentHash = await FileUtils.computeFileHash(fileToCheck);
      final storedHash = fileHashes[filePath];
      if (currentHash != storedHash) {
        invalidFiles.add(filePath);
      }
    } else {
      invalidFiles.add(filePath);
    }
  }

  // Send the result back to the main isolate.
  sendPort.send(invalidFiles);
}
