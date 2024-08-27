import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showCompletionDialog(
    BuildContext context, WidgetRef ref, String directoryPath) {
  final globalState = ref.read(globalStateProvider.notifier);
  globalState.setIsLoading(false);

  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: 'Modification Complete',
    content: Text(
      'Modification process completed successfully.',
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 18,
      ),
    ),
    okLabel: 'Close',
    onOkPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    },
  );
}
