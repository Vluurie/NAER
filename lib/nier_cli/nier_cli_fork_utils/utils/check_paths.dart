import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';

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
