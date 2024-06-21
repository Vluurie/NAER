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
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/nier_cli/nier_cli.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';
import 'package:stack_trace/stack_trace.dart';

void main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    bool isManagerFile = false;
    await nierCli(arguments, isManagerFile);
    exit(0);
  } else {
    final themeNotifier = await AutomatoThemeNotifier.loadFromPreferences();

    runApp(
      riverpod.ProviderScope(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GlobalState()),
            ChangeNotifierProvider(create: (_) => themeNotifier),
            ChangeNotifierProvider(create: (_) => LogState()),
          ],
          child: const EnemyRandomizerApp(),
        ),
      ),
    );
  }
}

class EnemyRandomizerApp extends StatelessWidget {
  const EnemyRandomizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NieR:Automata Enemy Randomizer Tool',
      theme: Provider.of<AutomatoThemeNotifier>(context).currentTheme,
      home: const EnemyRandomizerAppState(),
    );
  }
}

class EnemyRandomizerAppState extends StatefulWidget {
  const EnemyRandomizerAppState({super.key});

  @override
  _EnemyRandomizerAppState createState() => _EnemyRandomizerAppState();
}

class _EnemyRandomizerAppState extends State<EnemyRandomizerAppState>
    with TickerProviderStateMixin {
  final GlobalKey<LogOutputState> logOutputKey = GlobalKey<LogOutputState>();
  void logAndPrint(String message) {
    // print(message);
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
    final globalState = provider.Provider.of<GlobalState>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AutomatoThemeColors.bright(context),
                AutomatoThemeColors.primaryColor(context)
              ],
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
        height: 80, // Reduced height
        color: AutomatoThemeColors.bright(context),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 15,
                width: double.infinity,
                color: AutomatoThemeColors.bright(context),
                child: buildRepeatingBorderSVG(
                  context,
                  svgWidget: const AutomatoBorderSVG(
                    svgString: AutomatoSvgStrings.automatoSvgStrBorder,
                  ),
                  height: 50,
                  width: 50,
                  mirror: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AutomatoThemeColors.primaryColor(context),
                    AutomatoThemeColors.bright(context)
                  ],
                ),
              ),
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                    icon: MouseRegion(
                      onEnter: (_) => setState(
                          () => globalState.isHoveringSelectAll = true),
                      onExit: (_) => setState(
                          () => globalState.isHoveringSelectAll = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: globalState.isHoveringSelectAll
                              ? AutomatoThemeColors.brown15(context)
                              : AutomatoThemeColors.transparentColor(context),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.select_all,
                          size: 28.0,
                          color: AutomatoThemeColors.darkBrown(context),
                        ),
                      ),
                    ),
                    label: 'Select All',
                  ),
                  BottomNavigationBarItem(
                    icon: MouseRegion(
                      onEnter: (_) => setState(
                          () => globalState.isHoveringUnselectAll = true),
                      onExit: (_) => setState(
                          () => globalState.isHoveringUnselectAll = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: globalState.isHoveringUnselectAll
                              ? AutomatoThemeColors.brown15(context)
                              : AutomatoThemeColors.transparentColor(context),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.cancel,
                          size: 28.0,
                          color: AutomatoThemeColors.darkBrown(context),
                        ),
                      ),
                    ),
                    label: 'Unselect All',
                  ),
                  BottomNavigationBarItem(
                    icon: MouseRegion(
                      onEnter: (_) =>
                          setState(() => globalState.isHoveringUndo = true),
                      onExit: (_) =>
                          setState(() => globalState.isHoveringUndo = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: globalState.isHoveringUndo
                              ? AutomatoThemeColors.brown15(context)
                              : AutomatoThemeColors.transparentColor(context),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.undo,
                          size: 28.0, // Reduced icon size
                          color: AutomatoThemeColors.dangerZone(context),
                        ),
                      ),
                    ),
                    label: 'Undo',
                  ),
                  BottomNavigationBarItem(
                    icon: MouseRegion(
                      onEnter: (_) =>
                          setState(() => globalState.isHoveringModify = true),
                      onExit: (_) =>
                          setState(() => globalState.isHoveringModify = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: globalState.isHoveringModify
                              ? AutomatoThemeColors.brown15(context)
                              : AutomatoThemeColors.transparentColor(context),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.shuffle,
                          size: 28.0, // Reduced icon size
                          color: AutomatoThemeColors.saveZone(context),
                        ),
                      ),
                    ),
                    label: 'Modify',
                  ),
                ],
                currentIndex: globalState.selectedIndex,
                selectedItemColor: AutomatoThemeColors.selected(context),
                unselectedItemColor: AutomatoThemeColors.darkBrown(context),
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedLabelStyle: const TextStyle(fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: Stack(children: [
        AutomatoBackground(
          showRepeatingBorders: false,
          gradientColor: AutomatoThemeColors.gradient(context),
          linesConfig: LinesConfig(
              lineColor: AutomatoThemeColors.darkBrown(context),
              strokeWidth: 1.0,
              spacing: 5.0,
              flickerDuration: const Duration(milliseconds: 10000),
              enableFlicker: true,
              drawHorizontalLines: true,
              drawVerticalLines: true),
        ),
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
      ]),
    );
  }

  void scrollToSetup(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context);
    }
  }

  void _onItemTapped(int index) {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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

        globalLog(
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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
      globalLog("Error: Please select both input and output directories. 💋 ");
      setState(() {
        globalState.isLoading = false;
      });
      return;
    }

    globalLog("Starting randomization process... 🏃‍➡️");

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

      globalLog("Randomization process completed successfully.");
    } on Exception catch (e) {
      globalLog("Error occurred: $e");
    } finally {
      setState(() {
        globalState.isLoading = false;
      });
      globalLog('Thank you for using the randomization tool.');
      globalLog(asciiArt2B);
      globalLog("Randomization process finished.");
      showCompletionDialog();
    }
  }

  void logErrorDetails(dynamic e, StackTrace stackTrace) {
    globalLog("Error: $e");
    globalLog("Stack Trace: $stackTrace");
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
            globalLog("Deleted file: $filePath");
          } catch (e) {
            globalLog("Error deleting file $filePath: $e");
            setState(() {
              globalState.logMessages.add("Error deleting file $filePath: $e");
              startBlinkAnimation();
            });
          }
        } else {
          globalLog("File not found: $filePath");
          setState(() {
            globalLog("File not found: $filePath");
            startBlinkAnimation();
          });
        }
      }

      setState(() {
        globalLog("Last randomization undone.");
        startBlinkAnimation();
        globalState.isLoading = false;
        globalState.isProcessing = false;
      });

      globalState.createdFiles.clear();
    } catch (e) {
      globalLog("An error occurred during undo: $e");
      setState(() {
        globalLog("Error during undo: $e");
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    List<String> details = [];

    String enemyList = getSelectedEnemiesNames();

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

    if (enemyList.isNotEmpty && globalState.enemyStats != 0.0) {
      details.add(
          "• Change Enemy Stats: x${globalState.enemyStats} for $enemyList");
    } else {
      details.add("• Change Enemy Stats: None");
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AutomatoThemeColors.brown25(context),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                        AutomatoThemeColors.darkBrown(context).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const SingleChildScrollView(
                child: EnemyLevelSelection(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AutomatoThemeColors.brown25(context),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                        AutomatoThemeColors.darkBrown(context).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const SingleChildScrollView(
                child: CategorySelection(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AutomatoThemeColors.brown25(context),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                        AutomatoThemeColors.darkBrown(context).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const SingleChildScrollView(
                child: EnemyStatsSelection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> loadPathsFromSharedPreferences() async {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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
