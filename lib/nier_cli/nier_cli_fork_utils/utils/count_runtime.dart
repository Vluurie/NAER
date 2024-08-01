import 'dart:isolate';

import 'package:NAER/naer_utils/global_log.dart';

/// Util class for counting runtime of single methods or full processing time.
class CountRuntime {
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
    } else if (ms < 60000) {
      return "${(ms / 1000).toStringAsFixed(2)}s";
    } else {
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
  void processTime(DateTime t1, Set<String> processedFiles,
      List<String> errorFiles, SendPort sendPort) {
    var tD = DateTime.now().difference(t1);
    if (processedFiles.length == 1) {
      sendPort.send("Done (${timeStr(tD)}) :D");
    } else {
      if (errorFiles.isNotEmpty) {
        sendPort.send("Failed to process ${errorFiles.length} files:");
        for (var f in errorFiles) {
          sendPort.send("- $f");
        }
      }
    }
    if (processedFiles.isNotEmpty) {
      sendPort.send("Processed ${processedFiles.length} files "
          "in ${timeStr(tD)} "
          ":D");
    }
  }

  /// Runs the given [function] with the provided [arguments] and measures its execution time.
  /// Optionally handles messages sent back from the isolate using a [SendPort].
  ///
  /// This method uses a [Stopwatch] to measure how long the [function] takes to execute.
  /// It then prints the duration to the console or another logging mechanism.
  ///
  /// - [function]: The function to be executed and timed.
  /// - [arguments]: A list of arguments to be passed to the function.
  /// - [sendPort]: An optional [SendPort] to handle messages from the isolate.
  Future<void> runWithTimer(Function function, List<dynamic> arguments,
      {SendPort? sendPort}) async {
    Stopwatch stopwatch = Stopwatch()..start();

    String functionName = _extractFunctionName(function.toString());

    try {
      await Function.apply(function, arguments);
    } catch (e) {
      final errorMsg = 'Error in function $functionName: $e';
      globalLog(errorMsg);
      if (sendPort != null) {
        sendPort.send(errorMsg);
      }
    } finally {
      stopwatch.stop();
      final successMsg =
          'Function $functionName completed, execution time: ${stopwatch.elapsed}';
      globalLog(successMsg);
      if (sendPort != null) {
        sendPort.send(successMsg);
      }
    }
  }

  /// Extracts the function name from its string representation.
  String _extractFunctionName(String functionString) {
    final regex = RegExp(r"'(.*?)'");
    final match = regex.firstMatch(functionString);
    return match != null ? match.group(1) ?? 'Unknown' : 'Unknown';
  }
}
