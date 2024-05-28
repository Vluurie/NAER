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
  logAndPrint("Found metadata at $metadataPath");

  // Return the constructed metadata path
  return metadataPath;
}
