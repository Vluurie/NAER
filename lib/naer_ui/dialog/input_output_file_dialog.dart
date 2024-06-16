import 'dart:convert';
import 'dart:developer';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/naer_utils/find_mod_files.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputFileDialog {
  Future<void> openInputFileDialog(Function(String) updatePath,
      BuildContext context, GlobalState globalState, Function rebuild) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var containsValidFile = await containsValidFiles(selectedDirectory);

      if (containsValidFile) {
        globalState.input = selectedDirectory.convertAndEscapePath();
        updatePath(selectedDirectory);
      } else {
        if (context.mounted) {
          _showInvalidDirectoryDialog(context);
        }
        updatePath('');
      }
    } else {
      updatePath('');
    }

    rebuild(); // Call rebuild after selection
  }

  void _showInvalidDirectoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid Directory"),
          content: const Text(
              "The selected directory does not contain .cpk or .dat files."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class OutputFileDialog {
  Future<void> openOutputFileDialog(Function(String) updatePath,
      BuildContext context, GlobalState globalState, Function rebuild) async {
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
          }, context);
        }
      } else {
        if (context.mounted) {
          _showNoModFilesDialog(context);
        }
      }
    } else {
      updatePath('');
    }

    rebuild(); // Call rebuild after selection
  }

  void showModsMessage(List<String> modFiles,
      Function(List<String>) onModFilesUpdated, BuildContext context) {
    ScrollController scrollController = ScrollController();

    void showRemoveConfirmation(int? index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Removal"),
            content: index == null
                ? const Text("Are you sure you want to remove all mod files?")
                : Text("Are you sure you want to remove ${modFiles[index]}?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text("Remove"),
                  onPressed: () async {
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
                        showModsMessage(modFiles, onModFilesUpdated, context);
                      } else {
                        Navigator.of(context).pop();
                      }
                    }
                  }),
            ],
          );
        },
      );
    }

    if (modFiles.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Manage Mod Files"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "Below is a list of detected mod files. Mods listed here will be ignored by the tool during modification. You can remove mods from this list to include them in the tool's operations.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: modFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 2.0,
                            child: ListTile(
                              leading: const Icon(Icons.extension,
                                  color: Colors.blueAccent),
                              title: Text(
                                modFiles[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(221, 243, 240, 34)),
                              ),
                              subtitle: const Text(
                                  'Currently ignored by the tool',
                                  style: TextStyle(color: Colors.grey)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
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
            actions: <Widget>[
              TextButton(
                onPressed: () => showRemoveConfirmation(null),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text("Remove All"),
              ),
              TextButton(
                onPressed: () {
                  onModFilesUpdated(modFiles);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _showNoModFilesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Mod Files"),
          content:
              const Text("No mod files were found in the selected directory."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
