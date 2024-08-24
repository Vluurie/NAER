import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';

class FileHandlingException implements Exception {
  final String message;

  const FileHandlingException(this.message);

  @override
  String toString() => message;
}

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
