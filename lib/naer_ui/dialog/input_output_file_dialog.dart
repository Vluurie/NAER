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

        await updatePath(selectedDirectory);
        bool dlcExist = await hasDLC(selectedDirectory);
        if (!dlcExist) {
          if (context.mounted) {
            _showNoDlcDirectoryDialog(context, ref);
          }
        } else {
          if (context.mounted) {
            _showHasDlcDirectoryDialog(context, ref);
          }
        }
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

  void _showNoDlcDirectoryDialog(BuildContext context, WidgetRef ref) {
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
        _saveDLCOption(false);
        Navigator.of(context).pop();
      },
    );
  }

  void _showHasDlcDirectoryDialog(BuildContext context, WidgetRef ref) {
    final globalState = ref.read(globalStateProvider.notifier);

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
        globalState.updateDLCOption(true);
        _saveDLCOption(true);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _saveDLCOption(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dlc', value);
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

  void _showNoModFilesDialog(BuildContext context, WidgetRef ref) {
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
}

class ModFilesList extends StatefulWidget {
  final List<String> modFiles;
  final WidgetRef ref;
  final void Function(int?) onRemovePressed;

  const ModFilesList({
    super.key,
    required this.modFiles,
    required this.ref,
    required this.onRemovePressed,
  });

  @override
  ModFilesListState createState() => ModFilesListState();
}

class ModFilesListState extends State<ModFilesList> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Below is a list of detected scripted mod files. Mods listed here will be ignored by the tool during modification. You can remove mods from this list to include them in the tool's operations. This will overwrite them. For a lot of scripted mod files, you can randomize them using the mod manager. \nFor example: A language mod is installed: For this to work with the randomizer you need to drag the language mod in the mod manager folder randomization or add it to the mod list manually. For more information visit the NAER Guide.",
            style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AutomatoThemeColors.textDialogColor(widget.ref)),
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
              itemCount: widget.modFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: AutomatoThemeColors.darkBrown(widget.ref),
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  child: ListTile(
                    leading: Icon(Icons.extension,
                        color: AutomatoThemeColors.saveZone(widget.ref)),
                    title: Text(
                      widget.modFiles[index],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AutomatoThemeColors.primaryColor(widget.ref)),
                    ),
                    subtitle: Text('Currently ignored by the tool',
                        style: TextStyle(
                            color: AutomatoThemeColors.bright(widget.ref))),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AutomatoThemeColors.dangerZone(widget.ref)),
                      tooltip: 'Remove mod from ignore list',
                      onPressed: () => widget.onRemovePressed(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
