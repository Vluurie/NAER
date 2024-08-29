import 'package:NAER/naer_ui/dialog/modify_confirmation_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_ui/dialog/undo_dialog.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
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

  Future<void> installSetup(final SetupConfigData setup) async {
    ref.read(setupLoadingProvider.notifier).state = setup.id;
    final selectedSetup =
        ref.read(setupConfigProvider.notifier).getCurrentSelectedSetup();
    if (selectedSetup != null) {
      final arguments = selectedSetup.generateArguments(ref);
      await handleStartModification(
          context, ref, startModificationProcess, arguments,
          isAddition: false);
      ref.read(setupLoadingProvider.notifier).state = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No setup is currently selected!')),
      );
      ref.read(setupLoadingProvider.notifier).state = null;
    }
  }

  void toggleSetupSelection(final SetupConfigData setup) async {
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
        bool confirmUndo =
            await showUndoConfirmation(context, ref, isAddition: false);
        if (confirmUndo) {
          _deselectSetup(setup);
        }
      }
    }
  }

  void _selectSetup(final SetupConfigData setup) async {
    final globalState = ref.read(globalStateProvider);
    if (!validateInputOutput(globalState)) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      return;
    }
    bool? shouldStartSetup = await showStartSetupDialog(ref, context, setup);
    if (shouldStartSetup!) {
      ref.read(setupConfigProvider.notifier).selectSetup(setup.id);
      globalLog('STARTED NEW MODIFICATION SETUP.');
      await installSetup(setup);
    } else {
      ref.read(setupLoadingProvider.notifier).state = null;
    }
  }

  void _deselectSetup(final SetupConfigData setup) {
    ref.read(setupStateProvider.notifier).deselectSetup();
    globalLog('SETUP DESELECTED.');
    ref.read(setupLoadingProvider.notifier).state = null;
  }

  void deleteSetup(final SetupConfigData setup) async {
    if (!setup.isSelected) {
      final setupNotifier = ref.read(setupConfigProvider.notifier);
      setupNotifier.removeConfig(setup);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setup deleted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undo the Setup before deleting.')),
      );
    }
  }
}
