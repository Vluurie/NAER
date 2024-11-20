import 'dart:isolate';

import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/global_log.dart';

/// Util class for counting runtime of single methods or full processing time.
class CountRuntime {
  String timeStr(final Duration d) {
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

  void processTime(final DateTime t1, final Set<String> processedFiles,
      final List<String> errorFiles, final SendPort sendPort) {
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
  /// - [function]: The function to be executed and timed.
  /// - [arguments]: A list of arguments to be passed to the function.
  /// - [sendPort]: An optional [SendPort] to handle messages from the isolate.
  Future<void> runWithTimer(
      final Function function, final List<dynamic> arguments,
      {final SendPort? sendPort}) async {
    Stopwatch stopwatch = Stopwatch()..start();

    String functionName = _extractFunctionName(function.toString());

    try {
      await Function.apply(function, arguments);
    } catch (e, stackTrace) {
      final errorMsg = 'Error in function $functionName: $e';
      ExceptionHandler().handle(
        e,
        stackTrace,
        extraMessage: '''
Error occurred while executing function:
- Function Name: $functionName
- Arguments: $arguments
- Elapsed Time Before Failure: ${stopwatch.elapsed}
''',
      );

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
  String _extractFunctionName(final String functionString) {
    final regex = RegExp(r"'(.*?)'");
    final match = regex.firstMatch(functionString);
    return match != null ? match.group(1) ?? 'Unknown' : 'Unknown';
  }
}
