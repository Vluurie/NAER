import 'dart:isolate';
import 'package:NAER/naer_utils/exception_handler.dart';
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
  bool isAddition = arguments['isAddition'];

  NierCliArgs cliArgs = NierCliArgs(
    arguments: processArgs,
    sendPort: sendPort,
    isManagerFile: isManagerFile,
    isBalanceMode: isBalanceMode,
    backUp: backUp,
    hasDLC: hasDLC,
    isAddition: isAddition,
  );

  try {
    await nierCli(cliArgs);
  } catch (e, stackTrace) {
    sendPort.send(
        "An error has occurred while processing. Check the log.json for more information.");

    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage: '''
Error occurred in Nier CLI isolated process:
- Process Arguments: ${processArgs.join(', ')}
- Is Manager File: $isManagerFile
- Backup: $backUp
- Is Balance Mode: $isBalanceMode
- Has DLC: $hasDLC
- Is Addition: $isAddition
''',
    );
    rethrow;
  }
}
