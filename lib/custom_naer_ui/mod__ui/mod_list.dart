// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/handle_mod_install.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
import 'package:NAER/nier_enemy_data/category_data/nier_categories.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class Mod {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final List<Map<String, String>> files;
  final String? imagePath;

  Mod({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.files,
    this.imagePath,
  });

  factory Mod.fromJson(Map<String, dynamic> json) {
    var filesList = json['files'] as List<dynamic>;
    List<Map<String, String>> parsedFiles = filesList.map((fileItem) {
      Map<String, dynamic> fileMap = fileItem as Map<String, dynamic>;
      return fileMap.map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    return Mod(
      id: json['id'].toString(),
      name: json['name'],
      version: json['version'],
      author: json['author'],
      description: json['description'],
      files: parsedFiles,
      imagePath: json['imagePath'],
    );
  }
}

// ignore: must_be_immutable
class ModsList extends StatefulWidget {
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
  State<ModsList> createState() => _ModsListState();
}

class _ModsListState extends State<ModsList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late AnimationController _animationController;
  double modLoaderWidgetOpacity = 0.0;
  bool shouldShowMissingFilesSnackbar = false;
  final Map<String, bool> _installingMods = {};

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      verifyAllModFiles();
    });

    NotificationManager.notificationStream.listen((event) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Notification"),
              content: Text(event.message),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleInstallUninstallMod(int index) async {
    Mod mod = widget.mods[index];
    final ModInstallHandler modInstallHandler = ModInstallHandler(
        cliArguments: widget.cliArguments,
        modStateManager: widget.modStateManager);

    if (widget.modStateManager.isModInstalled(mod.id)) {
      // Call to uninstall the mod
      await modInstallHandler.uninstallMod(mod.id);
      widget.modStateManager.uninstallMod(mod.id);
    } else {
      await modInstallHandler.copyModToInstallPath(mod.id);
      widget.modStateManager.installMod(mod.id);
      await modInstallHandler.printAllSharedPreferences();
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!widget.modStateManager.isModInstalled(mod.id)
            ? 'Mod uninstalled.'
            : 'Mod installed.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> verifyAllModFiles() async {
    final ModInstallHandler modInstallHandler = ModInstallHandler(
      cliArguments: widget.cliArguments,
      modStateManager: widget.modStateManager,
    );

    bool foundInvalidFiles = false;
    for (var mod in widget.mods) {
      List<String> invalidFiles =
          await modInstallHandler.verifyModFiles(mod.id);
      if (invalidFiles.isNotEmpty &&
          widget.modStateManager.isModInstalled(mod.id)) {
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
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldShowMissingFilesSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'One or more mods have missing files and were uninstalled.'),
            duration: Duration(seconds: 3),
          ),
        );
        shouldShowMissingFilesSnackbar = false;
      }
    });
    final ModInstallHandler modInstallHandler = ModInstallHandler(
      cliArguments: widget.cliArguments,
      modStateManager: widget.modStateManager,
    );
    return Consumer<ModStateManager>(
        builder: (context, modStateManager, child) {
      final modStateManager = Provider.of<ModStateManager>(context);
      final mods = modStateManager.mods;
      return ListView.builder(
        itemCount: mods.length,
        itemBuilder: (context, index) {
          Mod mod = mods[index];
          bool modIsInstalled = modStateManager.isModInstalled(mod.id);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: mod.imagePath != null
                        ? Image.file(
                            File(mod.imagePath!),
                            width: 90,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/mods/mod${mod.id}.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color:
                                        const Color.fromARGB(255, 54, 52, 52),
                                    child: const Icon(
                                      size: 80.0,
                                      Icons.precision_manufacturing_outlined,
                                      color: Color.fromARGB(255, 0, 174, 255),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : Image.asset(
                            'assets/mods/mod${mod.id}.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Container(
                                width: 150,
                                height: 150,
                                color: const Color.fromARGB(255, 54, 52, 52),
                                child: const Icon(
                                  size: 80.0,
                                  Icons.precision_manufacturing_outlined,
                                  color: Color.fromARGB(255, 0, 174, 255),
                                ),
                              );
                            },
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
                      IconButton(
                        icon: Icon(
                          modIsInstalled
                              ? Icons.check_circle_outline
                              : Icons.download,
                          color: modIsInstalled
                              ? const Color.fromARGB(255, 76, 163, 175)
                              : Colors.grey,
                        ),
                        onPressed: () => toggleInstallUninstallMod(index),
                        tooltip: modIsInstalled
                            ? 'Uninstall Mod'
                            : 'Only Install Mod',
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => toggleInstallUninstallMod(index),
                        tooltip: 'Uninstall Mod',
                      ),
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
                                mods.removeWhere((item) => item.id == mod.id);
                              });
                            } else {
                              print("Failed to delete mod metadata.");
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

  Future<bool?> showConditionalPopup(BuildContext context, String mod) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

  Widget installRandomizeButton(int modIndex) {
    final mods = widget.modStateManager.mods;
    final modStateManager = Provider.of<ModStateManager>(context, listen: true);
    final bool isInstalled = modStateManager.isModInstalled(mods[modIndex].id);
    final bool isInstalling = _installingMods[mods[modIndex].id] ?? false;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isInstalling)
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 0, 183, 255),
            )
          else
            ElevatedButton(
              onPressed: () => installAndRandomize(modIndex, isInstalled),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isInstalled
                    ? Colors.grey
                    : const Color.fromARGB(255, 76, 163, 175),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                  isInstalled ? "Uninstall Mod" : "Install and Randomize Mod"),
            ),
        ],
      ),
    );
  }

  Future<void> installAndRandomize(int modIndex, bool isInstalled) async {
    final logState = Provider.of<LogState>(context, listen: false);
    final modStateManager =
        Provider.of<ModStateManager>(context, listen: false);
    Mod selectedMod = widget.mods[modIndex];
    String modId = selectedMod.id;
    final ModInstallHandler modInstallHandler = ModInstallHandler(
        cliArguments: widget.cliArguments,
        modStateManager: widget.modStateManager);

    setState(() {
      _installingMods[modId] = true;
    });

    if (!Platform.isWindows ||
        widget.cliArguments.input.isEmpty ||
        widget.cliArguments.specialDatOutputPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!Platform.isWindows
              ? 'This feature is currently only supported on Windows.'
              : 'Please select both input and output directory first on the first page!'),
        ),
      );
      setState(() => _installingMods[modId] = false);
      return;
    }

    if (modIndex < 0 || modIndex >= widget.mods.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid mod selection.')),
      );
      setState(() => _installingMods[modId] = false);
      return;
    }

    if (isInstalled) {
      try {
        await modInstallHandler.uninstallMod(selectedMod.id);
        modStateManager.uninstallMod(selectedMod.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mod uninstalled successfully!")),
        );
      } catch (e) {
        logState.addLog("Exception caught while uninstalling mod: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exception caught: $e")),
        );
      } finally {
        setState(() => _installingMods[modId] = false);
      }
      return;
    }

    var currentDir = Directory.current.path;
    String command = p.join(currentDir, 'bin', 'fork', 'nier_cli.exe');
    bool success = true;
    List<String> randomizedFilesPaths = [];
    List<String> copiedFilesPaths = [];

    for (var file in selectedMod.files) {
      String filePath = file['path'] ?? '';
      String createdPath =
          "${await FileChange.ensureSettingsDirectory()}/Modpackage/$filePath";
      var baseNameWithoutExtension = p.basenameWithoutExtension(createdPath);
      String directoryPath = p.dirname(createdPath);
      List<String> arguments = List.from(widget.cliArguments.processArgs);
      arguments[0] = directoryPath;
      bool shouldProcess = questOptions.contains(baseNameWithoutExtension) ||
          mapOptions.contains(baseNameWithoutExtension) ||
          phaseOptions.contains(baseNameWithoutExtension);
      String targetPath =
          await modInstallHandler.createModInstallPath(filePath);

      if (!shouldProcess) {
        // Copy action for non-randomized files
        await Directory(p.dirname(targetPath)).create(recursive: true);
        try {
          await File(createdPath).copy(targetPath);
          copiedFilesPaths.add(targetPath);
          String fileHash =
              await modInstallHandler.computeFileHash(File(targetPath));
          await modInstallHandler.storeFileHashInPreferences(
              modId, targetPath, fileHash);
        } catch (e) {
          logState.addLog("Failed to copy file: $e");
        }
        continue;
      }

      // Randomization process
      try {
        Process process =
            await Process.start(command, arguments, runInShell: true);
        await for (var output in process.stdout.transform(utf8.decoder)) {
          logState.addLog(output);
        }
        await for (var error in process.stderr.transform(utf8.decoder)) {
          logState.addLog(error);
        }
        int exitCode = await process.exitCode;
        if (exitCode == 0) {
          randomizedFilesPaths.add(targetPath);
          File randomizedFile = File(targetPath);
          String fileHash = await modInstallHandler
              .computeFileHash(randomizedFile); // Compute hash for the File
          await modInstallHandler.storeFileHashInPreferences(
              modId, filePath, fileHash); // Store the hash
        } else {
          success = false;
        }
      } catch (e) {
        success = false;
        logState.addLog("Error processing file: $e");
      }
    }

    if (success) {
      await modInstallHandler.markFilesRandomized(modId, randomizedFilesPaths);
      await modInstallHandler.printAllSharedPreferences();
      modStateManager.installMod(selectedMod.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Mod installed and randomized successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error processing mod file")));
    }

    setState(() => _installingMods[modId] = false);
  }
}
