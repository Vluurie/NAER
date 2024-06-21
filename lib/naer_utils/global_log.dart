import 'package:NAER/naer_utils/state_provider/log_state.dart';

void globalLog(String message) {
  final logState = LogState();
  if (message.trim().isEmpty) {
    return;
  }

  final processedLog = LogState.processLog(message);
  if (processedLog.isEmpty) {
    return;
  }

  logState.addLog(processedLog);
}
