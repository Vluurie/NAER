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

Future<void> startModificationProcess(final BuildContext context,
    final List<String> arguments, final WidgetRef ref,
    {required final bool backUp}) async {
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
    await runProcessInIsolate(arguments, globalStateRiverPod, backUp: backUp);
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
  final List<String> arguments,
  final GlobalState globalState, {
  required final bool backUp,
}) async {
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
  };

  // separate compute
  await compute(runNierCliIsolated, args);
}

void handleIsolateMessage(final dynamic message) {
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

void finalizeProcess(final BuildContext context, final WidgetRef ref,
    final GlobalStateNotifier globalState) {
  globalState.setIsLoading(isLoading: false);
  globalLog(asciiArt2B);
  globalLog("Modification process finished.");
  if (context.mounted) {
    showCompletionDialog(context, ref, globalState.readInput());
  }
}
