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

Future<void> startModificationProcess(BuildContext context, bool backUp,
    List<String> arguments, WidgetRef ref) async {
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
    await runProcessInIsolate(arguments, backUp, globalStateRiverPod);
    LogState().clearLogs();
  } on Exception catch (e) {
    globalLog("Error occurred: $e");
  } finally {
    if (context.mounted) {
      finalizeProcess(context, ref, globalState);
    }
  }
}

bool validateInputOutput(GlobalState globalState) {
  return globalState.input.isNotEmpty &&
      globalState.specialDatOutputPath.isNotEmpty;
}

void initializeProcess(GlobalStateNotifier globalState) {
  globalState.setHasError(true);
  globalState.setIsLoading(true);
  globalState.clearLoggedStages();
  globalState.scrollToSetup();
}

Future<void> runProcessInIsolate(
    List<String> arguments, bool backUp, GlobalState globalState) async {
  bool isManagerFile = false;
  final receivePort = ReceivePort();

  receivePort.listen((message) {
    handleIsolateMessage(message);
  });

  Map<String, dynamic> args = {
    'processArgs': arguments,
    'isManagerFile': isManagerFile,
    'sendPort': receivePort.sendPort,
    'backUp': backUp,
    'isBalanceMode': globalState.isBalanceMode,
    'hasDLC': globalState.hasDLC,
  };

  // separate compute
  await compute(runNierCliIsolated, args);
}

void handleIsolateMessage(dynamic message) {
  if (message is Map<String, dynamic>) {
    if (message['event'] == 'file_change') {
      logState.addLog("File created: ${message['filePath']}");
      FileChange.changes.add(FileChange(
        message['filePath'],
        message['action'],
      ));
    } else if (message['event'] == 'error') {
      logState.addLog(
          "Error: ${message['details']}\nStack Trace: ${message['stackTrace']}");
    }
  } else if (message is String) {
    logState.addLog(message);
  }
}

void finalizeProcess(
    BuildContext context, WidgetRef ref, GlobalStateNotifier globalState) {
  globalState.setIsLoading(false);
  globalLog(asciiArt2B);
  globalLog("Modification process finished.");
  if (context.mounted) {
    showCompletionDialog(context, ref, globalState.readInput());
  }
}
