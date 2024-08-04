import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:path/path.dart';

/// List of specific folder names to be deleted.
///
/// This list contains the names of folders that should be deleted from the output directory.
List<String> folderNames = [
  'data002.cpk_extracted',
  'data012.cpk_extracted',
  'data100.cpk_extracted',
  'data016.cpk_extracted',
  'data006.cpk_extracted',
  "st5/nier2blender_extracted",
  "st2/nier2blender_extracted",
  "st1/nier2blender_extracted",
  "quest/nier2blender_extracted",
  "ph4/nier2blender_extracted",
  "ph3/nier2blender_extracted",
  "ph2/nier2blender_extracted",
  "ph1/nier2blender_extracted",
  "em/nier2blender_extracted",
  "core/nier2blender_extracted",
  "nier2blender_extracted",
];

List<String> backupNames = [
  'naer_onlylevel',
  'naer_randomized',
  'naer_randomized_and_level',
];

/// Deletes specified folders from the given directory.
///
/// This function iterates over the hardcoded [folderNames] list, constructs the full path for each folder,
/// checks if the folder exists, and if so, deletes it. It prints a message for each deleted folder
/// or an error message if the deletion fails.
///
/// [directoryPath] is the base directory from which the folders will be deleted.
///
/// Hardcoded usage:
/// ```dart
/// await deleteFolders( [
///  'data002.cpk_extracted',
///   'data012.cpk_extracted',
///   'data100.cpk_extracted',
///   'data016.cpk_extracted',
///   'data006.cpk_extracted',
///   "st5/nier2blender_extracted",
///   "st2/nier2blender_extracted",
///   "st1/nier2blender_extracted",
///   "quest/nier2blender_extracted",
///   "ph4/nier2blender_extracted",
///   "ph3/nier2blender_extracted",
///   "ph2/nier2blender_extracted",
///   "ph1/nier2blender_extracted",
///   "em/nier2blender_extracted",
///   "core/nier2blender_extracted",
///   "nier2blender_extracted",
/// ]);
/// ```
Future<void> deleteExtractedGameFolders(String directoryPath) async {
  for (var folderName in folderNames) {
    var folderPath = Directory(join(directoryPath, folderName));
    if (await folderPath.exists()) {
      try {
        await folderPath.delete(recursive: true);
        globalLog('Deleted folder: $folderName');
      } catch (e) {
        logAndPrint('Error deleting folder $folderName: $e');
      }
    }
  }
}

Future<void> deleteBackupGameFolders(String directoryPath) async {
  var parentDirectory = Directory(directoryPath).parent.path;
  for (var folderName in backupNames) {
    var folderPath = Directory(join(parentDirectory, folderName));
    if (await folderPath.exists()) {
      try {
        await folderPath.delete(recursive: true);
        globalLog('Deleted folder: $folderName');
      } catch (e) {
        logAndPrint('Error deleting folder $folderName: $e');
      }
    }
  }
}

/// Validates if the specified extracted game folders have been deleted.
///
/// This function iterates over the [folderNames] list,
/// constructs the full path for each folder, checks if the folder exists,
/// and returns `true` if all folders are deleted, `false` otherwise.
///
/// [directoryPath] is the base directory from which the folders will be checked.
Future<bool> validateExtractedFolderDeletion(String directoryPath) async {
  for (var folderName in folderNames) {
    var folderPath = Directory(join(directoryPath, folderName));
    if (await folderPath.exists()) {
      return false;
    }
  }
  return true;
}
