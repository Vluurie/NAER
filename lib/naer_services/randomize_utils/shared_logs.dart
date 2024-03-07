import 'package:flutter/foundation.dart';

class LogState extends ChangeNotifier {
  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void addLog(String log) {
    _logs.add(log);
    notifyListeners();
  }

  clearLogs(String output) {
    _logs.clear();
    notifyListeners();
  }
}
