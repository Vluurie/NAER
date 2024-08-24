import 'dart:async';

import 'package:NAER/naer_ui/dialog/mod_file_list_dialog.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showInvalidDirectoryDialog(
    BuildContext context, WidgetRef ref) async {
  AutomatoDialogManager().showInfoDialog(
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
    okLabel: "OK",
  );
}

Future<void> showNoDlcDirectoryDialog(
    BuildContext context, WidgetRef ref) async {
  final globalState = ref.read(globalStateProvider.notifier);

  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "DLC Not Found!",
    content: Text(
      "Uh-oh! It seems like the DLC hasn't been installed yet. Without it, your adventures might be lacking some epic battles against fearsome enemies. If you have the DLC, you can enable it using the checkbox in the options. Gear up and get ready!",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    okLabel: "OK",
    onOkPressed: () {
      globalState.updateDLCOption(false);
      FileChange.saveDLCOption(ref, false);
      Navigator.of(context).pop();
    },
  );
}

Future<void> showAsyncInfoDialog(BuildContext context, WidgetRef ref) async {
  final Completer<void> completer = Completer<void>();
  final globalStateNotifier = ref.read(globalStateProvider.notifier);

  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "DLC Found!",
    content: Text(
      "DLC detected! If you prefer to disable the DLC enemies, you can do so in the options panel. This can be helpful as most speedruns are done without the DLC.",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    okLabel: "OK",
    onOkPressed: () {
      globalStateNotifier.updateDLCOption(true);
      FileChange.saveDLCOption(ref, true);
      completer.complete();
      Navigator.of(context).pop();
    },
  );

  return completer.future;
}

Future<bool> askForDeepSearchPermission(
    BuildContext context, WidgetRef ref) async {
  final completer = Completer<bool>();

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    title: "Empty Paths (≧︿≦)",
    content: Text(
      "NAER noticed that the paths are empty and needs to scan your drives to find the data folder. "
      "If you encounter any issues, like an error, manually selecting the correct path."
      "\n\nWould you like to proceed?",
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
    List<String> modFiles,
    Function(List<String>) onModFilesUpdated,
    BuildContext context,
    WidgetRef ref) {
  void showRemoveConfirmation(int? index) {
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
          await FileChange.removeIgnoreFiles([fileToRemove]);
        } else {
          modFiles.clear();
          FileChange.ignoredFiles.clear();
          await FileChange.saveIgnoredFiles();
        }
        onModFilesUpdated(modFiles);
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
      Navigator.of(context).pop();
    },
    onNoPressed: () => showRemoveConfirmation(null),
    yesLabel: "OK",
    noLabel: "Remove All",
  );
}

void showNoModFilesDialog(BuildContext context, WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "No Mod Files Found!",
    content: Text(
      "Good news, adventurer! No scripted mod files were detected in the data directory. This means there are no conflicting mods that might alter your epic battles against enemies for now. Remember, skin mods are always ignored as they're just for show and don't affect gameplay. Enjoy your unaltered journey!",
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 20,
      ),
    ),
    onOkPressed: () {
      Navigator.of(context).pop();
    },
    okLabel: "Got it!",
  );
}
