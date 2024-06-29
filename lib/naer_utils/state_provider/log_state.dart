import 'dart:io';

import 'package:NAER/naer_utils/global_log.dart';
import 'package:flutter/material.dart';

class LogState with ChangeNotifier {
  static final LogState _instance = LogState._internal();

  factory LogState() {
    return _instance;
  }

  LogState._internal();

  final List<String> _logs = [];

  List<String> get logs => _logs;

  void addLog(String log) {
    _logs.add(log);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  static String processLog(String log) {
    // Process the log message if necessary
    return log;
  }

  static List<String> getGlobalLogs() {
    return _instance._logs;
  }

  /// Logs an error message to the global log, sends it through the send port,
  /// and writes it to a log.txt file with a timestamp and stack trace.
  ///
  /// [error] is the error message to be logged.
  /// [stackTrace] is the stack trace associated with the error.
  static Future<void> logError(String error, StackTrace stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '[$timestamp] Error: $error\nStack trace:\n$stackTrace\n';

    globalLog(logMessage);

    final logFile = File('log.txt');
    await logFile.writeAsString(logMessage, mode: FileMode.append);
  }
}
