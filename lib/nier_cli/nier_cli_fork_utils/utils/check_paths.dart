import 'dart:io';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:path/path.dart' as path;

/// Retrieves the sorted enemies path from the list of arguments.
///
/// This function checks if the list of arguments contains at least four elements
/// and returns the fourth element if it exists. Otherwise, it returns null.
///
/// - Parameter arguments: The list of command-line arguments.
/// - Returns: The sorted enemies path if it exists, otherwise null.
String? getSortedEnemiesPath(List<String> arguments) {
  if (arguments.length >= 4) {
    return arguments[3];
  }
  return null;
}

/// Validates the provided paths for sorted enemies and output.
///
/// This function checks if the `sortedEnemiesPath` and `output` paths are valid.
/// If either path is null or invalid, it throws a [FileHandlingException].
///
/// - Parameters:
///   - sortedEnemiesPath: The path to the sorted enemies file.
///   - output: The output path where results should be saved.
/// - Throws: [FileHandlingException] if either path is invalid.
void validatePaths(String? sortedEnemiesPath, String? output) {
  if (sortedEnemiesPath == null || sortedEnemiesPath.isEmpty) {
    throw const FileHandlingException("Sorted enemies file path not specified");
  }

  if (output == null) {
    throw const FileHandlingException("Output path not specified");
  }
}

/// Asynchronously retrieves the file path to the mod metadata.
///
/// This function ensures that the settings directory exists, then constructs
/// the path to the mod metadata file ('mod_metadata.json') within the 'ModPackage'
/// directory. The path is logged for reference and returned as a string.
///
/// Returns:
/// A `Future<String>` that completes with the file path to the mod metadata.
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

/// Checks if the specified directories exist.
///
/// This function checks if the three folders (`naer_onlylevel`, `naer_randomized`,
/// `naer_randomized_and_level`) already exist in the given [baseDir].
///
/// [baseDir] is the base directory to check for the existence of the folders.
///
/// Returns `true` if all three folders exist, `false` otherwise.
bool checkIfExtractedFoldersExist(String baseDir) {
  final onlyLevelDir = Directory(path.join(baseDir, 'naer_onlylevel'));
  final randomizedDir = Directory(path.join(baseDir, 'naer_randomized'));
  final randomizedAndLevelDir =
      Directory(path.join(baseDir, 'naer_randomized_and_level'));

  return onlyLevelDir.existsSync() &&
      randomizedDir.existsSync() &&
      randomizedAndLevelDir.existsSync();
}

/// Returns the path of the target option directory based on the specified category.
///
/// This function takes the [baseDir] and a [category] and returns the path
/// of the corresponding target directory. The category can be one of the
/// following: "onlylevel", "randomized", or "randomized_and_level".
///
/// [baseDir] is the base directory where the target directories are located.
/// [category] is the category specifying which target directory to return.
///
/// Returns the path of the target directory if the category is valid, otherwise
/// throws an [ArgumentError].
String getTargetOptionDirectoryPath(String baseDir, String category) {
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
///
/// [outputDir] is the output directory where the extracted game files are stored.
/// [argument] is a map containing various parameters including enemy category.
/// [inputDir] is the directory containing the game files to be processed.
///
/// Returns the updated input directory based on the enemy category.
String getExtractedOptionDirectories(
    String outputDir, String inputDir, Map<String, dynamic> argument) {
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

/// Checks if all specified .cpk files exist in the directory.
///
/// This function takes the [directory] and checks if the following .cpk files exist:
/// 'data100.cpk', 'data006.cpk', 'data016.cpk', 'data002.cpk', 'data012.cpk'.
///
/// Returns `true` if all files exist, `false` otherwise.
Future<bool> checkNotAllCpkFilesExist(String directory) async {
  // Define the list of required file names
  final requiredFiles = [
    'data006.cpk',
    'data016.cpk',
    'data002.cpk',
    'data012.cpk',
  ];

  // Check if each file exists in the directory
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
/// if its size is approximately 937 MB to determine if the DLC is present.
///
/// - Parameters:
///   - directoryPath: The path of the directory to search in.
///
/// - Returns: true if the file exists and its size is approximately 937 MB, false otherwise.
Future<bool> hasDLC(String directoryPath) async {
  final Directory directory = Directory(directoryPath);
  const String fileName = 'data100.cpk';
  final File file = File('${directory.path}/$fileName');

  if (await file.exists()) {
    // Getting file size in bytes
    final int fileSize = await file.length();
    // 937 MB in bytes
    const int dlcSizeThreshold = 937 * 1024 * 1024; // 937 MB in bytes
    // Introducing a margin of error ±10 MB in bytes
    const int marginOfError = 5 * 1024 * 1024; // 5 MB in bytes

    // Check if the file size is within the range
    return fileSize >= (dlcSizeThreshold - marginOfError) &&
        fileSize <= (dlcSizeThreshold + marginOfError);
  }
  return false;
}
