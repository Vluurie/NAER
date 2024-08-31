import 'dart:async';
import 'dart:isolate';
import 'package:NAER/naer_database/handle_db_additions.dart';
import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_database/handle_db_modifications.dart';
import 'package:NAER/naer_ui/dialog/complete_dialog.dart';
import 'package:NAER/naer_ui/other/ascii_art.dart';
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
    {required final bool backUp, final bool isAddition = false}) async {
  final globalState = ref.read(globalStateProvider.notifier);
  final globalStateRiverPod = ref.read(globalStateProvider);

  if (!validateInputOutput(globalStateRiverPod)) {
    globalLog("Error: Please select both input and output directories. 💋 ");
    return;
  }

  initializeProcess(globalState);

  globalLog("Starting modification process... 🏃‍➡️");

  try {
    await runProcessInIsolate(arguments, globalStateRiverPod,
        backUp: backUp, isAddition: isAddition);
    await LogState().clearLogs();
  } on Exception catch (e) {
    globalLog("Error occurred: $e");
  } finally {
    if (context.mounted) {
      finalizeProcess(context, ref, globalState, isAddition: isAddition);
      if (context.mounted) {
        showCompletionDialog(context, ref, globalState.readInput());
        if (isAddition) {
          await DatabaseAdditionHandler.deleteMatchingModifications();
          await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();
        }
      }
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
    handleIsolateMessage(message, isAddition: isAddition);
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

void handleIsolateMessage(final dynamic message,
    {required final bool isAddition}) {
  if (message is Map<String, dynamic>) {
    if (message['event'] == 'file_changes_batch') {
      final List<Map<String, dynamic>> fileChanges =
          List<Map<String, dynamic>>.from(message['fileChanges']);

      for (final fileChange in fileChanges) {
        if (!isAddition) {
          DatabaseModificationHandler.logModificationForDatabase(
            fileChange['filePath'],
            fileChange['action'],
          );
        } else {
          DatabaseAdditionHandler.logAdditionForDatabase(
              fileChange['filePath'], fileChange['action']);
        }
      }
    } else if (message['event'] == 'error') {
      // Log the error message
      logState.addLog(
          "Error: ${message['details']}\nStack Trace: ${message['stackTrace']}");
    }
  } else if (message is String) {
    logState.addLog(message);
  }
}

void finalizeProcess(final BuildContext context, final WidgetRef ref,
    final GlobalStateNotifier globalState,
    {required final bool isAddition}) async {
  globalState.setIsLoading(isLoading: false);
  globalLog(asciiArt2B, useTimeDate: false);

  try {
    globalLog("Inserting file changes into database.");
    if (!isAddition) {
      await DatabaseModificationHandler.batchInsertModificationsToDatabase();
    } else {
      await DatabaseAdditionHandler.batchInsertAdditionsToDatabase();
    }
  } catch (e) {
    globalLog('Error during batch insert: $e');
  } finally {
    globalLog("Modification process finished.");
  }
}
