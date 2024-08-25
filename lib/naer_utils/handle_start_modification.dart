import 'package:NAER/naer_ui/dialog/backup_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> handleStartModification(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(BuildContext, bool, List<String>, WidgetRef)
      modifyMethod,
  List<String> arguments,
) async {
  bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
  if (!isNierRunning) {
    bool backUp = await showBackupDialog(context, ref);

    if (!context.mounted) return;

    final globalState = ref.read(globalStateProvider.notifier);
    if (!globalState.readIsLoading()) {
      globalState.setIsLoading(true);
      globalState.setIsButtonEnabled(false);

      try {
        await FileChange.savePreRandomizationTime();
        final stopwatch = Stopwatch()..start();
        if (context.mounted) {
          await modifyMethod(context, backUp, arguments, ref);
        }
        await FileChange.saveChanges();
        stopwatch.stop();

        globalLog('Total modification time: ${stopwatch.elapsed}');
      } catch (e, stackTrace) {
        LogState.logError(
          'Error during modification: $e',
          Trace.from(stackTrace),
        );
      } finally {
        if (context.mounted) {
          globalState.setIsLoading(false);
          globalState.setIsButtonEnabled(true);
        }
      }
    }
  } else {
    if (context.mounted) {
      showNierIsRunningDialog(context, ref);
    }
  }
}