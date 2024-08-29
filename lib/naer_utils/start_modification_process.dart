import 'dart:isolate';
import 'package:NAER/naer_ui/dialog/complete_dialog.dart';
import 'package:NAER/naer_ui/other/ascii_art.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO: Handle bug if no dlc exist
//TODO: Create a list of found nier automata paths if there are multiple

Future<void> startModificationProcess(final BuildContext context,
    final List<String> arguments, final WidgetRef ref,
    {required final bool backUp, final bool isAddition = false}) async {
  final globalState = ref.read(globalStateProvider.notifier);
  final globalStateRiverPod = ref.read(globalStateProvider);

  if (!validateInputOutput(globalStateRiverPod)) {
    globalLog("Error: Please select both input and output directories. 💋 ");
    return;
  }

  initializeProcess(globalState);

  await Future.delayed(const Duration(milliseconds: 800));

  globalLog("Starting modification process... 🏃‍➡️");

  try {
    await runProcessInIsolate(arguments, globalStateRiverPod,
        backUp: backUp, isAddition: isAddition);
    LogState().clearLogs();
  } on Exception catch (e) {
    globalLog("Error occurred: $e");
  } finally {
    if (context.mounted) {
      finalizeProcess(context, ref, globalState);
    }
  }
}

bool validateInputOutput(final GlobalState globalState) {
  return globalState.input.isNotEmpty &&
      globalState.specialDatOutputPath.isNotEmpty;
}

void initializeProcess(final GlobalStateNotifier globalState) {
  globalState.setHasError(hasError: true);
  globalState.setIsLoading(isLoading: true);
  globalState.clearLoggedStages();
  globalState.scrollToSetup();
}

Future<void> runProcessInIsolate(
    final List<String> arguments, final GlobalState globalState,
    {required final bool backUp, required final bool isAddition}) async {
  bool isManagerFile = false;
  final receivePort = ReceivePort();

  receivePort.listen((final message) {
    handleIsolateMessage(message);
  });

  Map<String, dynamic> args = {
    'processArgs': arguments,
    'isManagerFile': isManagerFile,
    'sendPort': receivePort.sendPort,
    'backUp': backUp,
    'isBalanceMode': globalState.isBalanceMode,
    'hasDLC': globalState.hasDLC,
    'isAddition': isAddition
  };

  await compute(runNierCliIsolated, args);
}

void handleIsolateMessage(final dynamic message) {
  if (message is Map<String, dynamic>) {
    if (message['event'] == 'file_change') {
      // Log the file change
      logState.addLog("File ${message['action']}d: ${message['filePath']}");

      // Ensure that the log change is recorded in shared preferences
      FileChange.logChange(
        message['filePath'],
        message['action'],
        isAddition: message['isAddition'],
      );
    } else if (message['event'] == 'error') {
      // Log the error message
      logState.addLog(
          "Error: ${message['details']}\nStack Trace: ${message['stackTrace']}");
    }
  } else if (message is String) {
    // Log any plain string messages
    logState.addLog(message);
  }
}

void finalizeProcess(final BuildContext context, final WidgetRef ref,
    final GlobalStateNotifier globalState) {
  globalState.setIsLoading(isLoading: false);
  globalLog(asciiArt2B);
  globalLog("Modification process finished.");
  FileChange.saveIgnoredFiles();
  if (context.mounted) {
    showCompletionDialog(context, ref, globalState.readInput());
  }
}
