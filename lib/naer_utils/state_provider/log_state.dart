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

  List<String> get logs => List.unmodifiable(_logs);

  void addLog(final String log) {
    _logs.add(log);
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await Future(() {
      _logs.clear();
      notifyListeners();
    });
  }

  static String processLog(final String log) {
    return log;
  }

  static List<String> getGlobalLogs() {
    return _instance._logs;
  }

  static void logError(final String error, final StackTrace stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '[$timestamp] Error: $error\nStack trace:\n$stackTrace\n';

    globalLog(logMessage);

    try {
      final logFile = File('log.txt');
      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      globalLog('Failed to write to log.txt: $e');
    }
  }
}
