import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'dart:collection';

class LogTracker {
  static final Set<String> _recentLogs = HashSet();
  static const int _logHistoryLimit = 100;

  static bool shouldLog(String message) {
    if (_recentLogs.contains(message)) {
      return false;
    }

    _recentLogs.add(message);
    if (_recentLogs.length > _logHistoryLimit) {
      _recentLogs.remove(_recentLogs.first);
    }

    return true;
  }
}

void globalLog(String message) {
  if (message.trim().isEmpty) {
    return;
  }

  final processedLog = LogState.processLog(message);

  LogState().addLog(processedLog);
}
