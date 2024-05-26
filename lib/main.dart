// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:NAER/data/boss_data/nier_boss_class_list.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_ui/animations/dotted_line_progress_animation.dart';
import 'package:NAER/naer_ui/animations/shacke_animation_widget.dart';
import 'package:NAER/naer_ui/appbar/appbar.dart';
import 'package:NAER/naer_ui/directory_ui/check_pathbox.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_ui/other/asciiArt.dart';
import 'package:NAER/naer_ui/other/shacking_message_list.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/nier_cli/nier_cli.dart';
import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart' as enemy_data;

import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    bool isManagerFile = false;
    await nierCli(arguments, isManagerFile);
    exit(0);
  } else {
    runApp(
      ChangeNotifierProvider(
        create: (context) => LogState(),
        child: EnemyRandomizerApp(),
      ),
    );
  }
}

class EnemyRandomizerApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  EnemyRandomizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'NieR:Automata Enemy Randomizer Tool',
      theme: ThemeData.dark().copyWith(
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromARGB(255, 65, 21, 0),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const EnemyRandomizerAppState(),
    );
  }
}

class EnemyRandomizerAppState extends StatefulWidget {
  const EnemyRandomizerAppState({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EnemyRandomizerAppState createState() => _EnemyRandomizerAppState();
}

class _EnemyRandomizerAppState extends State<EnemyRandomizerAppState>
    with TickerProviderStateMixin {
  GlobalKey setupDirectorySelectionKey = GlobalKey();
  GlobalKey setupImageGridKey = GlobalKey();
  GlobalKey setupCategorySelectionKey = GlobalKey();
  GlobalKey setupLogOutputKey = GlobalKey();
  GlobalKey<EnemyImageGridState> enemyImageGridKey = GlobalKey();
  List<String> createdFiles = [];
  List<String> createdDatFiles = [];
  List<String> ignoredModFiles = [];
  List<String> logMessages = [];
  Set<String> loggedStages = {};
  bool isLoading = false;
  bool isButtonEnabled = true;
  bool isLogIconBlinking = false;
  bool hasError = false;
  bool isProcessing = false;
  bool selectAllQuests = true;
  bool selectAllMaps = true;
  bool selectAllPhases = true;
  bool savePaths = false;
  String input = '';
  String scriptPath = '';
  String specialDatOutputPath = '';
  String? _lastLogProcessed;
  int enemyLevel = 1;
  int _selectedIndex = 0;
  double enemyStats = 0.0;
  Map<String, bool> stats = {"None": true, "Select All": false};
  Map<String, bool> categories = {};
  Map<String, bool> level = {
    "All Enemies": false,
    "All Enemies without Randomization": false,
    // "Only Bosses": false,
    // "Only Selected Enemies": false,
    'None': true
  };
  List<dynamic> getAllItems() {
    return [
      ...ScriptingPhase.scriptingPhases,
      ...MapLocation.mapLocations,
      ...SideQuest.sideQuests,
    ];
  }

  void logAndprint(String message) {
    // prin(message);
    logState.addLog(message);
  }

  late ScrollController scrollController;
  late AnimationController _blinkController;
  late Future<bool> _loadPathsFuture;

  @override
  void initState() {
    super.initState();
    FileChange.loadChanges();
    FileChange.loadIgnoredFiles().then((_) {}).catchError((error) {});
    updateItemsByType(SideQuest, true);
    updateItemsByType(MapLocation, true);
    updateItemsByType(ScriptingPhase, true);
    _loadPathsFuture = loadPathsFromSharedPreferences();
    scrollController = ScrollController();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 1000),
    );

    log('initState called');
  }

  void startBlinkAnimation() {
    if (!_blinkController.isAnimating) {
      _blinkController.forward(from: 0).then((_) {
        _blinkController.reverse();
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
    log('dispose called');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 28, 31, 32),
                  Color.fromARGB(255, 45, 45, 48),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: <Widget>[
                NaerAppBar(
                  blinkController: _blinkController,
                  scrollToSetup: () => scrollToSetup(setupLogOutputKey),
                  setupLogOutputKey: setupLogOutputKey,
                  button: navigateButton(context),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 28, 31, 32),
                Color.fromARGB(255, 45, 45, 48),
              ],
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5),
              topLeft: Radius.circular(5),
            ),
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.select_all, size: 32.0),
                label: 'Select All',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cancel, size: 32.0),
                label: 'Unselect All',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.undo, size: 32.0, color: Colors.red),
                label: 'Undo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shuffle, size: 32.0, color: Colors.green),
                label: 'Modify',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
        body: Stack(children: [
          Positioned.fill(
              child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(255, 24, 23, 23).withOpacity(0.9),
              BlendMode.srcOver,
            ),
            child: Image.asset('assets/naer_backgrounds/naer_background.png',
                fit: BoxFit.cover),
          )),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      KeyedSubtree(
                          key: setupDirectorySelectionKey,
                          child: setupDirectorySelection()),
                    ],
                  ),
                ),
                KeyedSubtree(
                  key: setupCategorySelectionKey,
                  child: setupAllCategorySelections(),
                ),
                KeyedSubtree(
                  key: setupImageGridKey,
                  child: EnemyImageGrid(key: enemyImageGridKey),
                ),
                KeyedSubtree(
                  key: setupLogOutputKey,
                  child: setupLogOutput(
                      logMessages, context, clearLogMessages, scrollController),
                ),
              ],
            ),
          ),
        ]));
  }

  ElevatedButton navigateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        CLIArguments cliArgs = await gatherCLIArguments(
          scrollController: scrollController,
          enemyImageGridKey: enemyImageGridKey,
          categories: categories,
          level: level,
          ignoredModFiles: ignoredModFiles,
          input: input,
          specialDatOutputPath: specialDatOutputPath,
          scriptPath: scriptPath,
          enemyStats: enemyStats,
          enemyLevel: enemyLevel,
        );

        ModInstallHandler modInstallHandler =
            ModInstallHandler(cliArguments: cliArgs);
        ModStateManager modStateManager = ModStateManager(modInstallHandler);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ModStateManager>(
              create: (_) => modStateManager,
              child: SecondPage(cliArguments: cliArgs),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 45, 45, 48),
        backgroundColor: const Color.fromARGB(255, 28, 31, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      child: const Text(
        'Mod Manager',
        style: TextStyle(
          fontSize: 16.0,
          color: Color.fromRGBO(0, 255, 255, 1),
        ),
      ),
    );
  }

  void scrollToSetup(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context);
    }
  }

  bool isLastMessageProcessing() {
    if (logMessages.isNotEmpty) {
      String lastMessage = logMessages.last;

      bool isProcessing = lastMessage.isNotEmpty &&
          !lastMessage.contains("Completed") &&
          !lastMessage.contains("Error") &&
          !lastMessage.contains("Randomization") &&
          !lastMessage.contains("NieR CLI") &&
          !lastMessage.contains("Last");

      return isProcessing;
    }

    return false;
  }

  Widget setupDirectorySelection() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directory Selection',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                DirectorySelectionCard(
                    title: "Input Directory:",
                    path: input,
                    onBrowse: (updatePath) => openInputFileDialog(updatePath),
                    icon: Icons.folder_open,
                    hints: "Hints: Your Game data folder."),
                DirectorySelectionCard(
                    title: "Output Directory:",
                    path: specialDatOutputPath,
                    onBrowse: (updatePath) => openOutputFileDialog(updatePath),
                    icon: Icons.folder_open,
                    hints: "Hints: Also Game data folder."),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_full, size: 18),
                  label:
                      const Text('Open output', style: TextStyle(fontSize: 14)),
                  onPressed: () => getOutputPath(context, specialDatOutputPath),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Settings', style: TextStyle(fontSize: 14)),
                  onPressed: getNaerSettings,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
                ),
                savePathCheckbox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget savePathCheckbox() {
    return FutureBuilder<bool>(
      future: _loadPathsFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SavePathsWidget(
            input: input,
            output: specialDatOutputPath,
            scriptPath: scriptPath,
            savePaths: savePaths,
            onCheckboxChanged: (bool value) async {
              if (!value) {
                await clearPathsFromSharedPreferences();
                setState(() {
                  input = '';
                  specialDatOutputPath = '';
                  scriptPath = '';
                });
              }
              setState(() {
                savePaths = value;
              });
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  void getOutputPath(BuildContext context, String outputPath) async {
    if (outputPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Output path is empty')),
      );
      return;
    }

    outputPath = outputPath.replaceAll('"', '');

    if (!await Directory(outputPath).exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Path does not exist: $outputPath')),
      );
      return;
    }

    if (Platform.isWindows) {
      await Process.run('explorer', [outputPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [outputPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [outputPath]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Opening output path is not supported on this platform.')),
      );
    }
  }

  void getNaerSettings() async {
    String settingsDirectoryPath = await FileChange.ensureSettingsDirectory();

    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', settingsDirectoryPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [settingsDirectoryPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [settingsDirectoryPath]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Opening output path is not supported on this platform.'),
        ),
      );
    }
  }

  Future<void> openInputFileDialog(Function(String) updatePath) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var containsValidFiles = await _containsValidFiles(selectedDirectory);

      if (containsValidFiles) {
        setState(() {
          input = selectedDirectory.convertAndEscapePath();
        });
        updatePath(selectedDirectory);
      } else {
        _showInvalidDirectoryDialog();
        updatePath('');
      }
    } else {
      updatePath('');
    }
  }

  void _showInvalidDirectoryDialog() {
    if (!mounted) return;

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

  Future<bool> _containsValidFiles(String directoryPath) async {
    var directory = Directory(directoryPath);
    var files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        var extension = file.path.split('.').last;
        if (extension == 'cpk' || extension == 'dat') {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> openOutputFileDialog(Function(String) updatePath) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        specialDatOutputPath = selectedDirectory.convertAndEscapePath();
      });
      updatePath(selectedDirectory);

      var modFiles = await findModFiles(selectedDirectory);
      if (modFiles.isNotEmpty) {
        showModsMessage(modFiles, (updatedModFiles) async {
          if (updatedModFiles.isEmpty) {
            setState(() {
              ignoredModFiles = [];
            });
          } else {
            setState(() {
              ignoredModFiles = updatedModFiles;
            });
          }
          log("Updated ignoredModFiles after dialog: $ignoredModFiles");
          final prefs = await SharedPreferences.getInstance();
          String jsonData = jsonEncode(ignoredModFiles);
          await prefs.setString('ignored_mod_files', jsonData);
        });
      } else {
        _showNoModFilesDialog();
      }
    } else {
      updatePath('');
    }
  }

  void _showNoModFilesDialog() {
    if (!mounted) return;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        enemyImageGridKey.currentState?.selectAllImages();
        break;
      case 1:
        enemyImageGridKey.currentState?.unselectAllImages();
        break;
      case 2:
        showUndoConfirmation();
        break;
      case 3:
        onPressedAction();
        break;
      default:
        break;
    }
  }

  void handleStartRandomizing() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        isButtonEnabled = false;
      });

      try {
        await FileChange.savePreRandomizationTime();
        log("Ignored mod files before starting: $ignoredModFiles");
        await startRandomizing();
        await FileChange.saveChanges();
      } catch (e) {
        log("Error during randomization: $e");
      } finally {
        setState(() {
          isLoading = false;
          isButtonEnabled = true;
        });
      }
    }
  }

  void onPressedAction() {
    if (isButtonEnabled) {
      showModifyConfirmation();
    }
  }

  Future<Map<String, List<String>>> sortSelectedEnemies(
      List<String> selectedImages) async {
    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;
    var enemyGroups = await readEnemyData();

    var formattedSelectedImages =
        selectedImages!.map((image) => image.split('.').first).toList();

    var sortedSelection = {
      "Ground": <String>[],
      "Fly": <String>[],
      "Delete": List<String>.from(enemyGroups["Delete"] ?? [])
    };

    for (var enemy in formattedSelectedImages) {
      bool found = false;
      for (var group in ["Ground", "Fly"]) {
        if (enemyGroups[group]?.contains(enemy) ?? false) {
          sortedSelection[group]?.add(enemy);
          found = true;
          break;
        }
      }
      if (!found) {}
    }

    return sortedSelection;
  }

// MAIN MODIFY BUTTON FUNCTIONALITY
  Future<void> startRandomizing() async {
    hasError = true;
    setState(() {
      isLoading = true;
      loggedStages.clear();
    });

    if (input.isEmpty || specialDatOutputPath.isEmpty) {
      updateLog("Error: Please select both input and output directories. 💋 ",
          scrollController);
      return;
    }

    updateLog("Starting randomization process... 🏃‍➡️", scrollController);

    try {
      CLIArguments cliArgs = await gatherCLIArguments(
        scrollController: scrollController,
        enemyImageGridKey: enemyImageGridKey,
        categories: categories,
        level: level,
        ignoredModFiles: ignoredModFiles,
        input: input,
        specialDatOutputPath: specialDatOutputPath,
        scriptPath: scriptPath,
        enemyStats: enemyStats,
        enemyLevel: enemyLevel,
      );
      bool isManagerFile = false;
      await nierCli(cliArgs.processArgs, isManagerFile);

      updateLog(
          "Randomization process completed successfully.", scrollController);
    } on Exception catch (e) {
      updateLog("Error occurred: $e", scrollController);
    } finally {
      setState(() {
        isLoading = false;
      });
      updateLog(
          'Thank you for using the randomization tool.', scrollController);
      updateLog(asciiArt2B, scrollController);
      updateLog("Randomization process finished.", scrollController);
      showCompletionDialog();
    }
  }

  void logErrorDetails(dynamic e, StackTrace stackTrace) {
    updateLog("Error: $e", scrollController);
    updateLog("Stack Trace: $stackTrace", scrollController);
  }

  Future<List<String>> findModFiles(String outputDirectory) async {
    List<String> modFiles = [];
    DateTime preRandomizationTime = await FileChange.getPreRandomizationTime();
    try {
      var directory = Directory(outputDirectory);
      if (await directory.exists()) {
        log("Scanning directory: $outputDirectory");
        await for (FileSystemEntity entity in directory.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dat')) {
            var fileModTime = await entity.lastModified();
            var fileName = path.basename(entity.path);
            if (fileName.contains("p100") ||
                fileName.contains("p200") ||
                fileName.contains("p300") ||
                fileName.contains("p400") ||
                fileName.contains("q") ||
                fileName.contains("r") ||
                fileName.contains("corehap") ||
                fileName.contains("em")) {
              log("Found .dat file: ${entity.path}, last modified: $fileModTime");

              if (fileModTime.isBefore(preRandomizationTime)) {
                modFiles.add(fileName);
                log("Adding mod file: $fileName");
              }
            }
          }
        }
      } else {
        log("Directory does not exist: $outputDirectory");
      }
    } catch (e) {
      log('Error while finding mod files: $e');
    }
    FileChange.ignoredFiles.addAll(modFiles);
    await FileChange.saveIgnoredFiles();
    log("Mod files found: $modFiles");
    return modFiles;
  }

  Future<Map<String, List<String>>> readEnemyData() async {
    return enemy_data.enemyData;
  }

  void undoLastRandomization() async {
    await FileChange.loadChanges();
    await FileChange.undoChanges();

    try {
      for (var filePath in createdFiles) {
        var file = File(filePath);

        if (await file.exists()) {
          try {
            await file.delete();
            log("Deleted file: $filePath");
          } catch (e) {
            log("Error deleting file $filePath: $e");
            setState(() {
              logMessages.add("Error deleting file $filePath: $e");
              startBlinkAnimation();
            });
          }
        } else {
          log("File not found: $filePath");
          setState(() {
            logMessages.add("File not found: $filePath");
            startBlinkAnimation();
          });
        }
      }

      setState(() {
        logMessages.add("Last randomization undone.");
        setState(() {
          startBlinkAnimation();
          isLoading = false;
          isProcessing = false;
        });

        createdFiles.clear();
      });
    } catch (e) {
      log("An error occurred during undo: $e");
      setState(() {
        logMessages.add("Error during undo: $e");
        startBlinkAnimation();
        isLoading = false;
        isProcessing = false;
      });
    }
  }

  void showUndoConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Undo"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to undo the last randomization?",
              ),
              SizedBox(height: 10),
              Text(
                "Important:",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Text(
                "• Avoid using this function while the game is running as it may cause issues.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes, Undo"),
              onPressed: () {
                Navigator.of(context).pop();
                undoLastRandomization();
              },
            ),
          ],
        );
      },
    );
  }

  void showModifyConfirmation() {
    String modificationDetails = _generateModificationDetails();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Modification"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text(
                    "Are you sure you want to start modification? Below are the selected settings:"),
                const SizedBox(height: 10),
                Text(modificationDetails),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("No, I still have work to do."),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes, Modify"),
              onPressed: () {
                Navigator.of(context).pop();
                handleStartRandomizing();
              },
            ),
          ],
        );
      },
    );
  }

  String _generateModificationDetails() {
    List<String> details = [];

    String bossList = getSelectedBossesNames();

    String categoryDetail = level.entries
        .firstWhere((entry) => entry.value,
            orElse: () => const MapEntry("None", false))
        .key;
    details.add("• Level Modify Category: $categoryDetail");

    if (categoryDetail == 'None') {
      details.add("• Change Level: None");
    } else {
      details.add("• Change Level: $enemyLevel");
    }

    if (bossList.isNotEmpty && enemyStats != 0.0) {
      details.add("• Change Boss Stats: x$enemyStats for $bossList");
    } else {
      details.add("• Change Boss Stats: None");
    }

    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;
    if (selectedImages != null && selectedImages.isNotEmpty) {
      details.add("• Selected Enemies: ${selectedImages.join(', ')}");
    } else {
      details.add(
          "• Selected Enemies: No Enemy selected, will use ALL Enemies for Randomization");
    }

    switch (categoryDetail) {
      case "All Enemies":
        details.add(
            "• Level Change: Every randomized enemy & bosses in the game will be included.");
        break;
      // case "Only Bosses":
      //   details.add("• Level Change: Only boss-type enemies will be included.");
      //   break;
      // case "Only Selected Enemies":
      //   details.add(
      //       "• Level Change: Only randomized selected enemies will be included.");

      //   break;
      case "None":
        details.add(
            "• Level Change: No specific category selected. No level will be modified");
        break;
      default:
        details.add("• Default settings will be used.");
        break;
    }

    List<String> selectedCategories = categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    if (selectedCategories.isNotEmpty) {
      details.add("• Selected Categories: ${selectedCategories.join(', ')}");
    } else {
      details
          .add("• No specific categories selected. Will use all categories!!!");
    }

    return details.join('\n\n');
  }

  Widget setupLogOutput(List<String> logMessages, BuildContext context,
      VoidCallback clearLogMessages, ScrollController scrollController) {
    Color messageColor(String message) {
      if (message.toLowerCase().contains('error') ||
          message.toLowerCase().contains('failed')) {
        return Colors.red;
      } else if (message.toLowerCase().contains('no selected') ||
          message.toLowerCase().contains('processed') ||
          message.toLowerCase().contains('found') ||
          message.toLowerCase().contains('temporary')) {
        return Colors.yellow;
      } else if (message.toLowerCase().contains('completed') ||
          message.toLowerCase().contains('finished')) {
        return const Color.fromARGB(255, 59, 255, 59);
      } else {
        return Colors.white;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    List<InlineSpan> buildLogMessageSpans() {
      return logMessages.map((message) {
        String logIcon;
        if (message.toLowerCase().contains('error') ||
            message.toLowerCase().contains('failed')) {
          logIcon = '💥 ';
        } else if (message.toLowerCase().contains('warning')) {
          logIcon = '⚠️ ';
        } else {
          logIcon = 'ℹ️ ';
        }

        return TextSpan(
          text: '$logIcon$message\n',
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            color: messageColor(message),
          ),
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100.0, right: 150, left: 150),
          child: Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 31, 29, 29),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 50,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(5.0),
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: logMessages.isNotEmpty
                            ? buildLogMessageSpans()
                            : [
                                const TextSpan(
                                    text:
                                        "Hey there! It's quiet for now... 🤫\n\n"),
                                TextSpan(text: asciiArt2B)
                              ],
                      ),
                    ),
                    if (isLastMessageProcessing())
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 100.0),
                        child: DottedLineProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 240, 71, 71)),
                ),
                onPressed: clearLogMessages,
                child: const Text('Clear Log'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy CLI Arguments'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 71, 192, 240)),
                ),
                onPressed: () => onnCopyArgsPressed(),
              ),
            ),
          ],
        )
      ],
    );
  }

  void onnCopyArgsPressed() {
    copyCLIArguments();
  }

  void copyCLIArguments() async {
    try {
      if (input.isEmpty || specialDatOutputPath.isEmpty) {
        updateLog("Error: Please select both input and output directories. 💋 ",
            scrollController);
        return;
      }

      CLIArguments cliArgs = await gatherCLIArguments(
        scrollController: scrollController,
        enemyImageGridKey: enemyImageGridKey,
        categories: categories,
        level: level,
        ignoredModFiles: ignoredModFiles,
        input: input,
        specialDatOutputPath: specialDatOutputPath,
        scriptPath: scriptPath,
        enemyStats: enemyStats,
        enemyLevel: enemyLevel,
      );

      updateLog(
          "NieR CLI Arguments: ${cliArgs.command} ${cliArgs.processArgs.join(' ')}",
          scrollController);

      Clipboard.setData(ClipboardData(text: cliArgs.fullCommand.join(' ')))
          .then((result) {
        const snackBar = SnackBar(content: Text('Command copied to clipboard'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((e) {
        updateLog("Error copying to clipboard: $e", scrollController);
      });
    } catch (e) {
      updateLog("Error gathering CLI arguments: $e", scrollController);
    }
  }

  Future<CLIArguments> gatherCLIArguments({
    required ScrollController scrollController,
    required GlobalKey<EnemyImageGridState> enemyImageGridKey,
    required Map<String, bool> categories,
    required Map<String, bool> level,
    required List<String> ignoredModFiles,
    required String input,
    required String specialDatOutputPath,
    required String scriptPath,
    required double enemyStats,
    required int enemyLevel,
  }) async {
    String tempFilePath;
    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;

    try {
      if (selectedImages!.isNotEmpty) {
        var sortedEnemies = await sortSelectedEnemies(selectedImages);
        var tempFile = await File(
                '${await FileChange.ensureSettingsDirectory()}/temp_sorted_enemies.dart')
            .create();
        var buffer = StringBuffer();
        buffer.writeln("const Map<String, List<String>> sortedEnemyData = {");
        sortedEnemies.forEach((group, enemies) {
          var enemiesFormatted = enemies.map((e) => '"$e"').join(', ');
          buffer.writeln('  "$group": [$enemiesFormatted],');
        });
        buffer.writeln("};");
        await tempFile.writeAsString(buffer.toString());
        tempFilePath = tempFile.path.convertAndEscapePath();
      } else {
        tempFilePath = "ALL";
      }
    } catch (e) {
      throw ArgumentError("Error creating temporary file");
    }

    String bossList = getSelectedBossesArgument();
    List<String> processArgs = [
      input,
      '--output',
      specialDatOutputPath,
      tempFilePath,
      '--bosses',
      bossList.isNotEmpty ? bossList : 'None',
      '--bossStats',
      enemyStats.toString(),
      '--level=$enemyLevel',
      ...categories.entries
          .where((entry) => entry.value)
          .map((entry) => "--${entry.key.replaceAll(' ', '').toLowerCase()}"),
    ];

    if (level["Only Selected Enemies"] == true) {
      processArgs.add("--category=onlyselectedenemies");
    }

    if (level["Only Bosses"] == true) {
      processArgs.add("--category=onlybosses");
    }

    if (level["All Enemies"] == true) {
      processArgs.add("--category=allenemies");
    }

    if (level["All Enemies without Randomization"] == true) {
      processArgs.add("--category=onlylevel");
    }

    if (level["None"] == true) {
      processArgs.add("--category=default");
    }

    List<String> ignoredModFiles = FileChange.ignoredFiles;
    if (ignoredModFiles.isNotEmpty) {
      String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
      processArgs.add(ignoreArgs);
      print("Ignore arguments added: $ignoreArgs");
    }

    String command = scriptPath;
    if (Platform.isMacOS || Platform.isLinux) {
      processArgs.insert(0, scriptPath);
      command = 'sudo';
    } else if (Platform.isWindows) {
      var currentDir = Directory.current.path;
      command = p.join(currentDir, 'NAER.exe');
    }

    List<String> fullCommand = [scriptPath] + processArgs;

    if (Platform.isMacOS || Platform.isLinux) {
      fullCommand = [scriptPath] + processArgs;
    } else if (Platform.isWindows) {
      fullCommand = [command] + processArgs;
    }

    return CLIArguments(
        input: input,
        specialDatOutputPath: specialDatOutputPath,
        tempFilePath: tempFilePath,
        bossList: bossList,
        processArgs: processArgs,
        command: command,
        fullCommand: fullCommand,
        ignoreList: ignoredModFiles);
  }

  void updateLog(String log, ScrollController scrollController) async {
    if (log.trim().isEmpty) {
      return;
    }

    final processedLog = LogState.processLog(log);

    if (processedLog.isEmpty || processedLog == _lastLogProcessed) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    setState(() {
      isProcessing = true;
      logMessages.add(processedLog);
      startBlinkAnimation();
      loggedStages.add(processedLog);
      _lastLogProcessed = processedLog;
      isProcessing = false;
    });

    onNewLogMessage(context, log);
  }

  void showCompletionDialog() {
    setState(() {
      isLoading = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Randomization Complete"),
          content: const Text("Randomization process completed successfully."),
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

  void showModsMessage(
      List<String> modFiles, Function(List<String>) onModFilesUpdated) {
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
                  Navigator.of(context).pop();
                  if (modFiles.isNotEmpty) {
                    Navigator.of(context).pop();
                    showModsMessage(modFiles, onModFilesUpdated);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
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

  void clearLogMessages() {
    setState(() {
      logMessages.clear();
    });
  }

  void updateItemsByType(Type type, bool value) {
    List<dynamic> allItems = getAllItems();
    for (var item in allItems.where((item) => item.runtimeType == type)) {
      categories[item.id] = value;
    }
  }

  Widget setupCategorySelection() {
    Widget specialCheckbox(
        String title, bool value, void Function(bool?) onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
              checkColor: Colors.white,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent[800],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Select Categories for Randomization",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          specialCheckbox(
            "All Quests",
            selectAllQuests,
            (newValue) {
              setState(() {
                selectAllQuests = newValue!;
                updateItemsByType(SideQuest, newValue);
              });
            },
          ),
          specialCheckbox(
            "All Maps",
            selectAllMaps,
            (newValue) {
              setState(() {
                selectAllMaps = newValue!;
                updateItemsByType(MapLocation, newValue);
              });
            },
          ),
          specialCheckbox(
            "All Phases",
            selectAllPhases,
            (newValue) {
              setState(() {
                selectAllPhases = newValue!;
                updateItemsByType(ScriptingPhase, newValue);
              });
            },
          ),
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: getAllItems().map((item) {
                  IconData icon = getIconForItem(item);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(icon, color: Colors.white, size: 28),
                      title: Text(
                        item.description,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: categories[item.id] ?? false,
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                          onChanged: (bool? newValue) {
                            setState(() {
                              categories[item.id] = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getIconForItem(dynamic item) {
    if (item is MapLocation) {
      return Icons.map;
    } else if (item is SideQuest) {
      return Icons.question_answer;
    } else if (item is ScriptingPhase) {
      return Icons.timeline;
    }
    return Icons.help_outline;
  }

  Widget specialCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            checkColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget setupAllCategorySelections() {
    return IntrinsicHeight(
        child: SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: setupEnemyLevelSelection(),
          ),
          Expanded(
            child: setupCategorySelection(),
          ),
          // if (Platform.isWindows)
          Expanded(
            child: setupEnemyStatsSelection(),
          ),
        ],
      ),
    ));
  }

  Widget setupEnemyLevelSelection() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.only(top: 30, bottom: 5, right: 30, left: 30),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                "Select if you want to change the Enemies Levels.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (level['None'] == false)
                    Text(
                      "Enemy Level: $enemyLevel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  if (level['None'] == false)
                    Slider(
                      activeColor: const Color.fromRGBO(0, 255, 255, 1),
                      value: enemyLevel.toDouble(),
                      min: 1,
                      max: 99,
                      divisions: 98,
                      label: enemyLevel.toString(),
                      onChanged: (double newValue) {
                        setState(() {
                          enemyLevel = newValue.round();
                        });
                      },
                    ),
                ],
              ),
            ),
            ...level.keys.map((levelKey) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CheckboxListTile(
                  title: Text(
                    levelKey,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  value: level[levelKey],
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true ||
                          level.values.every((v) => v == false)) {
                        level.updateAll((key, value) => false);
                        level[levelKey] = newValue!;
                      }
                    });
                  },
                  secondary: Icon(getIconForLevel(levelKey),
                      color: Colors.white, size: 28),
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String getSelectedBossesArgument() {
    List<List<String>> selectedBosses = bossList
        .where((boss) => boss.isSelected)
        .map((boss) => boss.emIdentifiers)
        .toList();
    return selectedBosses.join(',');
  }

  String getSelectedBossesNames() {
    List<String> selectedBosses = bossList
        .where((boss) => boss.isSelected)
        .map((boss) => boss.name)
        .toList();
    return selectedBosses.join(',');
  }

  Widget setupEnemyStatsSelection() {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent[800],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Adjust Boss Stats.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !stats["None"]!
                    ? Text(
                        "Boss Stats: ${enemyStats.toStringAsFixed(1)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.lerp(
                                    const Color.fromARGB(0, 41, 39, 39),
                                    Colors.red,
                                    enemyStats / 5.0)!
                                .withOpacity(0.1),
                            blurRadius: 10.0 + (enemyStats / 5.0) * 10.0,
                            spreadRadius: (enemyStats / 5.0) * 5.0,
                          ),
                        ],
                      ),
                      child: !stats["None"]!
                          ? Slider(
                              activeColor: Color.lerp(
                                  Colors.cyan, Colors.red, enemyStats / 5.0),
                              value: enemyStats,
                              min: 0.0,
                              max: 5.0,
                              divisions: 50,
                              label: enemyStats.toStringAsFixed(1),
                              onChanged: (double newValue) {
                                setState(() {
                                  enemyStats = newValue;
                                });
                              },
                            )
                          : Container()),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 18, 180, 209),
                  title: const Text(
                    "Select All",
                    textScaler: TextScaler.linear(0.8),
                  ),
                  value: stats["Select All"],
                  onChanged: (bool? value) {
                    setState(() {
                      stats["Select All"] = value ?? false;
                      stats["None"] = !value!;
                      for (var boss in bossList) {
                        boss.isSelected = value;
                      }
                      getSelectedBossesArgument();
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  tristate: false,
                  activeColor: const Color.fromARGB(255, 209, 18, 18),
                  title: const Text("None", textScaler: TextScaler.linear(0.8)),
                  value: stats["None"],
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true || !stats["Select All"]!) {
                        stats["None"] = true;
                        for (var boss in bossList) {
                          boss.isSelected = false;
                        }
                        getSelectedBossesArgument();
                      }
                      stats["Select All"] = false;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                const Scrollbar(
                  trackVisibility: true,
                  child: SizedBox(width: 10),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: bossList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var boss = entry.value;
                        final GlobalKey<ShakeAnimationWidgetState> shakeKey =
                            GlobalKey<ShakeAnimationWidgetState>();

                        double scale = boss.isSelected
                            ? 1.0 + 0.5 * (enemyStats / 5.0)
                            : 1.0;

                        return ListTile(
                          leading: GestureDetector(
                            onTap: () => shakeKey.currentState?.shake(),
                            child: Transform.scale(
                              scale: scale,
                              child: ShakeAnimationWidget(
                                key: shakeKey,
                                message: index < messages.length
                                    ? messages[index]
                                    : "",
                                onEnd: () {},
                                child: Image.asset(boss.imageUrl),
                              ),
                            ),
                          ),
                          title: Text(
                            boss.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: boss.isSelected,
                            onChanged: (bool? newValue) {
                              setState(() {
                                boss.isSelected = newValue ?? false;
                                stats["Select All"] =
                                    bossList.every((b) => b.isSelected);
                                stats["None"] =
                                    bossList.every((b) => !b.isSelected);
                              });
                              getSelectedBossesArgument();
                            },
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> loadPathsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    String? input = prefs.getString('input');
    String? specialDatOutputPath = prefs.getString('output');
    String? scriptPath = prefs.getString('scriptPath');
    bool savePaths = prefs.getBool('savePaths') ?? false;
    setState(() {
      this.input = input ?? '';
      this.specialDatOutputPath = specialDatOutputPath ?? '';
      this.scriptPath = scriptPath ?? '';
      this.savePaths = savePaths;
    });

    return input != null || specialDatOutputPath != null || scriptPath != null;
  }

  Future<void> clearPathsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('input');
    await prefs.remove('output');
    await prefs.remove('scriptPath');
    await prefs.setBool('savePaths', false);
  }

  IconData getIconForLevel(String levelEnemy) {
    switch (levelEnemy) {
      case "All Enemies":
        return Icons.emoji_events;
      case "All Enemies without Randomization":
        return Icons.emoji_flags_outlined;
      // case "Only Bosses":
      //   return Icons.emoji_emotions_rounded;
      // case "Only Selected Enemies":
      //   return Icons.radio_button_checked;
      case "None":
        return Icons.not_interested;
      default:
        return Icons.error;
    }
  }

  void onNewLogMessage(BuildContext context, String newMessage) {
    if (newMessage.toLowerCase().contains('error')) {
      log(newMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' $newMessage',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 81, 81),
          ),
        );
      });
    }
  }
}
