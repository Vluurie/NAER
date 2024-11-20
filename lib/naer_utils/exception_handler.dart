import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:synchronized/synchronized.dart';

/// A singleton class for handling exceptions and logging detailed information
/// about errors, including stack traces, file, line numbers, and more.
class ExceptionHandler {
  static final ExceptionHandler _instance = ExceptionHandler._internal();
  static final Lock _logFileLock = Lock(); // Mutex-like lock for thread safety

  factory ExceptionHandler() => _instance;

  ExceptionHandler._internal();

  void handle(
    final dynamic error,
    final StackTrace stackTrace, {
    final String? extraMessage,
    final void Function()? onHandled,
  }) async {
    final dateTime = DateTime.now();
    final stackTraceInfo = _parseStackTrace(stackTrace);

    final logData = {
      'DateTime': dateTime.toIso8601String(),
      'Exception': error.toString(),
      'Extra Message': extraMessage ?? '',
      'Method': stackTraceInfo.methodName,
      'File': stackTraceInfo.filePath,
      'Line': stackTraceInfo.lineNumber,
      'Column': stackTraceInfo.columnNumber,
      'StackTrace': _formatStackTrace(stackTrace),
    };

    globalLog(JsonEncoder.withIndent('  ').convert(logData));
    await _logToFile(logData);

    if (onHandled != null) {
      onHandled();
    }
  }

  /// Helper function to format the stack trace neatly.
  String _formatStackTrace(final StackTrace stackTrace) {
    final stackTraceString = stackTrace.toString();
    return stackTraceString.split('\n').map((final line) {
      return '  $line';
    }).join('\n');
  }

  _StackTraceInfo _parseStackTrace(final StackTrace stackTrace) {
    final stackTraceString = stackTrace.toString();
    final stackTraceLines = stackTraceString.split('\n');
    final firstLine = stackTraceLines.first;

    final regex = RegExp(r'#\d+\s+(.+?)\s+\((.+?):(\d+):(\d+)\)');
    final match = regex.firstMatch(firstLine);

    if (match != null) {
      return _StackTraceInfo(
        methodName: match.group(1) ?? '',
        filePath: match.group(2) ?? '',
        lineNumber: int.parse(match.group(3) ?? '0'),
        columnNumber: int.parse(match.group(4) ?? '0'),
      );
    } else {
      return _StackTraceInfo();
    }
  }

  /// Thread-safe method to append the new log to the logs.json file.
  Future<void> _logToFile(final Map<String, dynamic> logData) async {
    // Use Lock for thread safety
    await _logFileLock.synchronized(() async {
      try {
        final logFilePath = 'logs.json';
        final logFile = File(logFilePath);

        List<dynamic> existingLogs = [];

        // Read existing logs if the file exists
        if (await logFile.exists()) {
          final content = await logFile.readAsString();
          try {
            existingLogs = jsonDecode(content) as List<dynamic>;
          } catch (e) {
            print('Invalid JSON in logs.json, resetting to an empty list.');
            existingLogs = [];
          }
        }

        // Append the new log entry
        existingLogs.add(logData);

        // Write back updated logs
        const encoder = JsonEncoder.withIndent('  ');
        final updatedJson = encoder.convert(existingLogs);
        await logFile.writeAsString(updatedJson);
      } catch (e, stackTrace) {
        print('Failed to log message to file: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }
}

class _StackTraceInfo {
  final String methodName;
  final String filePath;
  final int lineNumber;
  final int columnNumber;

  _StackTraceInfo({
    this.methodName = '',
    this.filePath = '',
    this.lineNumber = 0,
    this.columnNumber = 0,
  });
}
