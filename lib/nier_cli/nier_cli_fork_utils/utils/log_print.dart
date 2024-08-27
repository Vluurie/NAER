import 'package:NAER/naer_utils/state_provider/log_state.dart';

final logState = LogState();

void logAndPrint(final String message) {
  // print(message);
  logState.addLog(message);
}
