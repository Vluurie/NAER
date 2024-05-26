/// Converts a [Duration] to a human-readable string format.
///
/// This function takes a [Duration] and returns a string representation of
/// the duration in milliseconds (ms), seconds (s), or minutes and seconds (m s)
/// depending on the length of the duration.
///
/// - Parameter d: The duration to be converted.
/// - Returns: A string representation of the duration.
String timeStr(Duration d) {
  var ms = d.inMilliseconds;
  if (ms < 1000) {
    return "${ms}ms";
  } else if (ms < 60000)
    // ignore: curly_braces_in_flow_control_structures
    return "${(ms / 1000).toStringAsFixed(2)}s";
  else {
    var m = d.inMinutes;
    var s = (ms / 1000) % 60;
    return "${m}m ${s.toStringAsFixed(2)}s";
  }
}

/// Processes and prints the time taken to process files along with a summary.
///
/// This function calculates the time difference between the current time and
/// the start time [t1]. It then prints the duration and a summary of the
/// processed files, including any errors encountered.
///
/// - Parameters:
///   - t1: The start time when the processing began.
///   - processedFiles: A set of files that have been successfully processed.
///   - errorFiles: A list of files that encountered errors during processing.
void processTime(
    DateTime t1, Set<String> processedFiles, List<String> errorFiles) {
  var tD = DateTime.now().difference(t1);
  if (processedFiles.length == 1) {
    print("Done (${timeStr(tD)}) :D");
  } else {
    if (errorFiles.isNotEmpty) {
      print("Failed to process ${errorFiles.length} files:");
      for (var f in errorFiles) {
        print("- $f");
      }
    }
  }
  print("Processed ${processedFiles.length} files "
      "in ${timeStr(tD)} "
      ":D");
}
