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
}
