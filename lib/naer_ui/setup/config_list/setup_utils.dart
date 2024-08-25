import 'package:NAER/naer_ui/dialog/modify_confirmation_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_ui/dialog/undo_dialog.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/handle_start_modification.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/start_modification_process.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupUtils {
  final WidgetRef ref;
  final BuildContext context;

  const SetupUtils(this.ref, this.context);

  void installSetup(SetupConfigData setup) {
    final selectedSetup =
        ref.read(setupConfigProvider.notifier).getCurrentSelectedSetup();
    if (selectedSetup != null) {
      final arguments = selectedSetup.generateArguments(ref);
      handleStartModification(
          context, ref, startModificationProcess, arguments);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No setup is currently selected!')),
      );
    }
  }

  void toggleSetupSelection(SetupConfigData setup) async {
    bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
    final globalState = ref.read(globalStateProvider);

    if (globalState.isLoading) {
      return;
    }

    if (!setup.isSelected) {
      if (isNierRunning) {
        showNierIsRunningDialog(context, ref);
      } else {
        _selectSetup(setup);
      }
    } else {
      if (isNierRunning) {
        showNierIsRunningDialog(context, ref);
      } else {
        bool confirmUndo = await showUndoConfirmation(context, ref);
        if (confirmUndo) {
          _deselectSetup(setup);
        }
      }
    }
  }

  void _selectSetup(SetupConfigData setup) async {
    bool? shouldStartSetup = await showStartSetupDialog(ref, context, setup);
    if (shouldStartSetup!) {
      ref.read(setupConfigProvider.notifier).selectSetup(setup.id);
      installSetup(setup);
      globalLog('STARTED NEW MODIFICATION SETUP.');
    } else {
      return;
    }
  }

  void _deselectSetup(SetupConfigData setup) {
    ref.read(setupStateProvider.notifier).deselectSetup();
    globalLog('SETUP DESELECTED.');
  }

  void deleteSetup(SetupConfigData setup) async {
    final setupNotifier = ref.read(setupConfigProvider.notifier);
    setupNotifier.removeConfig(setup);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Setup deleted successfully!')),
    );
  }
}
