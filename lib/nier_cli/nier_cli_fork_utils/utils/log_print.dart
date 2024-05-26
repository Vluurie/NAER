import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';

final logState = LogState();

void logAndPrint(String message) {
  print(message);
  logState.addLog(message);
}
