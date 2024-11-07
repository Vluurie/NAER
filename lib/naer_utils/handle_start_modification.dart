import 'dart:async';

import 'package:NAER/naer_database/handle_db_modifcation_time.dart';
import 'package:NAER/naer_ui/dialog/backup_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> handleStartModification(
    final BuildContext context,
    final WidgetRef ref,
    final Future<void> Function(BuildContext, List<String>, WidgetRef,
            {required bool backUp, bool isAddition})
        modifyMethod,
    final List<String> arguments,
    {required final bool isAddition}) async {
  final globalState = ref.read(globalStateProvider.notifier);

  bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
  bool doesDllExist = await doesDatExtractionDllExist();

  if (!doesDllExist) {
    if (context.mounted) {
      showDllDoesNotExistDialog(context, ref);
    }
    return;
  }

  if (isNierRunning) {
    if (context.mounted) {
      showNierIsRunningDialog(context, ref);
    }
    return;
  }

  if (!context.mounted) return;

  bool backUp = await showBackupDialog(context, ref);
  if (!context.mounted) return;

  if (globalState.readIsLoading()) return;

  globalState.setIsLoading(isLoading: true);
  globalState.setIsButtonEnabled(isButtonEnabled: false);

  try {
    await DatabaseModificationTimeHandler.savePreModificationTime();
    final stopwatch = Stopwatch()..start();

    if (context.mounted) {
      await modifyMethod(context, arguments, ref,
          backUp: backUp, isAddition: isAddition);
    }

    stopwatch.stop();
    globalLog('Total modification time: ${stopwatch.elapsed}');
  } catch (e, stackTrace) {
    LogState.logError(
      'Error during modification: $e',
      Trace.from(stackTrace),
    );
  } finally {
    if (context.mounted) {
      globalState.setIsLoading(isLoading: false);
      globalState.setIsButtonEnabled(isButtonEnabled: true);
    }
  }
}
