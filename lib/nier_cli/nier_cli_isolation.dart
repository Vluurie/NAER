import 'dart:isolate';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli.dart';

/// Runs the Nier CLI with the given arguments in an isolate.
Future<void> runNierCliIsolated(final Map<String, dynamic> arguments) async {
  List<String> processArgs = arguments['processArgs'];
  bool isManagerFile = arguments['isManagerFile'];
  SendPort sendPort = arguments['sendPort'];
  bool? backUp = arguments['backUp'];
  bool? isBalanceMode = arguments['isBalanceMode'];
  bool? hasDLC = arguments['hasDLC'];

  NierCliArgs cliArgs = NierCliArgs(
    arguments: processArgs,
    sendPort: sendPort,
    isManagerFile: isManagerFile,
    isBalanceMode: isBalanceMode,
    backUp: backUp,
    hasDLC: hasDLC,
  );

  try {
    await nierCli(cliArgs);
  } catch (e, stackTrace) {
    sendPort.send(
        "An error has occured while processing, check the log.txt for more information.");
    await LogState.logError(e.toString(), stackTrace);
    rethrow;
  }
}
