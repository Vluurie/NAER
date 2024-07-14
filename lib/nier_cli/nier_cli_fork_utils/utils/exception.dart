import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';

class FileHandlingException implements Exception {
  final String message;

  const FileHandlingException(this.message);

  @override
  String toString() => message;
}

/// Handles the errors encountered during file processing.
///
/// This function takes a list of error files and logs the errors.
/// If there are any files in the [errorFiles] list, it logs the number of failed files
/// and lists each file that failed to process. If there are no errors, it logs a success message.
///
/// [errorFiles] is a list of file paths that encountered errors during processing.
///
void handleExtractErrors(List<String> errorFiles) {
  if (errorFiles.isNotEmpty) {
    logAndPrint("Failed to extract ${errorFiles.length} files:");
    for (var file in errorFiles) {
      logAndPrint("- $file");
    }
  } else {
    logAndPrint("All files extracted successfully.");
  }
}
