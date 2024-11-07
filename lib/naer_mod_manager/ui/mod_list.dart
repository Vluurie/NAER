// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_mod_manager/ui/mod_popup.dart';
import 'package:NAER/naer_mod_manager/utils/file_utils.dart';
import 'package:NAER/naer_mod_manager/utils/notification_manager.dart';
import 'package:NAER/naer_mod_manager/utils/shared_preferences_utils.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_ui/setup/snackbars.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/naer_utils/get_paths.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/modify_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:path/path.dart' as p;
import 'package:stack_trace/stack_trace.dart';

class Mod {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final List<Map<String, String>> files;
  final String? imagePath;
  final bool? canBeRandomized;
  final String? dlc;

  Mod(
      {required this.id,
      required this.name,
      required this.version,
      required this.author,
      required this.description,
      required this.files,
      this.imagePath,
      this.canBeRandomized,
      this.dlc});

  factory Mod.fromJson(final Map<String, dynamic> json) {
    var filesList = json['files'] as List<dynamic>;
    List<Map<String, String>> parsedFiles = filesList.map((final fileItem) {
      Map<String, dynamic> fileMap = fileItem as Map<String, dynamic>;
      return fileMap
          .map((final key, final value) => MapEntry(key, value.toString()));
    }).toList();

    return Mod(
      id: json['id'].toString(),
      name: json['name'],
      version: json['version'],
      author: json['author'],
      description: json['description'],
      files: parsedFiles,
      imagePath: json['imagePath'],
      canBeRandomized: json['randomized'],
      dlc: json['dlc'],
    );
  }
}

// ignore: must_be_immutable
class ModsList extends ConsumerStatefulWidget {
  final CLIArguments cliArguments;
  final ModStateManager modStateManager;
  List<Mod> mods;
  final Function? refreshModsList;

  ModsList({
    super.key,
    required this.mods,
    required this.cliArguments,
    required this.modStateManager,
    this.refreshModsList,
  });

  @override
  ConsumerState<ModsList> createState() => _ModsListState();
}

class _ModsListState extends ConsumerState<ModsList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  double modLoaderWidgetOpacity = 0.0;
  bool shouldShowMissingFilesSnackbar = false;
  final Map<String, bool> _installingMods = {};
  final Map<int, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    widget.modStateManager.fetchAndUpdateModsList();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        modLoaderWidgetOpacity = 1.0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      verifyAllModFiles();
    });

    NotificationManager.notificationStream.listen((final event) {
      if (mounted && event.message == "Affected mods have been handled") {
        _showStyledPopup();
      }
    });
  }

  void _showStyledPopup() {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return ModPopup(
          currentlyIgnored: DatabaseIgnoredFilesHandler.ignoredFiles,
          affectedModsInfo: widget.modStateManager.affectedModsInfo,
          onDismiss: () {
            widget.modStateManager.clearAffectedModsInfo();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> toggleInstallUninstallMod(final int index) async {
    bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
    bool doesDllExist = await doesDatExtractionDllExist();

    if (isNierRunning) {
      showNierIsRunningDialog(context, ref);
      return;
    }

    if (!doesDllExist) {
      showDllDoesNotExistDialog(context, ref);
      return;
    }

    setState(() {
      _loadingMap[index] = true;
    });

    try {
      Mod mod = widget.mods[index];
      final modInstallHandler = ModInstallHandler(widget.cliArguments);
      final globalState = ref.watch(globalStateProvider);

      if (mod.dlc!.toBool() && !globalState.hasDLC) {
        globalLog("Mod requires DLC which is not available.");
        SnackBarHandler.showSnackBar(
            context,
            ref,
            'The mod "${mod.name}" requires DLC, which is not available. Please enable the DLC in the Action Panel if it is installed.',
            SnackBarType.failure);

        setState(() {
          _loadingMap[index] = false;
        });
        return;
      }

      if (widget.modStateManager.isModInstalled(mod.id)) {
        // Uninstall the mod
        await modInstallHandler.uninstallMod(mod.id);
        widget.modStateManager.uninstallMod(mod.id);
        List<String> filenamesToRemove = mod.files
            .map((final fileMap) => fileMap['path'] ?? '')
            .where((final path) => path.isNotEmpty)
            .map((final path) => p.basename(path))
            .toList();
        await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(
            filenamesToRemove);
      } else {
        // Install the mod
        await modInstallHandler.copyModToInstallPath(mod.id);
        widget.modStateManager.installMod(mod.id);
        for (var fileMap in mod.files) {
          String filePath = fileMap['path'] ?? '';
          if (filePath.isNotEmpty) {
            String fileName = p.basename(filePath);
            DatabaseIgnoredFilesHandler.ignoredFiles.add(fileName);
          }
        }
        await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();
      }

      SnackBarHandler.showSnackBar(
          context,
          ref,
          widget.modStateManager.isModInstalled(mod.id)
              ? 'Mod installed.'
              : 'Mod uninstalled.',
          SnackBarType.info);
    } catch (error) {
      SnackBarHandler.showSnackBar(
          context, ref, 'Error: $error', SnackBarType.failure);
    } finally {
      setState(() {
        _loadingMap[index] = false;
      });
    }
  }

  Future<void> verifyAllModFiles() async {
    final modInstallHandler = ModInstallHandler(widget.cliArguments);

    bool foundInvalidFiles = false;
    for (var mod in widget.mods) {
      List<String> invalidFiles =
          await modInstallHandler.verifyModFiles(mod.id);
      if (invalidFiles.isNotEmpty &&
          widget.modStateManager.isModInstalled(mod.id)) {
        List<String> filenamesToRemove = mod.files
            .map((final fileMap) => fileMap['path'] ?? '')
            .where((final path) => path.isNotEmpty)
            .map((final path) => p.basename(path))
            .toList();
        await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(
            filenamesToRemove);
        await modInstallHandler.removeModFiles(mod.id, invalidFiles);
        widget.modStateManager.uninstallMod(mod.id);
        foundInvalidFiles = true;
      }
    }

    if (foundInvalidFiles) {
      NotificationManager.notify(
        "One or more mods have been adjusted or have missing files and were partially uninstalled.",
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (shouldShowMissingFilesSnackbar) {
        SnackBarHandler.showSnackBar(
            context,
            ref,
            'One or more mods have missing files and were uninstalled.',
            SnackBarType.info);

        shouldShowMissingFilesSnackbar = false;
      }
    });
    final modInstallHandler = ModInstallHandler(widget.cliArguments);

    return provider.Consumer<ModStateManager>(
        builder: (final context, final modStateManager, final child) {
      final modStateManager = provider.Provider.of<ModStateManager>(context);
      final mods = modStateManager.mods;
      return ListView.builder(
        itemCount: mods.length,
        itemBuilder: (final context, final index) {
          Mod mod = mods[index];
          bool modIsInstalled = modStateManager.isModInstalled(mod.id);
          return Card(
            color: AutomatoThemeColors.brown25(ref),
            shadowColor: AutomatoThemeColors.primaryColor(ref),
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            elevation: 15,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AutomatoThemeColors.darkBrown(ref)
                              .withOpacity(0.80),
                          spreadRadius: 3,
                          blurRadius: 9,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: mod.imagePath != null
                          ? Image.file(
                              File(mod.imagePath!),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (final context, final error,
                                  final stackTrace) {
                                return Image.asset(
                                  'assets/mods/mod${mod.id}.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (final BuildContext context,
                                      final Object error,
                                      final StackTrace? stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: AutomatoThemeColors.darkBrown(ref),
                                      child: Icon(
                                        size: 80.0,
                                        Icons.precision_manufacturing_outlined,
                                        color: AutomatoThemeColors.primaryColor(
                                            ref),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : Image.asset(
                              'assets/mods/mod${mod.id}.gif',
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (final BuildContext context,
                                  final Object error,
                                  final StackTrace? stackTrace) {
                                return Container(
                                  width: 150,
                                  height: 150,
                                  color: AutomatoThemeColors.darkBrown(ref),
                                  child: Icon(
                                    size: 80.0,
                                    Icons.precision_manufacturing_outlined,
                                    color:
                                        AutomatoThemeColors.primaryColor(ref),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mod.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text("Description: ${mod.description}"),
                        Text("Version: ${mod.version}"),
                        Text("Author: ${mod.author}"),
                        installRandomizeButton(index)
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    children: <Widget>[
                      _iconButton(index, modIsInstalled),
                      _iconUninstallButton(index, modIsInstalled),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () async {
                          bool? confirmationResult =
                              await showConditionalPopup(context, mod.name);
                          if (confirmationResult == true) {
                            bool deletedSuccessfully = await modInstallHandler
                                .deleteModMetadata(mod.id);
                            bool deleteModsSuccessfully =
                                await modInstallHandler
                                    .deleteModDirectory(mod.id);
                            if (deletedSuccessfully && deleteModsSuccessfully) {
                              setState(() {
                                mods.removeWhere(
                                    (final item) => item.id == mod.id);
                              });
                            } else {
                              //  print("Failed to delete mod metadata.");
                            }
                          }
                        },
                        tooltip: 'Delete Metadata',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  IconButton _iconButton(final index, final bool modIsInstalled) {
    bool isLoading = _loadingMap[index] ?? false;

    return IconButton(
      icon: isLoading
          ? Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: AutomatoLoading(
                  color: AutomatoThemeColors.bright(ref),
                  translateX: 0,
                  svgString: AutomatoSvgStrings.automatoSvgStrHead,
                ),
              ),
            )
          : Icon(
              modIsInstalled
                  ? Icons.check_circle_outline
                  : Icons.install_desktop,
              color: modIsInstalled
                  ? AutomatoThemeColors.primaryColor(ref)
                  : AutomatoThemeColors.darkBrown(ref),
            ),
      onPressed:
          isLoading ? null : () async => await toggleInstallUninstallMod(index),
      tooltip: modIsInstalled ? 'Uninstall Mod' : 'Only Install Mod',
    );
  }

  Widget _iconUninstallButton(final int index, final bool isInstalled) {
    if (!isInstalled) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: () => toggleInstallUninstallMod(index),
      tooltip: 'Uninstall Mod',
    );
  }

  Future<bool?> showConditionalPopup(
      final BuildContext context, final String mod) async {
    return showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Confirmation',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        content: Text('Are you sure you want to delete metadata for: $mod',
            style: const TextStyle(color: Color.fromARGB(221, 255, 255, 255))),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget installRandomizeButton(final int modIndex) {
    final mods = widget.modStateManager.mods;
    final modStateManager = provider.Provider.of<ModStateManager>(context);
    final bool isInstalled = modStateManager.isModInstalled(mods[modIndex].id);
    final bool isInstalling = _installingMods[mods[modIndex].id] ?? false;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isInstalling)
            Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: AutomatoLoading(
                  color: AutomatoThemeColors.bright(ref),
                  svgString: AutomatoSvgStrings.automatoSvgStrHead,
                ),
              ),
            )
          else
            AutomatoButton(
              label:
                  isInstalled ? "Uninstall Mod" : "Install and Randomize Mod",
              onPressed: () async =>
                  await installAndRandomize(modIndex, isInstalled: isInstalled),
              uniqueId: 'install_$modIndex',
              pointerColor: AutomatoThemeColors.bright(ref),
              startColor: isInstalled
                  ? AutomatoThemeColors.darkBrown(ref)
                  : AutomatoThemeColors.primaryColor(ref),
              endColor: isInstalled
                  ? AutomatoThemeColors.dangerZone(ref)
                  : AutomatoThemeColors.primaryColor(ref),
              baseColor: isInstalled
                  ? Colors.grey
                  : AutomatoThemeColors.darkBrown(ref),
              fontSize: 18,
            ),
        ],
      ),
    );
  }

  Future<void> installAndRandomize(final int modIndex,
      {required final bool isInstalled}) async {
    bool isNierRunning = ProcessService.isProcessRunning("NieRAutomata.exe");
    if (!isNierRunning) {
      final logState = provider.Provider.of<LogState>(context, listen: false);
      final modStateManager =
          provider.Provider.of<ModStateManager>(context, listen: false);
      var mods = widget.modStateManager.mods;
      final modInstallHandler = ModInstallHandler(widget.cliArguments);
      final globalState = ref.watch(globalStateProvider);
      Mod selectedMod = mods[modIndex];
      String modId = selectedMod.id;

      setState(() => _installingMods[modId] = true);

      // Stop installation if selectedMod requires DLC but user does not have DLC
      if (selectedMod.dlc!.toBool() && !globalState.hasDLC) {
        globalLog("Mod requires DLC which is not available.");

        SnackBarHandler.showSnackBar(
          context,
          ref,
          'The mod "${selectedMod.name}" requires DLC, which is not available. Please enable the DLC in the Action Panel if it is installed.',
          SnackBarType.failure,
        );

        setState(() => _installingMods[modId] = false);
        return;
      }

      if (!Platform.isWindows ||
          widget.cliArguments.input.isEmpty ||
          widget.cliArguments.specialDatOutputPath.isEmpty) {
        SnackBarHandler.showSnackBar(
          context,
          ref,
          !Platform.isWindows
              ? 'This feature is currently only supported on Windows.'
              : 'Please select both input and output directory first!',
          SnackBarType.failure,
        );

        setState(() => _installingMods[modId] = false);
        return;
      }

      if (isInstalled) {
        await _uninstallMod(selectedMod, modStateManager, logState);
        setState(() => _installingMods[modId] = false);
        return;
      }

      List<String> fileNames = selectedMod.files
          .map((final fileMap) => fileMap['path'] ?? '')
          .where((final path) => path.isNotEmpty)
          .map((final path) => p.basename(path))
          .toList();
      await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(fileNames);

      bool success =
          await _processModFiles(selectedMod, modInstallHandler, logState);

      if (success) {
        modStateManager.installMod(selectedMod.id);
        List<String> filenamesToSave = selectedMod.files
            .map((final fileMap) => fileMap['path'] ?? '')
            .where((final path) => path.isNotEmpty)
            .map((final path) => p.basename(path))
            .toList();

        await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(fileNames);
        DatabaseIgnoredFilesHandler.ignoredFiles.addAll(filenamesToSave);
        await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();

        SnackBarHandler.showSnackBar(
          context,
          ref,
          "Mod installed and randomized successfully!",
          SnackBarType.success,
        );
      } else {
        SnackBarHandler.showSnackBar(
          context,
          ref,
          "Error processing mod file",
          SnackBarType.failure,
        );
      }

      setState(() => _installingMods[modId] = false);
    } else {
      showNierIsRunningDialog(context, ref);
    }
  }

  Future<bool> _processModFiles(
      final Mod selectedMod,
      final ModInstallHandler modInstallHandler,
      final LogState logState) async {
    Set<String> uniqueDirectories = {};
    List<String> filesToHash = [];

    for (var file in selectedMod.files) {
      String filePath = file['path'] ?? '';
      String createdPath =
          "${await ensureSettingsDirectory()}/Modpackage/$filePath";
      var baseNameWithoutExtension = p.basenameWithoutExtension(createdPath);

      bool shouldProcess = _shouldProcessFileBasedOnGameOptions(
          baseNameWithoutExtension, createdPath);

      if (!shouldProcess) {
        bool copySuccess = await _copyFile(
            logState, createdPath, filePath, modInstallHandler, selectedMod.id);
        if (!copySuccess) {
          return false;
        }
      } else {
        uniqueDirectories.add(p.dirname(createdPath));
      }
    }

    bool success = true;
    for (String dirPath in uniqueDirectories) {
      List<String> arguments = List.from(widget.cliArguments.processArgs);
      final selectedSetup =
          ref.read(setupConfigProvider.notifier).getCurrentSelectedSetup();
      if (selectedSetup != null) {
        arguments = selectedSetup.generateArguments(ref);
      }

      arguments[0] = dirPath;
      success = await _executeCLICommand(logState, arguments) && success;
      if (!success) {
        logState.addLog("Failed to process directory: $dirPath");
        break;
      }
    }

    if (success) {
      // Compute and store the hashes only after all other processes are finished
      for (var file in selectedMod.files) {
        String originalFilePath = file['path'] ?? '';

        // Normalize the path by removing the modId directory and any './'
        String installedFilePath = p.join(
            widget.cliArguments.specialDatOutputPath,
            p.normalize(p.joinAll(p.split(originalFilePath)..removeAt(0))));

        if (await File(installedFilePath).exists()) {
          filesToHash.add(installedFilePath);
        } else {
          logState.addLog(
              "File not found at the installed path: $installedFilePath");
        }
      }

      for (String filePath in filesToHash) {
        String fileHash = await FileUtils.computeFileHash(File(filePath));
        await SharedPreferencesUtils.storeFileHash(
            selectedMod.id, filePath, fileHash);
      }
    }

    return success;
  }

  bool _shouldProcessFileBasedOnGameOptions(
      final String baseNameWithoutExtension, final String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    if (extension != '.dat') {
      return false;
    }

    final gameOptions = [
      ...GameFileOptions.questOptions,
      ...GameFileOptions.mapOptions,
      ...GameFileOptions.enemyOptions,
      ...GameFileOptions.phaseOptions,
    ];

    return gameOptions.contains(baseNameWithoutExtension);
  }

  Future<bool> _executeCLICommand(
      final LogState logState, final List<String> arguments) async {
    final globalState = ref.read(globalStateProvider.notifier);
    try {
      arguments.modifyArgumentsForForcedEnemyList();
      final receivePort = ReceivePort();

      receivePort.listen((final message) {
        if (message is String) {
          logState.addLog(message);
        }
      });

      Map<String, dynamic> args = {
        'processArgs': arguments,
        'isManagerFile': true,
        'sendPort': receivePort.sendPort,
        'backUp': false,
        'isBalanceMode': globalState.readIsBalanceMode(),
        'hasDLC': globalState.readHasDLC(),
        'isAddition': false
      };
      globalState.setIsModManagerPageProcessing(
          isModManagerPageProcessing: true);
      await compute(runNierCliIsolated, args);
      globalLog("Randomization process finished the mod file successfully.");
      globalState.setIsModManagerPageProcessing(
          isModManagerPageProcessing: false);
      return true;
    } catch (e, stacktrace) {
      logState.addLog("Error executing CLI command: $e");
      globalState.setIsModManagerPageProcessing(
          isModManagerPageProcessing: false);
      globalLog(Trace.from(stacktrace).toString());
      return false;
    }
  }

  Future<bool> _copyFile(
      final LogState logState,
      final String createdPath,
      final String filePath,
      final ModInstallHandler modInstallHandler,
      final String modId) async {
    try {
      String targetPath =
          await modInstallHandler.createModInstallPath(filePath);
      await Directory(p.dirname(targetPath)).create(recursive: true);
      await File(createdPath).copy(targetPath);
      String fileHash = await FileUtils.computeFileHash(File(targetPath));
      await SharedPreferencesUtils.storeFileHash(modId, targetPath, fileHash);
      logState.addLog("Copied file: $filePath to $targetPath");
      return true;
    } catch (e) {
      logState.addLog("Failed to copy file: $e");
      return false;
    }
  }

  Future<void> _uninstallMod(final Mod selectedMod,
      final ModStateManager modStateManager, final LogState logState) async {
    final modInstallHandler = ModInstallHandler(widget.cliArguments);
    try {
      await modInstallHandler.uninstallMod(selectedMod.id);
      modStateManager.uninstallMod(selectedMod.id);
      List<String> filenamesToRemove = selectedMod.files
          .map((final fileMap) => fileMap['path'] ?? '')
          .where((final path) => path.isNotEmpty)
          .map((final path) => p.basename(path))
          .toList();
      await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(
          filenamesToRemove);

      SnackBarHandler.showSnackBar(
        context,
        ref,
        "Mod uninstalled successfully!",
        SnackBarType.success,
      );
    } catch (e) {
      logState.addLog("Exception caught while uninstalling mod: $e");
      SnackBarHandler.showSnackBar(
        context,
        ref,
        "Exception caught: $e",
        SnackBarType.failure,
      );
    }
  }
}
