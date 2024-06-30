import 'dart:convert';
import 'dart:developer';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/naer_utils/find_mod_files.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputFileDialog {
  Future<void> openInputFileDialog(
      Function(String) updatePath,
      BuildContext context,
      GlobalState globalState,
      Function rebuild,
      WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var containsValidFile = await containsValidFiles(selectedDirectory);
      bool isInDataDirectory =
          await checkNotAllCpkFilesExist(selectedDirectory);

      if (containsValidFile && !isInDataDirectory) {
        globalState.input = selectedDirectory.convertAndEscapePath();

        updatePath(selectedDirectory);
      } else {
        if (context.mounted) {
          _showInvalidDirectoryDialog(context, ref);
        }
        updatePath('');
      }
    } else {
      updatePath('');
    }

    rebuild(); // Call rebuild after selection
  }

  void _showInvalidDirectoryDialog(BuildContext context, WidgetRef ref) {
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
}

class OutputFileDialog {
  Future<void> openOutputFileDialog(
      Function(String) updatePath,
      BuildContext context,
      GlobalState globalState,
      Function rebuild,
      WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      globalState.specialDatOutputPath =
          selectedDirectory.convertAndEscapePath();
      updatePath(globalState.specialDatOutputPath);

      var modFiles = await findModFiles(globalState.specialDatOutputPath);
      if (modFiles.isNotEmpty) {
        if (context.mounted) {
          showModsMessage(modFiles, (updatedModFiles) async {
            if (updatedModFiles.isEmpty) {
              globalState.ignoredModFiles = [];
            } else {
              globalState.ignoredModFiles = updatedModFiles;
            }
            log("Updated ignoredModFiles after dialog: ${globalState.ignoredModFiles}");
            final prefs = await SharedPreferences.getInstance();
            String jsonData = jsonEncode(globalState.ignoredModFiles);
            await prefs.setString('ignored_mod_files', jsonData);
          }, context, ref);
        }
      } else {
        if (context.mounted) {
          _showNoModFilesDialog(context, ref);
        }
      }
    } else {
      updatePath('');
    }

    rebuild(); // Call rebuild after selection
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

    ScrollController scrollController = ScrollController();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Below is a list of detected scripted mod files. Mods listed here will be ignored by the tool during modification. You can remove mods from this list to include them in the tool's operations. This will overwrite them. For alot scripted mod files, you can randomize them using the mod manager. \nFor example: A language mod is installed: For this to work with the randomizer you need to drag the language mod in the mod manager folder randomization or add it to the mod list manually. For more Information visite the NAER Guide.",
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AutomatoThemeColors.textDialogColor(ref)),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: modFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: AutomatoThemeColors.darkBrown(ref),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      elevation: 2.0,
                      child: ListTile(
                        leading: Icon(Icons.extension,
                            color: AutomatoThemeColors.saveZone(ref)),
                        title: Text(
                          modFiles[index],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AutomatoThemeColors.primaryColor(ref)),
                        ),
                        subtitle: Text('Currently ignored by the tool',
                            style: TextStyle(
                                color: AutomatoThemeColors.bright(ref))),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: AutomatoThemeColors.dangerZone(ref)),
                          tooltip: 'Remove mod from ignore list',
                          onPressed: () => showRemoveConfirmation(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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

  void _showNoModFilesDialog(BuildContext context, WidgetRef ref) {
    AutomatoDialogManager().showInfoDialog(
      context: context,
      ref: ref,
      title: "No Mod Files",
      content: Text(
        "No scripted mod files were found in the data directory. Skin mods are always ignored.",
        style: TextStyle(
            color: AutomatoThemeColors.textDialogColor(ref), fontSize: 20),
      ),
      onOkPressed: () {
        Navigator.of(context).pop();
      },
      okLabel: "OK",
    );
  }
}
