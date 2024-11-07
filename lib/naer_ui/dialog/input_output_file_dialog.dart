import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:NAER/naer_database/handle_db_dlc.dart';
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
  Future<void> openInputFileDialog(
      final BuildContext context, final WidgetRef ref) async {
    String currentInputPath = ref.read(globalStateProvider).input;

    if (currentInputPath.isEmpty) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (context.mounted) {
        await _handleSelectedDirectory(context, ref, selectedDirectory);
      }
    }
  }

  Future<void> autoSearchInputPath(
      final BuildContext context, final WidgetRef ref) async {
    ref.read(countdownProvider.notifier).startCountdown();
    if (context.mounted) {
      unawaited(showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) {
          return _LoadingDialog();
        },
      ));
    }

    final List<Isolate> activeIsolates = [];
    final ReceivePort receivePort = ReceivePort();

    try {
      List<String> allDrives = _getAllDrives();

      String? autoFoundDirectory =
          await _searchAcrossDrives(allDrives, receivePort, activeIsolates)
              .timeout(const Duration(seconds: 30), onTimeout: () {
        _killAllIsolates(activeIsolates);
        return null;
      });

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
        globalLog(
            'NieR:Automata data directory not found. Please ensure the game is installed and the directory names are correct. It should be the "NieRAutomata/data" folder. You may need to select it manually.');

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      globalLog('Error during search: $e');
      _killAllIsolates(activeIsolates);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      receivePort.close();
    }
  }

  Future<String?> _searchAcrossDrives(final List<String> drives,
      final ReceivePort receivePort, final List<Isolate> activeIsolates) async {
    final completer = Completer<String?>();

    receivePort.listen((final message) {
      if (message != null) {
        completer.complete(message);
        _killAllIsolates(activeIsolates);
      }
    });

    for (String drive in drives) {
      Isolate isolate = await Isolate.spawn(
          _isolateSearchEntry, [drive, receivePort.sendPort]);
      activeIsolates.add(isolate);
    }

    return completer.future;
  }

  static Future<void> _isolateSearchEntry(final List<dynamic> args) async {
    final String drive = args[0];
    final SendPort sendPort = args[1];

    try {
      String? foundDirectory = await _searchForNierAutomataDirectory(drive);
      sendPort.send(foundDirectory);
    } catch (e) {
      sendPort.send(null);
    }
  }

  static Future<String?> _searchForNierAutomataDirectory(
      final String drive) async {
    Directory rootDir = Directory(drive);
    return await _bfsSearchDirectory(rootDir);
  }

  static Future<String?> _bfsSearchDirectory(final Directory directory) async {
    Queue<Directory> queue = Queue<Directory>();
    queue.add(directory);

    while (queue.isNotEmpty) {
      Directory currentDir = queue.removeFirst();

      try {
        List<FileSystemEntity> entities = currentDir.listSync();

        for (var entity in entities) {
          if (entity is Directory) {
            String dirPath = entity.path;

            // Check if the directory is the target "NieRAutomata\data and got the .exe"
            if (dirPath.endsWith(r'\data')) {
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
          globalLog(
              'Skipped directory due to access issues: ${currentDir.path}');
          continue;
        } else {
          globalLog('Error while searching directory: $e');
        }
      }
    }

    return null;
  }

  void _killAllIsolates(final List<Isolate> isolates) {
    for (Isolate isolate in isolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    isolates.clear();
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

  Future<void> _handleSelectedDirectory(final BuildContext context,
      final WidgetRef ref, final String? selectedDirectory) async {
    if (selectedDirectory != null) {
      var containsValidFile = await containsValidFiles(selectedDirectory);
      bool isInDataDirectory =
          await checkNotAllCpkFilesExist(selectedDirectory);

      if (containsValidFile && !isInDataDirectory) {
        final globalState = ref.read(globalStateProvider.notifier);
        String escapedPath = selectedDirectory.convertAndEscapePath();
        globalState.updateInputPath(escapedPath);

        bool dlcExist = await hasDLC(selectedDirectory);
        if (dlcExist) {
          globalState.updateDLCOption(update: true);
          await DatabaseDLCHandler.saveDLCOption(ref, shouldSave: true);
          globalLog("DLC was found, enabled Checkbox.");
        } else {
          globalState.updateDLCOption(update: false);
          await DatabaseDLCHandler.saveDLCOption(ref, shouldSave: false);
          globalLog("DLC does not exist, disabled Checkbox.");
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
  Future<void> openOutputFileDialog(
      final BuildContext context, final WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (context.mounted) {
      await handleSelectedDirectory(context, ref, selectedDirectory);
    }
  }

  static Future<void> handleSelectedDirectory(final BuildContext context,
      final WidgetRef ref, final String? selectedDirectory) async {
    if (selectedDirectory != null) {
      final globalState = ref.watch(globalStateProvider.notifier);
      String escapedPath = selectedDirectory.convertAndEscapePath();
      globalState.updateOutputPath(escapedPath);

      var modFiles = await findModFiles(escapedPath);
      if (modFiles.isNotEmpty) {
        if (context.mounted) {
          showModsMessage(modFiles, (final updatedModFiles) async {
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
        globalState.setWasModManamentDialogShown(
            wasModManagmentDialogShown: true);
      }
    } else {
      ref.read(globalStateProvider.notifier).updateOutputPath('');
    }
  }
}

final countdownProvider =
    StateNotifierProvider<CountdownNotifier, int>((final ref) {
  return CountdownNotifier();
});

class CountdownNotifier extends StateNotifier<int> {
  CountdownNotifier() : super(15);

  void startCountdown() {
    state = 15;
    Timer.periodic(const Duration(seconds: 1), (final Timer timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        timer.cancel();
      }
    });
  }
}

class _LoadingDialog extends ConsumerWidget {
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final countdown = ref.watch(countdownProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutomatoLoading(
            color: AutomatoThemeColors.bright(ref),
            translateX: 0,
            svgString: AutomatoSvgStrings.automatoSvgStrHead,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching paths... (${countdown}s)',
            style: TextStyle(
              color: AutomatoThemeColors.bright(ref),
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
