import 'dart:async';

import 'package:NAER/naer_ui/dialog/modify_confirmation_dialog.dart';
import 'package:NAER/naer_ui/dialog/undo_dialog.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_utils.dart';
import 'package:NAER/naer_ui/setup/snackbars.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/handle_start_modification.dart';
import 'package:NAER/naer_utils/start_modification_process.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/addition_state.dart';
import 'package:NAER/naer_utils/undo.dart';

class AdditionsUtils extends SetupUtils {
  const AdditionsUtils(super.ref, super.context);

  void installAddition(final SetupConfigData addition) async {
    ref.read(additionLoadingProvider.notifier).state = addition.id;
    final selectedAddition =
        ref.read(additionConfigProvider.notifier).getCurrentSelectedAddition();
    if (selectedAddition != null) {
      final arguments = selectedAddition.generateArguments(ref);
      await handleStartModification(
          context, ref, startModificationProcess, arguments,
          isAddition: true);
      ref.read(additionLoadingProvider.notifier).state = null;
    }
  }

  void toggleAdditionSelection(final SetupConfigData addition) async {
    final globalState = ref.read(globalStateProvider);

    if (globalState.isLoading) return;

    if (!await canToggleSelection()) return;

    if (addition.isSelected) {
      if (context.mounted) {
        bool confirmUndo =
            await showUndoConfirmation(context, ref, isAddition: true);
        if (confirmUndo) _deselectAddition(addition);
      }
    } else {
      _selectAddition(addition);
    }
  }

  void _selectAddition(final SetupConfigData addition) async {
    final globalState = ref.read(globalStateProvider);
    if (!validateInputOutput(globalState)) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      return;
    }
    bool? shouldStartAddition =
        await showStartSetupDialog(ref, context, addition);
    if (shouldStartAddition!) {
      ref.read(additionConfigProvider.notifier).selectAddition(addition.id);
      unawaited(removeModificationsSilently(isAddition: true));
      installAddition(addition);
      globalLog('STARTED NEW MODIFICATION ADDITION.');
    } else {
      ref.read(additionLoadingProvider.notifier).state = null;
    }
  }

  void _deselectAddition(final SetupConfigData addition) {
    ref.read(additionConfigProvider.notifier).deselectAddition();
    ref.read(additionLoadingProvider.notifier).state = null;
    globalLog('ADDITION DESELECTED.');
  }

  void deleteAddition(final SetupConfigData addition) async {
    if (!addition.isSelected) {
      final additionNotifier = ref.read(additionConfigProvider.notifier);
      additionNotifier.removeAddition(addition);
      SnackBarHandler.showSnackBar(
          context, ref, 'Addition deleted successfully!', SnackBarType.success);
    } else {
      SnackBarHandler.showSnackBar(context, ref,
          'Undo the Addition before deleting.', SnackBarType.info);
    }
  }
}
