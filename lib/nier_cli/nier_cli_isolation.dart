import 'dart:isolate';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli.dart';

/// Runs the Nier CLI with the given arguments in an isolate.
///
/// This function is designed to be executed in an isolate to manage potentially
/// long-running tasks without blocking the main thread. It accepts a map of
/// arguments including the process arguments, a flag indicating if it is a
/// manager file, and a send port for communication with the main thread.
///
/// The function logs messages using a global logging utility and sends these
/// messages back to the main thread via the provided send port. The send port
/// is propagated down the call tree to ensure all messages are logged in the
/// main log output.
Future<void> runNierCliIsolated(Map<String, dynamic> arguments) async {
  List<String> processArgs = arguments['processArgs'];
  bool isManagerFile = arguments['isManagerFile'];
  SendPort sendPort = arguments['sendPort'];

  try {
    await nierCli(processArgs, isManagerFile, sendPort);
  } catch (e, stackTrace) {
    sendPort.send(
        "An error has occured while processing, check the log.txt for more information.");
    await LogState.logError(e.toString(), stackTrace);
    rethrow;
  }
}
