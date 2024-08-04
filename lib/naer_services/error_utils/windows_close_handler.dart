import 'dart:async';

import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart' as provider;

class WindowsCloseListener with WindowListener {
  final BuildContext context;
  final WidgetRef ref;

  WindowsCloseListener(this.context, this.ref);

  @override
  void onWindowClose() async {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    if (globalState.isLoading) {
      windowManager.setPreventClose(true);
      await _showProcessingWarningDialog(ref);
    } else {
      final shouldClose = await _showExitConfirmationDialog(ref) ?? false;
      if (shouldClose) {
        windowManager.destroy();
      }
    }
  }

  Future<void> _showProcessingWarningDialog(WidgetRef ref) async {
    final completer = Completer<void>();
    AutomatoDialogManager().showYesNoDialog(
      context: context,
      title: "Warning: Application is processing",
      content: Text(
        "The application is still processing. Quitting now can leave uncleaned folders or modification, you need to clean the files that are left over in the data folder .\n\nDo you still want to quit?",
        style: TextStyle(
          fontSize: 24,
          color: AutomatoThemeColors.textDialogColor(ref),
        ),
      ),
      onYesPressed: () {
        completer.complete();
        windowManager.destroy();
        Navigator.of(context).pop();
      },
      onNoPressed: () {
        completer.complete();
        Navigator.of(context).pop();
      },
      yesLabel: "Yes",
      noLabel: "No",
      ref: ref,
    );
    return completer.future;
  }

  Future<bool?> _showExitConfirmationDialog(WidgetRef ref) async {
    final completer = Completer<bool>();
    AutomatoDialogManager().showYesNoDialog(
      context: context,
      title: "Information",
      content: Text(
        "Are you sure you want to quit? (⊙＿⊙') ",
        style: TextStyle(
          fontSize: 22,
          color: AutomatoThemeColors.textDialogColor(ref),
        ),
      ),
      onYesPressed: () {
        completer.complete(true);
        Navigator.of(context).pop();
      },
      onNoPressed: () {
        completer.complete(false);
        Navigator.of(context).pop();
      },
      yesLabel: "Yes",
      noLabel: "No",
      ref: ref,
    );
    return completer.future;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
