// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_ui/appbar/appbar.dart';
import 'package:NAER/naer_ui/nav_button/navigate_button.dart';
import 'package:NAER/naer_ui/other/asciiArt.dart';
import 'package:NAER/naer_ui/setup/category_selection_widget.dart';
import 'package:NAER/naer_ui/setup/directory_selection_widget.dart';
import 'package:NAER/naer_ui/setup/enemy_level_selection_widget.dart';
import 'package:NAER/naer_ui/setup/enemy_stats_selection_widget.dart';
import 'package:NAER/naer_ui/setup/log_output_widget.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/nier_cli/nier_cli.dart';
import 'package:NAER/naer_utils/change_tracker.dart';

import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';
import 'package:stack_trace/stack_trace.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    bool isManagerFile = false;
    await nierCli(arguments, isManagerFile);
    exit(0);
  } else {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LogState()),
          ChangeNotifierProvider(create: (context) => GlobalState()),
        ],
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
  final GlobalKey<LogOutputState> logOutputKey = GlobalKey<LogOutputState>();
  void logAndprint(String message) {
    // prin(message);
    logState.addLog(message);
  }

  late ScrollController scrollController;
  late AnimationController _blinkController;
  late Future<bool> _loadPathsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPathsFuture = loadPathsFromSharedPreferences();
    updateItemsByType(SideQuest, true, context);
    updateItemsByType(MapLocation, true, context);
    updateItemsByType(ScriptingPhase, true, context);
  }

  @override
  void initState() {
    super.initState();
    FileChange.loadChanges();
    FileChange.loadIgnoredFiles().then((_) {}).catchError((error) {});
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
    final globalState = Provider.of<GlobalState>(context);
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
                  scrollToSetup: () =>
                      scrollToSetup(globalState.setupLogOutputKey),
                  setupLogOutputKey: globalState.setupLogOutputKey,
                  button: navigateButton(context, scrollController),
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
            currentIndex: globalState.selectedIndex,
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
                          key: globalState.setupDirectorySelectionKey,
                          child: DirectorySelection(
                            loadPathsFuture: _loadPathsFuture,
                            globalState: globalState,
                          )),
                    ],
                  ),
                ),
                KeyedSubtree(
                  key: globalState.setupCategorySelectionKey,
                  child: setupAllSelections(),
                ),
                KeyedSubtree(
                  key: globalState.setupImageGridKey,
                  child: EnemyImageGrid(key: globalState.enemyImageGridKey),
                ),
                KeyedSubtree(
                  key: globalState.setupLogOutputKey,
                  child: LogOutput(
                    key: logOutputKey,
                  ),
                ),
              ],
            ),
          ),
        ]));
  }

  void scrollToSetup(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context);
    }
  }

  void _onItemTapped(int index) {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    setState(() {
      globalState.selectedIndex = index;
    });

    switch (index) {
      case 0:
        globalState.enemyImageGridKey.currentState?.selectAllImages();
        break;
      case 1:
        globalState.enemyImageGridKey.currentState?.unselectAllImages();
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
    final globalState = Provider.of<GlobalState>(context, listen: false);
    if (!globalState.isLoading) {
      setState(() {
        globalState.isLoading = true;
        globalState.isButtonEnabled = false;
      });

      try {
        await FileChange.savePreRandomizationTime();
        log("Ignored mod files before starting: ${globalState.ignoredModFiles}");
        final stopwatch = Stopwatch()..start();
        await startRandomizing();
        await FileChange.saveChanges();
        stopwatch.stop();

        logOutputKey.currentState?.updateLog(
          'Total randomization time: ${stopwatch.elapsed}',
        );
      } catch (e, stackTrace) {
        logAndPrint('Error during randomization $e');
        logAndPrint('Stack trace: ${Trace.from(stackTrace)}');
      } finally {
        setState(() {
          globalState.isLoading = false;
          globalState.isButtonEnabled = true;
        });
      }
    }
  }

  void onPressedAction() {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    if (globalState.isButtonEnabled) {
      showModifyConfirmation();
    }
  }

// MAIN MODIFY BUTTON FUNCTIONALITY
  Future<void> startRandomizing() async {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    globalState.hasError = true;
    setState(() {
      globalState.isLoading = true;
      globalState.loggedStages.clear();
    });

    if (globalState.input.isEmpty || globalState.specialDatOutputPath.isEmpty) {
      logOutputKey.currentState?.updateLog(
        "Error: Please select both input and output directories. 💋 ",
      );
      return;
    }

    logOutputKey.currentState
        ?.updateLog("Starting randomization process... 🏃‍➡️");

    try {
      CLIArguments cliArgs = await gatherCLIArguments(
        context: context,
        scrollController: scrollController,
        enemyImageGridKey: globalState.enemyImageGridKey,
        categories: globalState.categories,
        level: globalState.level,
        ignoredModFiles: globalState.ignoredModFiles,
        input: globalState.input,
        specialDatOutputPath: globalState.specialDatOutputPath,
        scriptPath: globalState.scriptPath,
        enemyStats: globalState.enemyStats,
        enemyLevel: globalState.enemyLevel,
      );
      bool isManagerFile = false;
      await nierCli(cliArgs.processArgs, isManagerFile);

      logOutputKey.currentState?.updateLog(
        "Randomization process completed successfully.",
      );
    } on Exception catch (e) {
      logOutputKey.currentState?.updateLog("Error occurred: $e");
    } finally {
      setState(() {
        globalState.isLoading = false;
      });
      logOutputKey.currentState?.updateLog(
        'Thank you for using the randomization tool.',
      );
      logOutputKey.currentState?.updateLog(asciiArt2B);
      logOutputKey.currentState?.updateLog("Randomization process finished.");
      showCompletionDialog();
    }
  }

  void logErrorDetails(dynamic e, StackTrace stackTrace) {
    logOutputKey.currentState?.updateLog("Error: $e");
    logOutputKey.currentState?.updateLog("Stack Trace: $stackTrace");
  }

  void undoLastRandomization() async {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    await FileChange.loadChanges();
    await FileChange.undoChanges();

    try {
      for (var filePath in globalState.createdFiles) {
        var file = File(filePath);

        if (await file.exists()) {
          try {
            await file.delete();
            log("Deleted file: $filePath");
          } catch (e) {
            log("Error deleting file $filePath: $e");
            setState(() {
              globalState.logMessages.add("Error deleting file $filePath: $e");
              startBlinkAnimation();
            });
          }
        } else {
          log("File not found: $filePath");
          setState(() {
            globalState.logMessages.add("File not found: $filePath");
            startBlinkAnimation();
          });
        }
      }

      setState(() {
        globalState.logMessages.add("Last randomization undone.");
        setState(() {
          startBlinkAnimation();
          globalState.isLoading = false;
          globalState.isProcessing = false;
        });

        globalState.createdFiles.clear();
      });
    } catch (e) {
      log("An error occurred during undo: $e");
      setState(() {
        globalState.logMessages.add("Error during undo: $e");
        startBlinkAnimation();
        globalState.isLoading = false;
        globalState.isProcessing = false;
      });
    }
  }

  void showUndoConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Undo Everything"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to undo every last modifications you did?",
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
              Text(
                "• This will also undo the installed mod manager files so you need to reinstall them if they got affected.",
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
    final globalState = Provider.of<GlobalState>(context, listen: false);
    List<String> details = [];

    String bossList = getSelectedBossesNames();

    String categoryDetail = globalState.level.entries
        .firstWhere((entry) => entry.value,
            orElse: () => const MapEntry("None", false))
        .key;
    details.add("• Level Modify Category: $categoryDetail");

    if (categoryDetail == 'None') {
      details.add("• Change Level: None");
    } else {
      details.add("• Change Level: ${globalState.enemyLevel}");
    }

    if (bossList.isNotEmpty && globalState.enemyStats != 0.0) {
      details
          .add("• Change Boss Stats: x${globalState.enemyStats} for $bossList");
    } else {
      details.add("• Change Boss Stats: None");
    }

    List<String>? selectedImages =
        globalState.enemyImageGridKey.currentState?.selectedImages;
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

    List<String> selectedCategories = globalState.categories.entries
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

  void showCompletionDialog() {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    setState(() {
      globalState.isLoading = false;
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

  void clearLogMessages() {
    final globalState = Provider.of<GlobalState>(context, listen: false);
    setState(() {
      globalState.logMessages.clear();
    });
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

  Widget setupAllSelections() {
    return const IntrinsicHeight(
        child: SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: EnemyLevelSelection(),
          ),
          Expanded(
            child: CategorySelection(),
          ),
          // if (Platform.isWindows)
          Expanded(
            child: EnemyStatsSelection(),
          ),
        ],
      ),
    ));
  }

  Future<bool> loadPathsFromSharedPreferences() async {
    final globalState = Provider.of<GlobalState>(context);
    final prefs = await SharedPreferences.getInstance();

    String? input = prefs.getString('input');
    String? specialDatOutputPath = prefs.getString('output');
    String? scriptPath = prefs.getString('scriptPath');
    bool savePaths = prefs.getBool('savePaths') ?? false;
    setState(() {
      globalState.input = input ?? '';
      globalState.specialDatOutputPath = specialDatOutputPath ?? '';
      globalState.scriptPath = scriptPath ?? '';
      globalState.savePaths = savePaths;
    });

    return input != null || specialDatOutputPath != null || scriptPath != null;
  }
}
