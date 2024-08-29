import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'dart:collection';

class LogTracker {
  static final Set<String> _recentLogs = HashSet();
  static const int _logHistoryLimit = 100;

  static bool shouldLog(final String message) {
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

void globalLog(final String message) {
  if (message.trim().isEmpty) {
    return;
  }

  final now = DateTime.now();
  final formattedDateTime =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

  final processedLog = LogState.processLog('[$formattedDateTime] $message');

  LogState().addLog(processedLog);
}
