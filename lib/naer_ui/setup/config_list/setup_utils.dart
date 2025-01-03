import 'package:NAER/naer_ui/dialog/modify_confirmation_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_ui/dialog/undo_dialog.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_ui/setup/snackbars.dart';
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
      SnackBarHandler.showSnackBar(
          context, ref, 'No setup is currently selected!', SnackBarType.info);

      ref.read(setupLoadingProvider.notifier).state = null;
    }
  }

  Future<bool> canToggleSelection() async {
    bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
    bool doesDllExist = await doesDatExtractionDllExist();

    if (isNierRunning) {
      if (context.mounted) showNierIsRunningDialog(context, ref);
      return false;
    }

    if (!doesDllExist) {
      if (context.mounted) showDllDoesNotExistDialog(context, ref);
      return false;
    }

    return true;
  }

  void toggleSetupSelection(final SetupConfigData setup) async {
    final globalState = ref.read(globalStateProvider);

    if (globalState.isLoading) return;

    if (!await canToggleSelection()) return;

    if (setup.isSelected) {
      if (context.mounted) {
        bool confirmUndo =
            await showUndoConfirmation(context, ref, isAddition: false);
        if (confirmUndo) _deselectSetup(setup);
      }
    } else {
      _selectSetup(setup);
    }
  }

  void _selectSetup(final SetupConfigData setup) async {
    final globalState = ref.read(globalStateProvider);

    if ((setup.doesUseDlc ?? false) && !globalState.hasDLC) {
      globalLog(
          "Setup ${setup.title} requires DLC which is not available. If DLC is available you can enable it in the options. Only check if you have the DLC otherwise DLC enemies get used that will not render in the game.");
      SnackBarHandler.showSnackBar(
          context,
          ref,
          'The setup "${setup.title}" requires DLC, which is not available. Please enable the DLC in the options if you have it installed.',
          SnackBarType.failure);

      return;
    }

    if (!validateInputOutput(globalState)) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      return;
    }

    bool? shouldStartSetup = await showStartSetupDialog(ref, context, setup);
    if (shouldStartSetup == true) {
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

      SnackBarHandler.showSnackBar(
          context, ref, 'Setup deleted successfully!', SnackBarType.success);
    } else {
      SnackBarHandler.showSnackBar(
          context, ref, 'Undo the Setup before deleting.', SnackBarType.info);
    }
  }
}
