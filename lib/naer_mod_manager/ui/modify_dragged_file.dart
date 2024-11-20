import 'dart:io';
import 'dart:isolate';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/modify_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_utils/cli_arguments.dart';

class ModifyDraggedFile {
  final CLIArguments cliArguments;
  final BuildContext context;
  final WidgetRef ref;
  ModifyDraggedFile(
      {required this.cliArguments, required this.context, required this.ref});

  Future<void> randomizeDraggedFile(final List<String> droppedFolders) async {
    final globalState = ref.read(globalStateProvider.notifier);
    final logState = provider.Provider.of<LogState>(context, listen: false);
    if (cliArguments.input.isEmpty ||
        cliArguments.specialDatOutputPath.isEmpty ||
        !Platform.isWindows) {
      return;
    }

    List<String> baseArgs = List.from(cliArguments.processArgs);

    for (String folderPath in droppedFolders) {
      if (FileSystemEntity.typeSync(folderPath) ==
          FileSystemEntityType.directory) {
        List<String> arguments = List.from(baseArgs);
        arguments[0] = folderPath;
        arguments.modifyArgumentsForForcedEnemyList();

        try {
          final receivePort = ReceivePort();

          receivePort.listen((final message) {
            if (message is String) {
              logState.addLog(message);
            }
          });

          Map<String, dynamic> args = {
            'processArgs': arguments,
            'isManagerFile': true,
            'sendPort': receivePort.sendPort,
            'backUp': false,
            'isBalanceMode': globalState.readIsBalanceMode(),
            'hasDLC': globalState.readHasDLC(),
            'isAddition': false
          };
          globalState.setIsModManagerPageProcessing(
              isModManagerPageProcessing: true);
          await compute(runNierCliIsolated, args);
          globalState.setIsModManagerPageProcessing(
              isModManagerPageProcessing: false);
          globalLog(
              "Randomization process finished the dragged file successfully.");
        } catch (e, stackTrace) {
          ExceptionHandler().handle(e, stackTrace,
              extraMessage:
                  "Failed to process folder $folderPath with ${arguments.toString()}",
              onHandled: () => {
                    globalState.setIsModManagerPageProcessing(
                        isModManagerPageProcessing: false)
                  });
        }
      }
    }
  }
}
