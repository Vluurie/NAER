import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:NAER/custom_naer_ui/directory_ui/check_pathbox.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart' as p;
import 'package:NAER/naer_pages/second_page.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/nier_enemy_data/sorted_data/nier_sorted_enemies.dart'
    as enemy_data;
import 'package:NAER/nier_enemy_data/boss_data/nier_boss_class_list.dart';
import 'package:NAER/custom_naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/custom_naer_ui/animations/dotted_line_progress_animation.dart';
import 'package:NAER/custom_naer_ui/animations/shacke_animation_widget.dart';
import 'package:NAER/custom_naer_ui/other/shacking_message_list.dart';
import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';

void main() {
  runApp(EnemyRandomizerApp());
}

class EnemyRandomizerApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  EnemyRandomizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  GlobalKey setupButtonsKey = GlobalKey();
  GlobalKey setupImageGridKey = GlobalKey();
  GlobalKey setupCategorySelectionKey = GlobalKey();
  GlobalKey setupLogOutputKey = GlobalKey();
  GlobalKey<EnemyImageGridState> enemyImageGridKey = GlobalKey();
  int _selectedIndex = 0;
  List<String> createdFiles = [];
  bool isLoading = false;
  bool isButtonEnabled = true;
  bool isLogIconBlinking = false;
  bool hasError = false;
  bool isProcessing = false;
  String input = '';
  String scriptPath = '';
  int enemyLevel = 1;
  String escapeSpaces(String path) {
    return path.replaceAll(' ', '\\ ');
  }

  String specialDatOutputPath = '';
  List<String> ignoredModFiles = [];
  List<String> logMessages = [];
  Map<String, bool> categories = {
    "All Quests": true,
    "All Maps": true,
    "All Phases": true,
    'Ignore DLC': true
  };
  Map<String, bool> level = {
    "All Enemies": false,
    "All Enemies without Randomization": false,
    "Only Bosses": false,
    "Only Selected Enemies": false,
    'None': true
  };
  double enemyStats = 0.0;
  Map<String, bool> stats = {"None": true, "Select All": false};
  bool savePaths = false;

  late ScrollController scrollController;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    FileChange.loadChanges();
    FileChange.loadIgnoredFiles();
    loadPathsFromJson();
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
                AppBar(
                  toolbarHeight: 100.0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isLargeScreen = constraints.maxWidth > 600;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // Icon Image
                          Padding(
                            padding: EdgeInsets.only(
                                right: isLargeScreen ? 20.0 : 10.0),
                            child: Image.asset(
                              'assets/naer_icons/icon.png',
                              fit: BoxFit.cover,
                              width: isLargeScreen ? 70.0 : 50.0,
                            ),
                          ),
                          // Text Title
                          Text(
                            'NAER',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 36.0 : 24.0,
                              color: const Color.fromRGBO(0, 255, 255, 1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info, size: 32.0),
                                color: const Color.fromRGBO(49, 217, 240, 1),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Information"),
                                        content: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      "Thank you for using this tool! It is provided free of charge and developed in my personal time. "),
                                              TextSpan(
                                                  text:
                                                      "\n\nIf you encounter any issues or have questions, feel free to ask in the Nier Modding community! "),
                                              TextSpan(
                                                  text:
                                                      ".\n\nSpecial thanks to RaiderB with his NieR CLI and the entire mod community for making this possible."),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text("Close"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              const Text(
                                'Information',
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: AnimatedBuilder(
                                    animation: _blinkController,
                                    builder: (context, child) {
                                      final color = ColorTween(
                                        begin: const Color.fromARGB(
                                            31, 206, 198, 198),
                                        end: const Color.fromARGB(
                                            255, 86, 244, 54),
                                      ).animate(_blinkController).value;

                                      if (_blinkController.status ==
                                          AnimationStatus.forward) {}

                                      return Icon(
                                        Icons.terminal,
                                        size: 32.0,
                                        color: color,
                                      );
                                    },
                                  ),
                                  onPressed: () {
                                    scrollToSetup(setupLogOutputKey);
                                  }),
                              const Text(
                                'Log',
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 100.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                _navigateButton(context),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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

  ElevatedButton _navigateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SecondPage()),
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
        'Go to Second Page',
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
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10, // Horizontal space between items
              runSpacing: 10, // Vertical space between items
              children: [
                DirectorySelectionCard(
                  title: "Input Directory:",
                  path: input,
                  onBrowse: (updatePath) => openInputFileDialog(updatePath),
                  icon: Icons.folder_open,
                  width: 200,
                ),
                DirectorySelectionCard(
                  title: "Output Directory:",
                  path: specialDatOutputPath,
                  onBrowse: (updatePath) => openOutputFileDialog(updatePath),
                  icon: Icons.folder_open,
                  width: 200,
                ),
                DirectorySelectionCard(
                  title: "Select NieR CLI (macOS):",
                  path: scriptPath,
                  onBrowse: (updatePath) => openCliSearch(updatePath),
                  icon: Icons.apple,
                  width: 300,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Open output path'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
                  onPressed: () => getOutputPath(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Open NAER_settings'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
                  onPressed: getNaerSettings,
                ),
                SavePathsWidget(
                  input: input,
                  output: specialDatOutputPath,
                  scriptPath: scriptPath,
                  savePaths: savePaths,
                  onCheckboxChanged: (bool value) {
                    if (!value) {
                      removePathsFile();
                    }
                    setState(() {
                      savePaths = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getOutputPath(BuildContext context) async {
    if (specialDatOutputPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Output path is empty'),
        ),
      );
      return;
    }

    if (Platform.isWindows) {
      // Correctly format the path for Windows command line
      String formattedPath = specialDatOutputPath.replaceAll('/', '\\');
      // Use 'cmd' to execute the 'start' command which opens the folder
      await Process.run('cmd', ['/c', 'start', '', formattedPath]);
    } else if (Platform.isMacOS) {
      // Open the directory in Finder on macOS
      await Process.run('open', [specialDatOutputPath]);
    } else if (Platform.isLinux) {
      // Open the directory in the default file manager on Linux
      await Process.run('xdg-open', [specialDatOutputPath]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Opening output path is not supported on this platform.'),
        ),
      );
    }
  }

  void getNaerSettings() async {
    String settingsDirectoryPath = await FileChange.ensureSettingsDirectory();

    if (Platform.isWindows) {
      // Correctly format the path for Windows command line

      // Use 'cmd' to execute the 'start' command which opens the folder
      await Process.run('cmd', ['/c', 'start', '', settingsDirectoryPath]);
    } else if (Platform.isMacOS) {
      // Open the directory in Finder on macOS
      await Process.run('open', [settingsDirectoryPath]);
    } else if (Platform.isLinux) {
      // Open the directory in the default file manager on Linux
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

  Future<void> openCliSearch(Function(String) updatePath) async {
    String? scriptFile = await getCLIFilePath();

    if (scriptFile != null && scriptFile.isNotEmpty) {
      setState(() {
        scriptPath = scriptFile;
      });
    }

    updatePath(scriptFile ?? '');
  }

  Future<String?> getCLIFilePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String scriptFile = result.files.single.path!;
      print(scriptFile);

      bool isValidCli = await _isValidCliFile(scriptFile);
      if (isValidCli) {
        return scriptFile;
      } else {
        _showInvalidCli();
      }
    }

    return null;
  }

  Future<bool> _isValidCliFile(String scriptPath) async {
    return File(scriptPath).existsSync() && scriptPath.endsWith('nier_cli.exe');
  }

  void _showInvalidCli() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid File"),
          content: const Text(
              "The selected file is not a valid NieR CLI executable."),
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

  Future<void> openInputFileDialog(Function(String) updatePath) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var containsValidFiles = await _containsValidFiles(selectedDirectory);

      if (containsValidFiles) {
        setState(() {
          input = escapeSpaces(selectedDirectory);
        });
        updatePath(selectedDirectory);
      } else {
        // Moved the showDialog inside a separate function
        _showInvalidDirectoryDialog();
        updatePath('');
      }
    } else {
      updatePath('');
    }
  }

  void _showInvalidDirectoryDialog() {
    if (!mounted) return; // Check if the widget is still in the tree

    showDialog(
      context:
          context, // Safe to use context here as it's immediately after the check
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
        specialDatOutputPath = escapeSpaces(selectedDirectory);
      });
      updatePath(selectedDirectory);

      var modFiles = await findModFiles(selectedDirectory);
      if (modFiles.isNotEmpty) {
        showModsMessage(modFiles, (updatedModFiles) {
          setState(() {
            ignoredModFiles = updatedModFiles;
          });
          log("Updated ignoredModFiles after dialog: $ignoredModFiles");
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
        await FileChange
            .savePreRandomizationTime(); // Save pre-randomization time
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

    // Remove file extensions from selected images, if they have any
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

  Future<void> startRandomizing() async {
    hasError = true;
    setState(() {
      isLoading = true;
      loggedStages.clear();
    });
    updateLog("Starting randomization process... 🏃‍➡️", scrollController);

    if (input.isEmpty || specialDatOutputPath.isEmpty) {
      updateLog("Error: Please select both input and output directories. 💋 ",
          scrollController);
      setState(() {
        startBlinkAnimation();
      });
      return;
    }

    String tempFilePath;
    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;

    try {
      if (selectedImages!.isNotEmpty) {
        updateLog("Sorting selected enemies... 💬 ", scrollController);
        var sortedEnemies = await sortSelectedEnemies(selectedImages);
        var tempFile =
            await File('${Directory.systemTemp.path}/temp_sorted_enemies.dart')
                .create();
        var buffer = StringBuffer();
        buffer.writeln("const Map<String, List<String>> sortedEnemyData = {");
        sortedEnemies.forEach((group, enemies) {
          var enemiesFormatted = enemies.map((e) => '"$e"').join(', ');
          buffer.writeln('  "$group": [$enemiesFormatted],');
        });
        buffer.writeln("};");
        await tempFile.writeAsString(buffer.toString());
        tempFilePath = tempFile.path;
        updateLog("Temporary file created: $tempFilePath", scrollController);
      } else {
        tempFilePath = "ALL";
        updateLog(
            "No selected images. Using ALL enemies. 💬 ", scrollController);
      }
    } catch (e) {
      updateLog("Error during file preparation: $e", scrollController);
      return;
    }

    String bossList = getSelectedBossesArgument();
    List<String> createdDatFiles = [];

    if (scriptPath.isEmpty) {
      print("path $scriptPath");
      updateLog("Error: Please select the Nier CLI. 💩 ", scrollController);
      setState(() {
        startBlinkAnimation();
      });
      return;
    }

    scriptPath = escapeSpaces(scriptPath);

// Construct the process arguments

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

    if (ignoredModFiles.isNotEmpty) {
      String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
      processArgs.add(ignoreArgs);
      log("Ignore arguments added: $ignoreArgs");
    }

    print("Final process arguments: $processArgs");

    updateLog("Process arguments: ${processArgs.join(' ')}", scrollController);

    try {
      updateLog("Starting nier_cli...", scrollController);
      // Ensure the scriptPath is not empty and exists
      if (scriptPath.isEmpty || !File(scriptPath).existsSync()) {
        updateLog("Error: NieR CLI path is invalid or not specified.",
            scrollController);
        return;
      }

      updateLog("Starting nier_cli...", scrollController);
      updateLog("Executing command: $scriptPath ${processArgs.join(' ')}",
          scrollController);

      // Start the process
      Process process = await Process.start(scriptPath, processArgs,
          mode: ProcessStartMode.detachedWithStdio);

      process.stdout.transform(utf8.decoder).listen((data) {
        // Split the data by new lines and process each line separately
        var lines = data.split('\n');
        for (var line in lines) {
          updateLog(line.trim(), scrollController);

          // Check if the line contains 'Folder created:'
          if (line.contains("Folder created:")) {
            // Split the line and get the part after 'Folder created:'
            var parts = line.split("Folder created:");
            if (parts.length >= 2) {
              var fullPath = parts[1].trim(); // Extract the path
              log("Debug - Extracted path: $fullPath");

              if (fullPath.endsWith('.dat')) {
                setState(() {
                  createdFiles.add(fullPath);
                  FileChange.logChange(fullPath, 'create');
                  log("Debug - Added to createdFiles: $fullPath");
                });
              }
            }
          }
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        updateLog("stderr: $data", scrollController);
      });

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        updateLog(
            "Randomization process completed successfully with exit code $exitCode",
            scrollController);
        setState(() {
          createdFiles
              .addAll(createdDatFiles); // Update state with tracked .dat files
        });
      } else {
        updateLog(
            "Randomization process ended with error. Exit code: $exitCode",
            scrollController);
      }
    } catch (e) {
      updateLog("Error during process execution: $e", scrollController);
    } finally {
      setState(() {
        isLoading = false;
      });
      loggedStages.clear();
      updateLog(
          'Thank you for using the randomization tool.', scrollController);
      updateLog("Randomization process finished.", scrollController);
      showCompletionDialog();
    }
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
            var fileName =
                path.basename(entity.path); // Extract only the file name
            log("Found .dat file: ${entity.path}, last modified: $fileModTime");
            if (fileModTime.isBefore(preRandomizationTime)) {
              modFiles.add(fileName); // Add only the file name
              log("Adding mod file: $fileName");
            }
          }
        }
      } else {
        log("Directory does not exist: $outputDirectory");
      }
    } catch (e) {
      log('Error while finding mod files: $e');
    }
    FileChange.ignoredFiles.clear();
    FileChange.ignoredFiles.addAll(modFiles);
    await FileChange.saveIgnoredFiles();
    log("Mod files found: $modFiles");
    return modFiles;
  }

  Future<Map<String, List<String>>> readEnemyData() async {
    return enemy_data.enemyData;
  }

  void undoLastRandomization() async {
    await FileChange
        .loadChanges(); // Load the changes if they were saved previously
    await FileChange.undoChanges(); // Undo the changes

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
                "• Once the tool is closed, you cannot undo the last randomization.",
                style: TextStyle(fontSize: 12),
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

    // Category details
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

    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;
    if (selectedImages != null && selectedImages.isNotEmpty) {
      details.add("• Selected Enemies: ${selectedImages.join(', ')}");
    } else {
      details.add(
          "• Selected Enemies: No Enemy selected, will use ALL Enemies for Randomization");
    }

    // Explaining what each category means
    switch (categoryDetail) {
      case "All Enemies":
        details.add(
            "• Level Change: Every randomized enemy & bosses in the game will be included.");
        break;
      case "Only Bosses":
        details.add("• Level Change: Only boss-type enemies will be included.");
        break;
      case "Only Selected Enemies":
        details.add(
            "• Level Change: Only randomized selected enemies will be included.");

        break;
      case "None":
        details.add(
            "• Level Change: No specific category selected. No level will be modified");
        break;
      default:
        details.add("• Default settings will be used.");
        break;
    }

    // Categories details
    List<String> selectedCategories = categories.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    if (selectedCategories.isNotEmpty) {
      details.add("• Selected Categories: ${selectedCategories.join(', ')}");
    } else {
      details.add("• No specific categories selected.");
    }

    return details.join('\n\n');
  }

  Widget setupLogOutput(List<String> logMessages, BuildContext context,
      VoidCallback clearLogMessages, ScrollController scrollController) {
    // Function to determine text color based on message type
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
        return Colors.white; // Color for informational messages
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

    // Function to determine if the last message is still being processed

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
                                    text: "Hey there! It's quiet for now... 🤫")
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
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 71, 192, 240)),
                ),
                onPressed: clearLogMessages,
                child: const Text('Clear Log'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.apple), // Apple icon
                label: const Text('Copy CLI Argument (macOS)'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 71, 192, 240)),
                ),
                onPressed:
                    copyCLIArguments, // Function to be called on button press
              ),
            ),
          ],
        )
      ],
    );
  }

  void copyCLIArguments() async {
    if (input.isEmpty || specialDatOutputPath.isEmpty) {
      updateLog("Error: Please select both input and output directories. 💋 ",
          scrollController);
      return;
    }

    if (scriptPath.isEmpty) {
      updateLog("Error: Please select the Nier CLI. 💩 ", scrollController);
      setState(() {
        startBlinkAnimation();
      });
      return;
    }

    String tempFilePath;
    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;

    try {
      if (selectedImages!.isNotEmpty) {
        updateLog("Sorting selected enemies... 💬 ", scrollController);
        var sortedEnemies = await sortSelectedEnemies(selectedImages);
        var tempFile =
            await File('${Directory.systemTemp.path}/temp_sorted_enemies.dart')
                .create();
        var buffer = StringBuffer();
        buffer.writeln("const Map<String, List<String>> sortedEnemyData = {");
        sortedEnemies.forEach((group, enemies) {
          var enemiesFormatted = enemies.map((e) => '"$e"').join(', ');
          buffer.writeln('  "$group": [$enemiesFormatted],');
        });
        buffer.writeln("};");
        await tempFile.writeAsString(buffer.toString());
        tempFilePath = tempFile.path;
      } else {
        tempFilePath = "ALL";
      }
    } catch (e) {
      return;
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

    if (ignoredModFiles.isNotEmpty) {
      String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
      processArgs.add(ignoreArgs);
      log("Ignore arguments added: $ignoreArgs");
    }

    scriptPath = escapeSpaces(scriptPath);

    updateLog("NieR CLI Arguments: ${processArgs.join(' ')}", scrollController);

    String command = "sudo $scriptPath ${processArgs.join(' ')}";

    // Copy the command to clipboard
    Clipboard.setData(ClipboardData(text: command)).then(
      (result) {
        const snackBar = SnackBar(content: Text('Command copied to clipboard'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    ).catchError((e) {
      print('Error copying to clipboard: $e');
    });
    setState(() {
      isLoading = false;
    });
  }

  Set<String> loggedStages = {};

  void updateLog(String log, ScrollController scrollController) async {
    if (log.trim().isEmpty) {
      return;
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

    setState(() {
      isProcessing = true;
    });

    setState(() {
      String? stageIdentifier;

      startBlinkAnimation();

      if (log.startsWith("Repacking DAT file")) {
        stageIdentifier = 'repacking_dat';
      } else if (log.contains("Converting YAX to XML")) {
        stageIdentifier = 'converting_yax_to_xml';
      } else if (log.contains("Converting XML to YAX")) {
        stageIdentifier = 'converting_xml_to_yax';
      } else if (log.startsWith("Extracting CPK")) {
        stageIdentifier = 'extracting_cpk';
      } else if (log.contains('Processing entity:')) {
        stageIdentifier = 'processing_entity';
      } else if (log.contains('Replaced objId')) {
        stageIdentifier = 'replacing_objid';
      } else if (log.contains("Randomizing complete")) {
        stageIdentifier = 'randomizing_complete';
      } else if (log.contains("Decompressing")) {
        stageIdentifier = 'decompressing';
      } else if (log.contains("Skipping")) {
        stageIdentifier = 'skipping';
      } else if (log.contains("Object ID")) {
        stageIdentifier = 'id';
      } else if (log.contains("Folder created")) {
        stageIdentifier = 'folder';
      } else if (log.contains("Export path")) {
        stageIdentifier = 'export';
      } else if (log.contains("Deleted")) {
        stageIdentifier = 'deleted';
      } else if (log.contains("Reading")) {
        stageIdentifier = 'read';
      } else if (log.contains("r5a5.dat")) {
        stageIdentifier = 'write';
      } else if (log.contains("Bad state")) {
        stageIdentifier = 'skip';
      } else {
        logMessages.add(log);
      }

      if (stageIdentifier != null) {
        if (!loggedStages.contains(stageIdentifier)) {
          // Start animation when a new stage begins

          // Customizing the message for better readability
          switch (stageIdentifier) {
            case 'repacking_dat':
              log = "Repacking DAT files initiated.";
              break;
            case 'converting_yax_to_xml':
              log = "Conversion from YAX to XML in progress...";
              break;
            case 'converting_xml_to_yax':
              log = "Conversion from XML to YAX in progress...";
              break;
            case 'extracting_cpk':
              log = "CPK Extraction started.";
              break;
            case 'processing_entity':
              log = "Searching and replacing Enemies...";
              break;
            case 'replacing_objid':
              log = "Replaced Enemies.";
              break;
            case 'randomizing_complete':
              log = "Randomizing process completed.";
              break;
            case 'decompressing':
              log = "Decompressing DAT files in progress.";
              break;
            case 'skipping':
              log = "Skipping unnecessary DAT files.";
              break;
            case 'id':
              log = "Replacing Enemies in process.";
              break;
            case 'folder':
              log = "Processing files.. copy to output path.";
              break;
            case 'export':
              log = "Exporting dat files to output directory started.";
              break;
            case 'deleted':
              log = "Deleting extracted CPK files in output directory...";
              break;
            case 'read':
              log = "Reading extracted files in process.";
              break;
            case 'write':
              log = "Im the issue that can be ignored.";
              break;
            case 'skip':
              log = "I had an issue, but this issue is not an issue. ";
              break;
          }

          logMessages.add(log);
          startBlinkAnimation();
          loggedStages.add(stageIdentifier);
        }
      }
    });

    setState(() {
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
                onPressed: () {
                  if (index != null) {
                    modFiles.removeAt(index); // Remove a single file
                  } else {
                    modFiles.clear(); // Remove all files
                  }
                  onModFilesUpdated(modFiles);
                  Navigator.of(context).pop();
                  if (modFiles.isNotEmpty) {
                    Navigator.of(context).pop();
                    showModsMessage(modFiles,
                        onModFilesUpdated); // Reopen with updated list
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

    // Only show the mods message dialog if there are mod files
    if (modFiles.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Mod Files Detected"),
            content: SizedBox(
              width: double.maxFinite,
              child: modFiles.isNotEmpty
                  ? Scrollbar(
                      thumbVisibility: true,
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: modFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 2.0,
                            child: ListTile(
                              leading: const Icon(Icons.extension),
                              title: Text(
                                modFiles[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  const Text('Ignored during randomization'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => showRemoveConfirmation(index),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Text('No mod files found'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Remove All"),
                onPressed: () => showRemoveConfirmation(
                    null), // Null indicates removal of all
              ),
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  onModFilesUpdated(modFiles);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void clearLogMessages() {
    setState(() {
      logMessages.clear(); // Clear the log messages
    });
  }

  Widget setupCategorySelection() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
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
                "Select Categories for Randomization (at least one must be selected)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ...categories.keys.map((category) {
              IconData icon = getIconForCategory(category);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  leading: Icon(icon, color: Colors.white, size: 28),
                  title: Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: categories[category],
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true ||
                              categories.values.where((v) => v).length > 1) {
                            categories[category] = newValue!;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'At least one category must be selected.'),
                                backgroundColor:
                                    Color.fromARGB(255, 255, 255, 255),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget setupAllCategorySelections() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: setupEnemyLevelSelection(),
          ),
          Expanded(
            child: setupCategorySelection(),
          ),
          Expanded(
            child: setupEnemyStatsSelection(),
          ),
        ],
      ),
    );
  }

  Widget setupEnemyLevelSelection() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
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
                  Text(
                    "Enemy Level: $enemyLevel",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
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
    print("Selected Bosses $selectedBosses");
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
              "Adjust Boss Stats.(Still experimental)",
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
                Text(
                  "Boss Stats: ${enemyStats.toStringAsFixed(1)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(const Color.fromARGB(0, 41, 39, 39),
                                  Colors.red, enemyStats / 5.0)!
                              .withOpacity(
                                  0.1), // Dynamic glow color with some transparency
                          blurRadius: 10.0 +
                              (enemyStats / 5.0) *
                                  10.0, // Increasing blur radius based on the slider value
                          spreadRadius: (enemyStats / 5.0) *
                              5.0, // Spread radius starts from 0 and increases as the value approaches 5
                        ),
                      ],
                    ),
                    child: Slider(
                      activeColor:
                          Color.lerp(Colors.cyan, Colors.red, enemyStats / 5.0),
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
                    ),
                  ),
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
                  title: const Text("Select All"),
                  value: stats["Select All"],
                  onChanged: (bool? value) {
                    setState(() {
                      stats["Select All"] = value ?? false;
                      stats["None"] =
                          !value!; // Set "None" to opposite of "Select All"
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
                  title: const Text("None"),
                  value: stats["None"],
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true || !stats["Select All"]!) {
                        stats["None"] =
                            true; // Keep "None" true if "Select All" is not selected
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
            height: 320, // Set a fixed height
            child: Row(
              children: [
                const Scrollbar(
                  trackVisibility: true,
                  child: SizedBox(width: 10), // Minimal width to show scrollbar
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

                        // Calculate scale factor based on enemyStats and selection status
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
                            boss.name, // Display boss name here
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: boss.isSelected,
                            onChanged: (bool? newValue) {
                              setState(() {
                                boss.isSelected = newValue ?? false;
                                // Update "Select All" and "None" based on current selections
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

  Future<void> loadPathsFromJson() async {
    String directoryPath = await FileChange.ensureSettingsDirectory();
    File settingsFile = File(p.join(directoryPath, 'paths.json'));

    if (await settingsFile.exists()) {
      String contents = await settingsFile.readAsString();
      Map<String, dynamic> paths = jsonDecode(contents);
      setState(() {
        input = paths['input'] ?? '';
        specialDatOutputPath = paths['output'] ?? '';
        scriptPath = paths['scriptPath'] ?? '';

        // Set savePaths to true if the paths.json file exists and paths are not empty
        savePaths = input.isNotEmpty ||
            specialDatOutputPath.isNotEmpty ||
            scriptPath.isNotEmpty;
      });
    }
  }

  // In your main widget class
  Future<void> removePathsFile() async {
    String directoryPath = await FileChange.ensureSettingsDirectory();
    File settingsFile = File(p.join(directoryPath, 'paths.json'));

    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }

    setState(() {
      input = '';
      specialDatOutputPath = '';
      scriptPath = '';
      savePaths = false;
    });
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case "All Quests":
        return Icons.announcement_rounded;
      case "All Maps":
        return Icons.map;
      case "All Phases":
        return Icons.loop;
      case "Ignore DLC":
        return Icons.image_not_supported_rounded;
      default:
        return Icons.error;
    }
  }
}

IconData getIconForLevel(String levelEnemy) {
  switch (levelEnemy) {
    case "All Enemies":
      return Icons.emoji_events;
    case "All Enemies without Randomization":
      return Icons.emoji_flags_outlined;
    case "Only Bosses":
      return Icons.emoji_emotions_rounded;
    case "Only Selected Enemies":
      return Icons.radio_button_checked;
    case "None":
      return Icons.not_interested;
    default:
      return Icons.error;
  }
}

void onNewLogMessage(BuildContext context, String newMessage) {
  if (newMessage.toLowerCase().contains('error')) {
    log(newMessage); // Writing the error to the log file

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
