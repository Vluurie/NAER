// ignore_for_file: avoid_print

import 'dart:io';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:path/path.dart' as path;

/// Retrieves the sorted enemies path from the list of arguments.
String? getSortedEnemyGroupsIdentifierMap(final List<String> arguments) {
  if (arguments.length >= 4) {
    return arguments[3];
  }
  return null;
}

/// Validates the provided paths for the sorted enemies file and output.
///
/// This function checks if the `sortedEnemyGroupsIdentifierMap` and `output` paths are valid.
/// If either path is null or invalid, it throws a [FileHandlingException] message.
void validateIdentifierAndOutput(
    final String? sortedEnemyGroupsIdentifierMap, final String? output) {
  try {
    if (sortedEnemyGroupsIdentifierMap == null ||
        sortedEnemyGroupsIdentifierMap.isEmpty) {
      throw const FileHandlingException(
          "The sorted enemies identifier is not specified. Please make sure the third argument is either 'CUSTOM_SELECTED' or 'ALL' to include all enemies.");
    }

    if (output == null || output.isEmpty) {
      throw const FileHandlingException(
          "The output path is not specified. Please make sure the second argument is the path where you want to save the results.");
    }
  } catch (e) {
    print('''
+-------------------------------------------------+
| Oops! Something went wrong with the paths.      |
+-------------------------------------------------+
| Possible Issues:                                |
| - The third argument (path to sorted enemies)   |
|   is missing or incorrect. Ensure it's either   |
|   an absolute path (e.g.,                       |
|   ../NAER_Settings/temp_sorted_enemies.dart) or |
|   the word 'ALL' to include all enemies.        |
| - The second argument (output path) is missing  |
|   or incorrect. Ensure it's the correct path    |
|   where you want to save the results.           |
+-------------------------------------------------+
| What to do:                                     |
| 1. Ensure the third argument is correct.        |
| 2. Ensure the second argument is correct.       |
| 3. Double-check both paths for typos or errors. |
+-------------------------------------------------+
| Error Details:                                  |
| $e                                              |
+-------------------------------------------------+
| If issues persist, seek further assistance.     |
+-------------------------------------------------+
''');
  }
}

/// Ensures that the settings directory exists, then constructs
/// the path to the mod metadata file ('mod_metadata.json') within the 'ModPackage'
/// directory. The path is logged for reference and returned as a string.
Future<String> getMetaDataPath() async {
  // Ensure the settings directory exists and get its path
  final String settingsDirectoryPath =
      await FileChange.ensureSettingsDirectory();

  // Construct the path to the mod metadata file
  final String metadataPath =
      path.join(settingsDirectoryPath, 'ModPackage', 'mod_metadata.json');

  // Log the found metadata path
  logAndPrint("Found metadata at $metadataPath for important Spawn ID's.");

  // Return the constructed metadata path
  return metadataPath;
}

/// Checks if the three folders (`naer_onlylevel`, `naer_randomized`,
/// `naer_randomized_and_level`) already exist in the given [baseDir].
bool checkIfExtractedFoldersExist(final String baseDir) {
  final onlyLevelDir = Directory(path.join(baseDir, 'naer_onlylevel'));
  final randomizedDir = Directory(path.join(baseDir, 'naer_randomized'));
  final randomizedAndLevelDir =
      Directory(path.join(baseDir, 'naer_randomized_and_level'));

  return onlyLevelDir.existsSync() &&
      randomizedDir.existsSync() &&
      randomizedAndLevelDir.existsSync();
}

/// Takes the [baseDir] and a [category] and returns the path
/// of the corresponding target directory. The category can be one of the
/// following: "onlylevel", "randomized", or "randomized_and_level".
String getTargetOptionDirectoryPath(
    final String baseDir, final String category) {
  switch (category) {
    case 'onlylevel':
      return path.join(baseDir, 'naer_onlylevel');
    case 'default':
      return path.join(baseDir, 'naer_randomized');
    case 'allenemies':
      return path.join(baseDir, 'naer_randomized_and_level');
    default:
      throw ArgumentError(
          'Invalid category: $category. Valid categories are "onlylevel", "randomized", and "randomized_and_level".');
  }
}

/// Determines the input directory for extracted game files based on enemy category.
String getExtractedOptionDirectories(final String outputDir, String inputDir,
    final Map<String, dynamic> argument) {
  final onlyLevelPath = getTargetOptionDirectoryPath(outputDir, 'onlylevel');
  final randomizedPath = getTargetOptionDirectoryPath(outputDir, 'default');
  final randomizedAndLevelPath =
      getTargetOptionDirectoryPath(outputDir, 'allenemies');

  if (argument['enemyCategory'] == 'onlylevel') {
    inputDir = onlyLevelPath;
  } else if (argument['enemyCategory'] == 'default') {
    inputDir = randomizedPath;
  } else if (argument['enemyCategory'] == 'allenemies') {
    inputDir = randomizedAndLevelPath;
  }
  return inputDir;
}

/// Takes the [directory] and checks if the following .cpk files exist:
/// 'data100.cpk', 'data006.cpk', 'data016.cpk', 'data002.cpk', 'data012.cpk'.
Future<bool> checkNotAllCpkFilesExist(final String directory) async {
  // Define the list of required file names
  final requiredFiles = [
    'data006.cpk',
    'data016.cpk',
    'data002.cpk',
    'data012.cpk',
    'data100.cpk'
  ];

  for (var fileName in requiredFiles) {
    final filePath = path.join(directory, fileName);
    final file = File(filePath);

    if (!await file.exists()) {
      return true;
    }
  }

  return false;
}

/// Checks if the DLC file 'data100.cpk' exists in the given directory and
/// if its size is approximately 928 MB (973,603,536 bytes) to determine if the DLC is present.
Future<bool> hasDLC(final String directoryPath) async {
  final Directory directory = Directory(directoryPath);
  const String fileName = 'data100.cpk';
  final File file = File('${directory.path}/$fileName');

  if (await file.exists()) {
    // Getting file size in bytes
    final int fileSize = await file.length();
    // 928 MB in bytes
    const int dlcSizeThreshold = 928 * 1024 * 1024; // 928 MB in bytes
    // Introducing a margin of error ±5 MB in bytes
    const int marginOfError = 5 * 1024 * 1024; // 5 MB in bytes
    // Upper limit to exclude sizes around 937 MB
    const int upperLimit = 937 * 1024 * 1024; // 937 MB in bytes

    // is approximately 928 MB and less than 937 MB
    return fileSize >= (dlcSizeThreshold - marginOfError) &&
        fileSize < upperLimit;
  }
  return false;
}
