import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:NAER/naer_database/handle_db_dlc.dart';
import 'package:NAER/naer_ui/dialog/directory_selection_dialog.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
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
    final Set<String> foundDirectoriesWithData = {};
    final Set<String> foundDirectoriesWithoutData = {};

    try {
      List<String> allDrives = _getAllDrives();

      await _searchAcrossDrives(
        allDrives,
        receivePort,
        activeIsolates,
        foundDirectoriesWithData,
        foundDirectoriesWithoutData,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        _killAllIsolates(activeIsolates);
      });

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (foundDirectoriesWithData.isNotEmpty ||
          foundDirectoriesWithoutData.isNotEmpty) {
        String? selectedDirectory = await showDirectorySelectionDialog(
          context,
          foundDirectoriesWithData,
          foundDirectoriesWithoutData,
        );
        if (context.mounted) {
          await _handleSelectedDirectory(context, ref, selectedDirectory);
          bool containsValidFile = await containsValidFiles(selectedDirectory!);
          if (context.mounted && containsValidFile) {
            await OutputDirectoryHandler.handleSelectedDirectory(
                context, ref, selectedDirectory);
          }
        }
      } else {
        globalLog(
            'NieR:Automata data directory not found. Please ensure the game is installed and the directory names are correct. It should be the "NieRAutomata/data" folder. You may need to select it manually.');
      }
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace,
          extraMessage: "Caught during searching of input path.",
          onHandled: () => {
                _killAllIsolates(activeIsolates),
                if (context.mounted) {Navigator.of(context).pop()}
              });
    } finally {
      receivePort.close();
    }
  }

  Future<void> _searchAcrossDrives(
    final List<String> drives,
    final ReceivePort receivePort,
    final List<Isolate> activeIsolates,
    final Set<String> foundDirectoriesWithData,
    final Set<String> foundDirectoriesWithoutData,
  ) async {
    final completer = Completer<void>();

    receivePort.listen((final message) {
      if (message is Map<String, Set<String>>) {
        Set<String> withData = message['withData'] ?? {};
        Set<String> withoutData = message['withoutData'] ?? {};

        foundDirectoriesWithData.addAll(withData);
        foundDirectoriesWithoutData.addAll(withoutData);

        if (foundDirectoriesWithData.length +
                foundDirectoriesWithoutData.length >
            2) {
          if (!completer.isCompleted) {
            completer.complete();
            _killAllIsolates(activeIsolates);
          }
        }
      }
    });

    for (String drive in drives) {
      Isolate isolate = await Isolate.spawn(
        _isolateSearchEntry,
        [drive, receivePort.sendPort],
      );
      activeIsolates.add(isolate);
    }

    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
        _killAllIsolates(activeIsolates);
      },
    );
  }

  static Future<void> _isolateSearchEntry(final List<dynamic> args) async {
    final String drive = args[0];
    final SendPort sendPort = args[1];

    try {
      Map<String, Set<String>> foundDirectories =
          await _searchForNierAutomataDirectory(drive);
      sendPort.send(foundDirectories);
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace,
          extraMessage: "Caught in _isolateSearchEntry.",
          onHandled: () => {sendPort.send(null)});
    }
  }

  static Future<Map<String, Set<String>>> _searchForNierAutomataDirectory(
      final String drive) async {
    Directory rootDir = Directory(drive);
    return await _bfsSearchDirectory(rootDir);
  }

  static Future<Map<String, Set<String>>> _bfsSearchDirectory(
      final Directory directory) async {
    Queue<Directory> queue = Queue<Directory>();
    queue.add(directory);
    Set<String> foundDirectoriesWithData = {};
    Set<String> foundDirectoriesWithoutData = {};

    while (queue.isNotEmpty) {
      Directory currentDir = queue.removeFirst();

      try {
        List<FileSystemEntity> entities = currentDir.listSync();

        for (var entity in entities) {
          if (entity is Directory) {
            String dirPath = entity.path;

            String parentDir = Directory(dirPath).parent.path;
            Directory dataFolder = Directory(path.join(parentDir, "data"));
            File exeFile = File(path.join(parentDir, 'NieRAutomata.exe'));

            if (exeFile.existsSync()) {
              if (dataFolder.existsSync()) {
                String normalizedPath =
                    path.normalize(path.join(parentDir, "data"));
                foundDirectoriesWithData.add(normalizedPath);
              } else {
                String normalizedParentDir = path.normalize(parentDir);
                foundDirectoriesWithoutData.add(normalizedParentDir);
              }
            }

            queue.add(entity);
          }
        }
      } catch (e, stackTrace) {
        if (e is FileSystemException) {
          continue;
        } else {
          ExceptionHandler().handle(
            e,
            stackTrace,
            extraMessage:
                'Caught while searching directory: ${currentDir.path} in _searchForNierAutomataDirectory',
          );
        }
      }
    }

    return {
      'withData': foundDirectoriesWithData,
      'withoutData': foundDirectoriesWithoutData,
    };
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
      bool containsValidFile = await containsValidFiles(selectedDirectory);
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
            'SEARCHING FOR NIER AUTOMATA DIRECTORIES... (${countdown}s)',
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

//TODO: Refactore to Automato Theme
Future<String?> showDirectorySelectionDialog(
  final BuildContext context,
  final Set<String> withData,
  final Set<String> withoutData,
) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (final BuildContext context) {
      return SimpleDialog(
        title: Text(
          'Select Directory',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        children: [
          if (withData.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SAVE - NieR:Automata with "data" folder:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ...withData.map((final directory) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, directory);
              },
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      directory,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (withoutData.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WARNING - NieR:Automata without "data" folder:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ...withoutData.map((final directory) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, directory);
              },
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      directory,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "Not found? Select your NieR:Automata data folder manually .",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    },
  ).then((final value) {
    return value;
  });
}
