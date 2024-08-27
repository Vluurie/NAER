// ignore_for_file: avoid_print

import 'dart:isolate';

import 'package:NAER/naer_utils/change_tracker.dart';

/// Handles the logging in only ASCII chars and saves the modified files paths received by the port.
class ConsoleMessageHandler {
  /// Add the [receivePort] to get the isolate messages.
  /// [_handleExportedFilesMessage] saves exported files in [FileChange] with [saveChanges()]
  /// This ensures that [undoChanges()] works in the GUI.
  void listenToReceivePort(final ReceivePort receivePort) {
    receivePort.listen((final message) {
      if (message is Map<String, dynamic>) {
        _handleExportedFilesMessage(message);
        _logPortMessage(message);
      } else if (message is String) {
        _logPortMessage(message);
      }
    });
  }

  /// Filters non ascii chars with RegEx and prints the message for console.
  void printAsciiMessage(final String message) {
    String asciiMessage = message.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    print(asciiMessage);
  }

  /// Saves the exported modified files in [SharedPreferences]:
  ///  ['filePath'],
  ///  ['action'],
  void _handleExportedFilesMessage(final Map<String, dynamic> message) {
    if (message['event'] == 'file_change') {
      FileChange.changes.add(FileChange(
        message['filePath'],
        message['action'],
      ));
    }
  }

  void _logPortMessage(final dynamic message) {
    if (message is Map<String, dynamic> && message['event'] == 'error') {
      printAsciiMessage(
          "Error: ${message['details']}\nStack Trace: ${message['stackTrace']}");
    } else if (message is String) {
      printAsciiMessage(message);
    }
  }
}
