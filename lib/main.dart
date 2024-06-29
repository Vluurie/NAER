// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:isolate';
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
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';
import 'package:stack_trace/stack_trace.dart';

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (arguments.isNotEmpty) {
    final receivePort = ReceivePort();
    Map<String, dynamic> args = {
      'processArgs': arguments,
      'isManagerFile': false,
      'sendPort': receivePort.sendPort,
    };
    await compute(runNierCliIsolated, args);
    exit(0);
  } else {
    final themeNotifier = await AutomatoThemeNotifier.loadFromPreferences();

    runApp(
      ProviderScope(
        overrides: [
          automatoThemeNotifierProvider.overrideWith((ref) => themeNotifier),
        ],
        child: MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => GlobalState()),
            provider.ChangeNotifierProvider(create: (_) => LogState()),
          ],
          child: const EnemyRandomizerApp(),
        ),
      ),
    );
  }
}

class EnemyRandomizerApp extends ConsumerWidget {
  const EnemyRandomizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(automatoThemeNotifierProvider).theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NieR:Automata Enemy Randomizer Tool',
      theme: theme,
      home: const EnemyRandomizerAppState(),
    );
  }
}

class EnemyRandomizerAppState extends ConsumerStatefulWidget {
  const EnemyRandomizerAppState({super.key});

  @override
  _EnemyRandomizerAppState createState() => _EnemyRandomizerAppState();
}

class _EnemyRandomizerAppState extends ConsumerState<EnemyRandomizerAppState>
    with TickerProviderStateMixin {
  final GlobalKey<LogOutputState> logOutputKey = GlobalKey<LogOutputState>();

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
    _blinkController.dispose();
    super.dispose();
    log('dispose called');
  }

  @override
  Widget build(BuildContext context) {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AutomatoThemeColors.primaryColor(ref),
                    AutomatoThemeColors.bright(ref),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: NaerAppBar(
                blinkController: _blinkController,
                scrollToSetup: () =>
                    scrollToSetup(globalState.setupLogOutputKey),
                setupLogOutputKey: globalState.setupLogOutputKey,
                button: navigateButton(context, scrollController, ref),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80, // Reduced height
        color: AutomatoThemeColors.bright(ref),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 15,
                width: double.infinity,
                color: AutomatoThemeColors.bright(ref),
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
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AutomatoThemeColors.primaryColor(ref),
                      AutomatoThemeColors.bright(ref)
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
                                ? AutomatoThemeColors.brown15(ref)
                                : AutomatoThemeColors.transparentColor(ref),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.select_all,
                            size: 28.0,
                            color: AutomatoThemeColors.darkBrown(ref),
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
                                ? AutomatoThemeColors.brown15(ref)
                                : AutomatoThemeColors.transparentColor(ref),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.cancel,
                            size: 28.0,
                            color: AutomatoThemeColors.darkBrown(ref),
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
                                ? AutomatoThemeColors.brown15(ref)
                                : AutomatoThemeColors.transparentColor(ref),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.undo,
                            size: 28.0, // Reduced icon size
                            color: AutomatoThemeColors.dangerZone(ref),
                          ),
                        ),
                      ),
                      label: 'Undo',
                    ),
                    BottomNavigationBarItem(
                      icon: MouseRegion(
                        onEnter: (_) =>
                            setState(() => globalState.isHoveringModify = true),
                        onExit: (_) => setState(
                            () => globalState.isHoveringModify = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: globalState.isHoveringModify
                                ? AutomatoThemeColors.brown15(ref)
                                : AutomatoThemeColors.transparentColor(ref),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.shuffle,
                            size: 28.0, // Reduced icon size
                            color: AutomatoThemeColors.saveZone(ref),
                          ),
                        ),
                      ),
                      label: 'Modify',
                    ),
                  ],
                  currentIndex: globalState.selectedIndex,
                  selectedItemColor: AutomatoThemeColors.selected(ref),
                  unselectedItemColor: AutomatoThemeColors.darkBrown(ref),
                  onTap: _onItemTapped,
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  selectedLabelStyle: const TextStyle(fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(children: [
        AutomatoBackground(
          ref: ref,
          showRepeatingBorders: false,
          gradientColor: AutomatoThemeColors.gradient(ref),
          linesConfig: LinesConfig(
              lineColor: AutomatoThemeColors.bright(ref),
              strokeWidth: 2.5,
              spacing: 5.0,
              flickerDuration: const Duration(milliseconds: 5000),
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
        showUndoConfirmation(context, ref);
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
        await startRandomizing(context);
        await FileChange.saveChanges();
        stopwatch.stop();

        globalLog(
          'Total randomization time: ${stopwatch.elapsed}',
        );
      } catch (e, stackTrace) {
        LogState.logError(
            'Error during randomization $e', Trace.from(stackTrace));
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
      showModifyConfirmation(context, ref);
    }
  }

// MAIN MODIFY BUTTON FUNCTIONALITY
  Future<void> startRandomizing(BuildContext context) async {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    globalState.hasError = true;
    globalState.isLoading = true;
    globalState.loggedStages.clear();

    if (globalState.input.isEmpty || globalState.specialDatOutputPath.isEmpty) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      globalState.isLoading = false;
      return;
    }

    scrollToSetup(globalState.setupLogOutputKey);

    await Future.delayed(const Duration(milliseconds: 800));

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
      final receivePort = ReceivePort();

      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          if (message['event'] == 'file_change') {
            logState.addLog("File created: ${message['filePath']}");
            FileChange.changes.add(FileChange(
              message['filePath'],
              message['action'],
            ));
          } else if (message['event'] == 'error') {
            logState.addLog(
                "Error: ${message['details']}\nStack Trace: ${message['stackTrace']}");
          }
        } else if (message is String) {
          logState.addLog(message);
        }
      });

      Map<String, dynamic> args = {
        'processArgs': cliArgs.processArgs,
        'isManagerFile': isManagerFile,
        'sendPort': receivePort.sendPort,
      };

      // Run nierCli in a separate isolate
      await compute(runNierCliIsolated, args);

      globalLog("Randomization process completed successfully.");
    } on Exception catch (e) {
      globalLog("Error occurred: $e");
    } finally {
      globalState.isLoading = false;
      globalLog('Thank you for using the randomization tool.');
      globalLog(asciiArt2B);
      globalLog("Randomization process finished.");
      showCompletionDialog(context, ref);
    }
  }

  void logErrorDetails(dynamic e, StackTrace stackTrace) {
    globalLog("Error: $e");
    globalLog("Stack Trace: $stackTrace");
  }

  void undoLastRandomization() async {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
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

  void showUndoConfirmation(BuildContext context, WidgetRef ref) {
    AutomatoDialogManager().showYesNoDialog(
      context: context,
      title: 'Confirm Undo Everything',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to undo every last modification you did?',
            style: TextStyle(
                color: AutomatoThemeColors.textDialogColor(ref), fontSize: 22),
          ),
          const SizedBox(height: 10),
          const Text(
            'Important:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red,
            ),
          ),
          Text(
            '• Avoid using this function while the game is running as it may cause issues.',
            style: TextStyle(
              fontSize: 18,
              color: AutomatoThemeColors.textDialogColor(ref),
            ),
          ),
          Text(
            '• This will also undo the installed mod manager files so you need to reinstall them if they got affected.',
            style: TextStyle(
              fontSize: 18,
              color: AutomatoThemeColors.textDialogColor(ref),
            ),
          ),
        ],
      ),
      onYesPressed: () {
        Navigator.of(context).pop();
        undoLastRandomization();
      },
      onNoPressed: () {
        Navigator.of(context).pop();
      },
      ref: ref,
    );
  }

  void showModifyConfirmation(BuildContext context, WidgetRef ref) {
    String modificationDetails = _generateModificationDetails();

    AutomatoDialogManager().showYesNoDialog(
      context: context,
      ref: ref,
      title: 'Confirm Modification',
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.5, // Adjust the height as needed
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to start modification? Below are the selected settings:",
                style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                modificationDetails,
                style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      onYesPressed: () {
        Navigator.of(context).pop();
        handleStartRandomizing();
      },
      onNoPressed: () {
        Navigator.of(context).pop();
      },
      yesLabel: 'Yes, Modify',
      noLabel: 'No, I still have work to do.',
      activeHoverColorNo: AutomatoThemeColors.darkBrown(ref),
      activeHoverColorYes: AutomatoThemeColors.saveZone(ref),
      yesButtonColor: AutomatoThemeColors.darkBrown(ref),
      noButtonColor: AutomatoThemeColors.darkBrown(ref),
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

  void showCompletionDialog(BuildContext context, WidgetRef ref) {
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    globalState.isLoading = false;

    AutomatoDialogManager().showInfoDialog(
        context: context,
        ref: ref,
        title: 'Randomization Complete',
        content: Text(
          'Randomization process completed successfully.',
          style: TextStyle(
            color: AutomatoThemeColors.textDialogColor(ref),
            fontSize: 18,
          ),
        ),
        onOkPressed: () {
          Navigator.of(context).pop();
        },
        okLabel: "Ok");
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
                color: AutomatoThemeColors.brown25(ref),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
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
                color: AutomatoThemeColors.brown25(ref),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
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
                color: AutomatoThemeColors.brown25(ref),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
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
