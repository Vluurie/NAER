import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:NAER/naer_ui/dialog/directory_selection_dialog.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/naer_utils/find_mod_files.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'dart:async';

import 'dart:isolate';

class InputDirectoryHandler {
  Future<void> openInputFileDialog(BuildContext context, WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (context.mounted) {
      await _handleSelectedDirectory(context, ref, selectedDirectory);
    }
  }

  Future<void> autoSearchInputPath(BuildContext context, WidgetRef ref) async {
    bool granted = await askForDeepSearchPermission(context, ref);

    if (granted) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: AutomatoLoading(
                color: AutomatoThemeColors.bright(ref),
                translateX: 0,
                svgString: AutomatoSvgStrings.automatoSvgStrHead,
              ),
            );
          },
        );
      }

      try {
        List<String> allDrives = _getAllDrives();
        String? autoFoundDirectory = await _searchAcrossDrives(allDrives);

        if (autoFoundDirectory != null) {
          globalLog('Found NieR:Automata input directory: $autoFoundDirectory');
          if (context.mounted) {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              await _handleSelectedDirectory(context, ref, autoFoundDirectory);
              if (context.mounted) {
                await OutputDirectoryHandler.handleSelectedDirectory(
                    context, ref, autoFoundDirectory);
              }
            }
          }
        } else {
          globalLog('NieR:Automata data directory not found.');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        globalLog('Error during search: $e');
      }
    } else {
      globalLog('Search permission denied.');
    }
  }

  // Method to manage isolates and search across all drives
  Future<String?> _searchAcrossDrives(List<String> drives) async {
    final completer = Completer<String?>();
    final receivePort = ReceivePort();
    List<Isolate> activeIsolates = [];

    receivePort.listen((message) {
      if (message != null) {
        completer.complete(message);
        for (Isolate isolate in activeIsolates) {
          isolate.kill(priority: Isolate.immediate);
        }
        receivePort.close();
      } else {
        if (activeIsolates.isEmpty) {
          completer.complete(null);
        }
      }
    });

    // Spawn an isolate for each drive
    for (String drive in drives) {
      Isolate.spawn(_isolateSearchEntry, [drive, receivePort.sendPort])
          .then((isolate) {
        activeIsolates.add(isolate);
      });
    }

    return completer.future;
  }

  // Entry point for the isolate
  static Future<void> _isolateSearchEntry(List<dynamic> args) async {
    final String drive = args[0];
    final SendPort sendPort = args[1];

    String? foundDirectory = await _searchForNierAutomataDirectory(drive);
    sendPort.send(foundDirectory);
  }

  // Function to search for the NieR:Automata directory within a specific drive
  static Future<String?> _searchForNierAutomataDirectory(String drive) async {
    Directory rootDir = Directory(drive);
    return await _bfsSearchDirectory(rootDir);
  }

  static Future<String?> _bfsSearchDirectory(Directory directory) async {
    Queue<Directory> queue = Queue<Directory>();
    queue.add(directory);

    while (queue.isNotEmpty) {
      Directory currentDir = queue.removeFirst();

      try {
        List<FileSystemEntity> entities = currentDir.listSync();

        for (var entity in entities) {
          if (entity is Directory) {
            String dirPath = entity.path;

            // Check if the directory is the target "NieRAutomata\data"
            if (dirPath.endsWith(r'NieRAutomata\data')) {
              String parentDir = Directory(dirPath).parent.path;
              File exeFile = File(path.join(parentDir, 'NieRAutomata.exe'));
              if (exeFile.existsSync()) {
                return dirPath;
              }
            }

            queue.add(entity);
          }
        }
      } catch (e) {
        if (e is FileSystemException) {
          log('Skipped directory due to access issues: ${currentDir.path}');
          continue;
        } else {
          log('Error while searching directory: $e');
        }
      }
    }

    return null;
  }

  List<String> _getAllDrives() {
    List<String> drives = [];
    for (int i = 67; i <= 90; i++) {
      String driveLetter = String.fromCharCode(i);
      String drivePath = '$driveLetter:\\';

      if (Directory(drivePath).existsSync()) {
        drives.add(drivePath);
      }
    }
    return drives;
  }

  Future<void> _handleSelectedDirectory(
      BuildContext context, WidgetRef ref, String? selectedDirectory) async {
    if (selectedDirectory != null) {
      var containsValidFile = await containsValidFiles(selectedDirectory);
      bool isInDataDirectory =
          await checkNotAllCpkFilesExist(selectedDirectory);

      if (containsValidFile && !isInDataDirectory) {
        final globalState = ref.read(globalStateProvider.notifier);
        String escapedPath = selectedDirectory.convertAndEscapePath();
        globalState.updateInputPath(escapedPath);

        bool dlcExist = await hasDLC(selectedDirectory);
        if (!dlcExist) {
          if (context.mounted) {
            await showNoDlcDirectoryDialog(context, ref);
          }
        } else {
          if (context.mounted) {
            await showAsyncInfoDialog(context, ref);
          }
        }
      } else {
        if (context.mounted) {
          await showInvalidDirectoryDialog(context, ref);
        }
        ref.read(globalStateProvider.notifier).updateInputPath('');
      }
    } else {
      ref.read(globalStateProvider.notifier).updateInputPath('');
    }
  }
}

class OutputDirectoryHandler {
  Future<void> openOutputFileDialog(BuildContext context, WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (context.mounted) {
      await handleSelectedDirectory(context, ref, selectedDirectory);
    }
  }

  static Future<void> handleSelectedDirectory(
      BuildContext context, WidgetRef ref, String? selectedDirectory) async {
    if (selectedDirectory != null) {
      final globalState = ref.read(globalStateProvider.notifier);
      String escapedPath = selectedDirectory.convertAndEscapePath();
      globalState.updateOutputPath(escapedPath);

      var modFiles = await findModFiles(escapedPath);
      if (modFiles.isNotEmpty) {
        if (context.mounted) {
          showModsMessage(modFiles, (updatedModFiles) async {
            if (updatedModFiles.isEmpty) {
              globalState.updateIgnoredModFiles([]);
            } else {
              globalState.updateIgnoredModFiles(updatedModFiles);
            }
            log("Updated ignoredModFiles after dialog: ${globalState.readIgnoredModFiles()}");
            final prefs = await SharedPreferences.getInstance();
            String jsonData = jsonEncode(globalState.readIgnoredModFiles());
            await prefs.setString('ignored_mod_files', jsonData);
          }, context, ref);
        }
      } else {
        if (context.mounted) {
          showNoModFilesDialog(context, ref);
        }
      }
    } else {
      ref.read(globalStateProvider.notifier).updateOutputPath('');
    }
  }
}
