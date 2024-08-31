import 'dart:async';

import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_database/handle_db_dlc.dart';
import 'package:NAER/naer_ui/dialog/mod_file_list_dialog.dart';

import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showInvalidDirectoryDialog(
    final BuildContext context, final WidgetRef ref) async {
  unawaited(AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "Invalid Directory",
    content: Text(
      "The selected directory does not contain all .cpk files of the game. Be sure to select the correct NieR:Automata data directory (.../common/NieRAutomata/data).",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    onOkPressed: () {
      Navigator.of(context).pop();
    },
  ));
}

Future<void> showNoDlcDirectoryDialog(
    final BuildContext context, final WidgetRef ref) async {
  final globalState = ref.read(globalStateProvider.notifier);

  unawaited(AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "DLC Not Found",
    content: Text(
      "NAER detected that the DLC isn't installed. If you have it, enable it in the options.",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    onOkPressed: () {
      globalState.updateDLCOption(update: false);
      DatabaseDLCHandler.saveDLCOption(ref, shouldSave: false);
      Navigator.of(context).pop();
    },
  ));
}

Future<void> showAsyncInfoDialog(
    final BuildContext context, final WidgetRef ref) async {
  final Completer<void> completer = Completer<void>();
  final globalStateNotifier = ref.read(globalStateProvider.notifier);

  unawaited(AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "DLC Found!",
    content: Text(
      "DLC detected! If you prefer to disable the DLC enemies, you can do so in the options pane.",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    onOkPressed: () {
      globalStateNotifier.updateDLCOption(update: true);
      DatabaseDLCHandler.saveDLCOption(ref, shouldSave: true);
      completer.complete();
      Navigator.of(context).pop();
    },
  ));

  return completer.future;
}

Future<bool> askForDeepSearchPermission(
    final BuildContext context, final WidgetRef ref) async {
  final completer = Completer<bool>();

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    title: "Empty Paths (≧︿≦)",
    content: Text(
      "NAER didn't find any paths and needs to scan your drives to locate the data folder. If this causes any issues, you can manually select the correct path."
      "\n\nDo you want to proceed?",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 22,
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
    yesLabel: "Yes, proceed",
    noLabel: "No, cancel",
  );

  return completer.future;
}

void showModsMessage(
    final List<String> modFiles,
    final Function(List<String>) onModFilesUpdated,
    final BuildContext context,
    final WidgetRef ref) {
  void showRemoveConfirmation(final int? index) {
    final globalStateNotifier = ref.read(globalStateProvider.notifier);

    AutomatoDialogManager().showYesNoDialog(
      context: context,
      ref: ref,
      title: "Confirm Removal",
      content: index == null
          ? Text(
              "Are you sure you want to remove all mod files?",
              style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 20),
            )
          : Text(
              "Are you sure you want to remove ${modFiles[index]}?",
              style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 20),
            ),
      onYesPressed: () async {
        if (index != null) {
          String fileToRemove = modFiles.removeAt(index);
          await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(
              [fileToRemove]);
        } else {
          modFiles.clear();
          DatabaseIgnoredFilesHandler.ignoredFiles.clear();
          await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();
        }
        onModFilesUpdated(modFiles);

        // Update the state before closing the dialog
        globalStateNotifier.setWasModManamentDialogShown(
            wasModManagmentDialogShown: true);

        if (context.mounted) {
          Navigator.of(context).pop();

          if (modFiles.isNotEmpty) {
            Navigator.of(context).pop();
            showModsMessage(modFiles, onModFilesUpdated, context, ref);
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      onNoPressed: () {
        // Update the state before closing the dialog
        globalStateNotifier.setWasModManamentDialogShown(
            wasModManagmentDialogShown: true);
        Navigator.of(context).pop();
      },
      yesLabel: "Remove",
      noLabel: "Cancel",
    );
  }

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    showYesPointer: false,
    showNoPointer: false,
    title: "Manage Mod Files",
    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: ModFilesList(
        modFiles: modFiles,
        ref: ref,
        onRemovePressed: showRemoveConfirmation,
      ),
    ),
    onYesPressed: () {
      onModFilesUpdated(modFiles);

      // Update the state before closing the dialog
      final globalStateNotifier = ref.read(globalStateProvider.notifier);
      globalStateNotifier.setWasModManamentDialogShown(
          wasModManagmentDialogShown: true);

      Navigator.of(context).pop();
    },
    onNoPressed: () {
      // Handle removal confirmation for all mods
      showRemoveConfirmation(null);
    },
    yesLabel: "OK",
    noLabel: "Remove All",
  );
}

void showNoModFilesDialog(final BuildContext context, final WidgetRef ref) {
  final globalStateNotifier = ref.read(globalStateProvider.notifier);

  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "No Mod Files Found",
    content: Text(
      "Awesome, no mods found that NAER also uses. You can safely modify.",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    onOkPressed: () {
      // Update the state before closing the dialog
      globalStateNotifier.setWasModManamentDialogShown(
          wasModManagmentDialogShown: true);

      Navigator.of(context).pop();
    },
  );
}
