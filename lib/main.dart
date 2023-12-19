import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NAER/customUI/DirectorySelectionCard.dart';
import 'package:NAER/customUI/DottedLineProgressAnimation.dart';
import 'package:NAER/customUI/customErrorScreen.dart';
import 'package:NAER/naerServices/enemyImageGrid.dart';
import 'package:NAER/secondPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'enemyData/sorted_enemy.dart' as enemy_data;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomErrorScreen(errorDetails: errorDetails);
  };
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
      home: EnemyRandomizerAppState(), // Reference the StatefulWidget here
    );
  }
}

class EnemyRandomizerAppState extends StatefulWidget {
  @override
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
  final List<String> selectedImages = [];
  bool isLoading = false;
  bool isButtonEnabled = true;
  bool isLogIconBlinking = false;
  bool hasError = false;
  bool isProcessing = false;
  String input = '';
  int enemyLevel = 1;
  String specialDatOutputPath = '';
  List<String> ignoredModFiles = [];
  List<String> logMessages = []; // List to store log messages
  Map<String, bool> categories = {
    "All Quests": true,
    "All Maps": true,
    "All Phases": true,
    'Ignore DLC': true
  };
  Map<String, bool> level = {
    "All Enemies": false,
    "Only Bosses": false,
    "Only Selected Enemies": false,
    'None': true
  };

  late ScrollController scrollController;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 1000),
    );

    // Initialize the check icon animation

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
    log('dispose called'); // Debugging statement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0), // Height of the AppBar.
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 28, 31, 32), // Dark purple
                  Color.fromARGB(255, 45, 45, 48), // Light purple
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16), // Rounded corner radius
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: 110,
                    width: 70,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Color.fromARGB(0, 117, 100,
                            100), // Adjust the opacity to control darkness
                        BlendMode.srcOver, // Use darken blend mode
                      ),
                      child: Image.asset(
                        'assets/1234.png', // Replace with your image asset path
                        fit: BoxFit
                            .cover, // This ensures the image covers the whole screen
                      ),
                    )),
                AppBar(
                  toolbarHeight: 100.0, // Adjusted AppBar height
                  title: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: const Text('NAER'),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: <Widget>[
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'NAER',
                          style: TextStyle(
                              fontSize: 36.0,
                              color: Color.fromRGBO(0, 255, 255, 1),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),

                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info, size: 32.0),
                          color: Color.fromRGBO(
                              49, 217, 240, 1), // Normal information icon
                          onPressed: () {
                            // Display a message when the button is pressed
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Information"),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255)),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                "Thank you for using this tool! It is provided free of charge and developed in my personal time. "),
                                        TextSpan(
                                            text:
                                                "\n\nIf you encounter any issues or have questions, feel free to ask in the "),
                                        TextSpan(
                                          text: "NieR Modding Community",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              Uri url = Uri.parse(
                                                  'https://discord.gg/VaK99wH3sg');
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Could not launch the URL'),
                                                  ),
                                                );
                                              }
                                            },
                                        ),
                                        TextSpan(
                                            text:
                                                ".\n\nSpecial thanks to RaiderB with his NieR CLI and the entire mod community for making this possible."),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("Close"),
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
                        Text(
                          'Information',
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: AnimatedBuilder(
                              animation: _blinkController,
                              builder: (context, child) {
                                final color = ColorTween(
                                  begin: Color.fromARGB(31, 206, 198,
                                      198), // Change this to the initial color of the icon
                                  end: Color.fromARGB(255, 86, 244,
                                      54), // Change this to the desired color during blinking
                                ).animate(_blinkController).value;

                                // Print a message when the blinking animation is triggered
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
                        Text(
                          'Log',
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                          right: 100.0), // Adjust padding as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          _navigateButton(context),
                        ],
                      ),
                    ), // Add Spacer to push icons to the center
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 28, 31, 32), // Same as AppBar start color
                Color.fromARGB(255, 45, 45, 48), // Same as AppBar end color
              ],
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5),
              topLeft: Radius.circular(5),
            ),
          ),
          child: BottomNavigationBar(
            items: [
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
            backgroundColor:
                Colors.transparent, // Set it transparent to show gradient
            type: BottomNavigationBarType.fixed, // Avoid shifting items
            elevation: 0, // Remove shadow
          ),
        ),
        body: Stack(children: [
          Positioned.fill(
              child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Color.fromARGB(255, 24, 23, 23)
                  .withOpacity(0.9), // Adjust the opacity to control darkness
              BlendMode.srcOver, // Use darken blend mode
            ),
            child: Image.asset(
              'assets/NaerIcon.png', // Replace with your image asset path
              fit: BoxFit
                  .cover, // This ensures the image covers the whole screen
            ),
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
                  child: setupBothCategorySelections(),
                ),
                // Wrap each setup widget with KeyedSubtree and provide a key
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
          MaterialPageRoute(builder: (context) => SecondPage()),
        );
      },
      child: Text(
        'Go to Second Page',
        style: TextStyle(
          fontSize: 16.0,
          color: Color.fromRGBO(0, 255, 255, 1), // Cyan color for text
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromARGB(255, 45, 45, 48),
        backgroundColor: Color.fromARGB(255, 28, 31, 32), // Light purple
        elevation: 10, // This adds the shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor:
            Colors.black.withOpacity(0.5), // Shadow color with some opacity
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

      // Example conditions
      bool isProcessing = lastMessage.isNotEmpty &&
          !lastMessage.contains("Completed") &&
          !lastMessage.contains("Error") &&
          !lastMessage.contains("Randomization") &&
          !lastMessage.contains("Last");

      // Additional logic can be added here as needed

      return isProcessing;
    }

    return false;
  }

  Widget setupDirectorySelection() {
    return Align(
      alignment: Alignment.topLeft, // Align to the right
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        constraints: BoxConstraints(
            maxWidth: 600), // Constrain the width of the whole setup
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Align children to the right
          children: [
            DirectorySelectionCard(
              title: "Input Directory:",
              path: input,
              onBrowse: (updatePath) => openInputFileDialog(updatePath),
              icon: Icons.folder_open,
              width: 250, // Set fixed width of the cards
            ),
            const SizedBox(width: 10), // Space between the two cards
            DirectorySelectionCard(
              title: "Output Directory:",
              path: specialDatOutputPath,
              onBrowse: (updatePath) => openOutputFileDialog(updatePath),
              icon: Icons.folder_open,
              width: 250, // Set fixed width of the cards
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openInputFileDialog(Function(String) updatePath) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var containsValidFiles = await _containsValidFiles(selectedDirectory);

      if (containsValidFiles) {
        setState(() {
          input = selectedDirectory;
        });
        updatePath(selectedDirectory); // Update with the selected directory
      } else {
        // Show error dialog
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
        updatePath(''); // Do not update the path as the directory is invalid
      }
    } else {
      updatePath(''); // No directory selected
    }
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
      // Always update the state and the path with the selected directory
      setState(() {
        specialDatOutputPath = selectedDirectory;
      });
      updatePath(selectedDirectory);

      var modFiles = await findModFiles(selectedDirectory);
      if (modFiles.isNotEmpty) {
        // If mod files are found, show mods message
        showModsMessage(modFiles, (updatedModFiles) {
          setState(() {
            ignoredModFiles = updatedModFiles; // Update the ignored mod files
          });
          print("Updated ignoredModFiles after dialog: $ignoredModFiles");
        });
      } else {
        // Show a dialog if no mod files are found, but keep the path updated
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("No Mod Files"),
              content: const Text(
                  "No mod files were found in the selected directory."),
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
    } else {
      // No directory selected, reset the path
      updatePath('');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Invoke your methods based on the index:
    switch (index) {
      case 0:
        enemyImageGridKey.currentState?.unselectAllImages();
        break;
      case 1:
        showUndoConfirmation();
        break;
      case 2:
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
        await savePreRandomizationTime(); // Save pre-randomization time
        print("Ignored mod files before starting: $ignoredModFiles");
        await startRandomizing();
        await saveLastRandomizationTime(); // Save last randomization time
      } catch (e) {
        // Handle any exceptions here
        print("Error during randomization: $e");
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

  Future<void> savePreRandomizationTime() async {
    var bufferTime = Duration(minutes: 60); // Adjust buffer time as needed
    var preRandomizationTime = DateTime.now().subtract(bufferTime);
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(preRandomizationTime);

    var preRandomizationData =
        jsonEncode({'pre_randomization_time': formattedTime});
    var file = File('pre_randomization_time.json');
    await file.writeAsString(preRandomizationData);
    print("Pre-randomization time saved: $formattedTime");
  }

  Future<void> saveLastRandomizationTime() async {
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);

    var lastRandomizationData =
        jsonEncode({'last_randomization_time': formattedTime});
    var file = File('last_randomization_time.json');
    await file.writeAsString(lastRandomizationData);
  }

  Future<Map<String, List<String>>> sortSelectedEnemies(
      List<String> selectedImages) async {
    var enemyGroups = await readEnemyData();

    // Remove file extensions from selected images, if they have any
    var formattedSelectedImages =
        selectedImages.map((image) => image.split('.').first).toList();

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
      if (!found) {
        // Optionally handle unmatched enemies here
      }
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
    try {
      if (selectedImages.isNotEmpty) {
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

// Construct the process arguments
    List<String> processArgs = [
      input,
      '--output',
      specialDatOutputPath,
      tempFilePath,
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

    if (level["None"] == true) {
      processArgs.add("--category=default");
    }

    if (ignoredModFiles.isNotEmpty) {
      String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
      processArgs.add(ignoreArgs);
      print("Ignore arguments added: $ignoreArgs");
    }

    print("Final process arguments: $processArgs");

    updateLog("Process arguments: ${processArgs.join(' ')}", scrollController);

    var currentDir = Directory.current.path;
    var scriptPath = p.join(currentDir, 'bin/nier_cli.exe');

    List<String> createdDatFiles = []; // To track created .dat files

    try {
      updateLog("Starting nier_cli.exe...", scrollController);
      final process = await Process.start(
          scriptPath, processArgs); // Directly call the .exe with arguments

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
              print("Debug - Extracted path: $fullPath");

              if (fullPath.endsWith('.dat')) {
                setState(() {
                  createdFiles.add(fullPath);
                  print("Debug - Added to createdFiles: $fullPath");
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
    DateTime preRandomizationTime = await _getPreRandomizationTime();

    print("Pre-randomization time: $preRandomizationTime");

    try {
      var directory = Directory(outputDirectory);
      if (await directory.exists()) {
        print("Scanning directory: $outputDirectory");
        await for (FileSystemEntity entity in directory.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dat')) {
            var fileModTime = await entity.lastModified();
            var fileName =
                path.basename(entity.path); // Extract only the file name
            print(
                "Found .dat file: ${entity.path}, last modified: $fileModTime");
            if (fileModTime.isBefore(preRandomizationTime)) {
              modFiles.add(fileName); // Add only the file name
              print("Adding mod file: $fileName");
            }
          }
        }
      } else {
        print("Directory does not exist: $outputDirectory");
      }
    } catch (e) {
      print('Error while finding mod files: $e');
    }

    print("Mod files found: $modFiles");
    return modFiles;
  }

  Future<DateTime> _getPreRandomizationTime() async {
    var preRandomizationFile = File('pre_randomization_time.json');
    try {
      if (await preRandomizationFile.exists()) {
        var content = await preRandomizationFile.readAsString();
        var preRandomizationData = jsonDecode(content);
        DateTime parsedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
            .parse(preRandomizationData['pre_randomization_time']);
        print("Loaded pre-randomization time from file: $parsedTime");
        return parsedTime;
      } else {
        print("Pre-randomization time file does not exist.");
      }
    } catch (e) {
      print('Error reading pre-randomization time: $e');
    }
    print("Using current time as fallback for pre-randomization time.");
    return DateTime.now();
  }

  Future<Map<String, List<String>>> readEnemyData() async {
    return enemy_data.enemyData;
  }

  void undoLastRandomization() async {
    print("Files to be deleted: $createdFiles");

    if (createdFiles.isEmpty) {
      setState(() {
        hasError = true;
        logMessages.add("Error: No randomization to undo.");
        startBlinkAnimation();
      });
      onNewLogMessage(context, "Error: No randomization to undo.");
      return;
    }

    try {
      for (var filePath in createdFiles) {
        var file = File(filePath);

        if (await file.exists()) {
          try {
            await file.delete();
            print("Deleted file: $filePath");
          } catch (e) {
            print("Error deleting file $filePath: $e");
            setState(() {
              logMessages.add("Error deleting file $filePath: $e");
              startBlinkAnimation();
            });
          }
        } else {
          print("File not found: $filePath");
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
      print("An error occurred during undo: $e");
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Are you sure you want to undo the last randomization?",
              ),
              SizedBox(height: 10),
              const Text(
                "Important:",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const Text(
                "• Once the tool is closed, you cannot undo the last randomization.",
                style: TextStyle(fontSize: 12),
              ),
              const Text(
                "• Avoid using this function while the game is running as it may cause issues.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without doing anything
              },
            ),
            TextButton(
              child: const Text("Yes, Undo"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                undoLastRandomization(); // Proceed with undo
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
                SizedBox(height: 10),
                Text(modificationDetails),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("No, I still have work to do."),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without doing anything
              },
            ),
            TextButton(
              child: const Text("Yes, Modify"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                handleStartRandomizing(); // Proceed with modification
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
            orElse: () => MapEntry("None", false))
        .key;
    details.add("• Level Modify Category: $categoryDetail");

    if (categoryDetail == 'None') {
      details.add("• Change Level: None");
    } else {
      details.add("• Change Level: $enemyLevel");
    }

    List<String>? selectedImages =
        enemyImageGridKey.currentState?.selectedImages;
    if (selectedImages != null && selectedImages.isNotEmpty)
      details.add("• Selected Enemies: ${selectedImages.join(', ')}");
    else {
      details.add(
          "• Selected Enemies: No Enemy selected, will use ALL Enemies for Randomization");
    }

    // Explain what each category means
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
    Color _messageColor(String message) {
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
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // Function to determine if the last message is still being processed

    List<InlineSpan> _buildLogMessageSpans() {
      return logMessages.map((message) {
        String logIcon;
        if (message.toLowerCase().contains('error') ||
            message.toLowerCase().contains('failed')) {
          logIcon = '💥 ';
        } else if (message.toLowerCase().contains('warning')) {
          logIcon = '⚠️ ';
        } else {
          logIcon = 'ℹ️ '; // Icon for informational messages
        }

        return TextSpan(
          text: '$logIcon$message\n',
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            color: _messageColor(message),
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
              color: Color.fromARGB(255, 31, 29, 29),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 50,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: Radius.circular(5.0),
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: logMessages.isNotEmpty
                            ? _buildLogMessageSpans()
                            : [
                                TextSpan(
                                    text: "Hey there! It's quiet for now... 🤫")
                              ],
                      ),
                    ),
                    if (isLastMessageProcessing())
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 100.0),
                        child: DottedLineProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(
                        255, 25, 25, 26)), // Change the background color
                foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 71, 192, 240)), // Change the text color
              ),
              onPressed: clearLogMessages,
              child: Text('Clear Log'),
            ),
          ),
        ),
      ],
    );
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
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    var delay = const Duration(seconds: 1);

    setState(() {
      isProcessing = true;
    });

    await Future.delayed(delay, () {
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

            // Customize the message for better readability
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
                // Additional actions on completion, if necessary
              },
            ),
          ],
        );
      },
    );
  }

  void showModsMessage(
      List<String> modFiles, Function(List<String>) onModFilesUpdated) {
    ScrollController _scrollController = ScrollController();

    void _showRemoveConfirmation(int? index) {
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
                  Navigator.of(context).pop(); // Close the confirmation dialog
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
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  if (modFiles.isNotEmpty) {
                    Navigator.of(context)
                        .pop(); // Close the mods message dialog
                    showModsMessage(modFiles,
                        onModFilesUpdated); // Reopen with updated list
                  } else {
                    Navigator.of(context)
                        .pop(); // Close the mods message dialog
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
            content: Container(
              width: double.maxFinite,
              child: modFiles.isNotEmpty
                  ? Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: modFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 2.0,
                            child: ListTile(
                              leading: Icon(Icons.extension),
                              title: Text(
                                modFiles[index],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Ignored during randomization'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline),
                                onPressed: () => _showRemoveConfirmation(index),
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
                onPressed: () => _showRemoveConfirmation(
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
              IconData icon = getIconForCategory(
                  category); // Assuming this function returns an icon based on the category
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
                              SnackBar(
                                content: Text(
                                    'At least one category must be selected.'),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                              ),
                            );
                          }
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget setupBothCategorySelections() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Space out children equally
      children: [
        Expanded(
          flex: 1, // Takes 50% of horizontal space
          child: setupEnemyLevelSelection(),
        ),
        Expanded(
          flex: 1, // Takes 50% of horizontal space
          child: setupCategorySelection(),
        ),
      ],
    );
  }

  Widget setupEnemyLevelSelection() {
    return Align(
      alignment: Alignment.topLeft,
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
                    activeColor: Color.fromRGBO(0, 255, 255, 1),
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
            }).toList(),
          ],
        ),
      ),
    );
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
        return Icons.error; // Return a valid default icon
    }
  }
}

IconData getIconForLevel(String levelEnemy) {
  switch (levelEnemy) {
    case "All Enemies":
      return Icons.emoji_events;
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
    writeLog(newMessage); // Write the error to the log file

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ' $newMessage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 255, 81, 81),
        ),
      );
    });
  }
}

Future<void> writeLog(String message) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/log.txt');
  await file.writeAsString('$message\n', mode: FileMode.append);
}

Future<void> logMessage(String message) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/log.txt');
  final timestamp = DateTime.now().toString();
  final logEntry = '[$timestamp] $message\n';

  await file.writeAsString(logEntry, mode: FileMode.append);
  print(logEntry); // Also print to console for debugging
}