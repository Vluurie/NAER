// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'dart:isolate';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_cli/console_service.dart';
import 'package:NAER/naer_cli/handle_guided_argument.dart';
import 'package:NAER/naer_services/error_utils/windows_close_handler.dart';
import 'package:NAER/naer_ui/appbar/appbar.dart';
import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/setup/bottom_navbar.dart';
import 'package:NAER/naer_ui/setup/category_selection_widget.dart';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:NAER/naer_ui/setup/naer_main_page_setup.dart';
import 'package:NAER/naer_ui/setup/options_panel.dart';
import 'package:NAER/naer_ui/setup/splash_screen.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/start_modification_process.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/naer_utils/update_util.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart' as provider;

void main(List<String> arguments) async {
  bool isBalanceMode = false;
  bool hasDLC = false;
  bool backUp = false;
  bool guided = arguments.contains('--guided');

  // // Test mode: predefined arguments
  // if (arguments.isEmpty) {
  //   arguments = [
  //     r'D:\SteamLibrary\steamapps\common\NieRAutomata\data',
  //     '--output',
  //     r'D:\SteamLibrary\steamapps\common\NieRAutomata\data',
  //     'ALL',
  //     '--enemies',
  //     '[em3000]',
  //     '--enemyStats',
  //     '5.0',
  //     '--level=99',
  //     '--p100',
  //     '--category=allenemies',
  //     '--backUp',
  //   ];
  //   print('test arguments: $arguments');
  // }

  if (guided) {
    List<String> guidedArgs = await guidedMode();
    arguments = guidedArgs;
  }

  // Process the arguments
  if (arguments.isNotEmpty) {
    for (String arg in arguments) {
      if (arg == '--balance') {
        isBalanceMode = true;
      } else if (arg == '--dlc') {
        hasDLC = true;
      } else if (arg == '--backUp') {
        backUp = true;
      }
    }

    final receivePort = ReceivePort();
    final cmh = ConsoleMessageHandler();
    cmh.listenToReceivePort(receivePort);
    Map<String, dynamic> args = {
      'processArgs': arguments,
      'isManagerFile': false,
      'sendPort': receivePort.sendPort,
      'isBalanceMode': isBalanceMode,
      'hasDLC': hasDLC,
      'backUp': backUp,
    };

    await compute(runNierCliIsolated, args);
    cmh.printAsciiMessage("Cleaning Input: ${arguments[0]}");
    await deleteExtractedGameFolders(arguments[0]);
    cmh.printAsciiMessage('''
                                                                                                                                       
                  All modifications were successfully completed!
  ''');
    exit(0);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await dotenv.load(fileName: ".env");
    final themeNotifier = await AutomatoThemeNotifier.loadFromPreferences();
    unawaited(windowManager.setPreventClose(true));

    runApp(
      ProviderScope(
        overrides: [
          automatoThemeNotifierProvider.overrideWith((ref) => themeNotifier),
        ],
        child: MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => LogState()),
          ],
          child: const EnemyRandomizerApp(),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EnemyRandomizerApp extends ConsumerWidget {
  const EnemyRandomizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(automatoThemeNotifierProvider).theme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NieR:Automata Enemy Randomizer Tool',
      theme: theme,
      home: const SplashScreen(),
    );
  }
}

class EnemyRandomizerAppState extends ConsumerStatefulWidget {
  const EnemyRandomizerAppState({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EnemyRandomizerAppState createState() => _EnemyRandomizerAppState();
}

class _EnemyRandomizerAppState extends ConsumerState<EnemyRandomizerAppState>
    with TickerProviderStateMixin {
  final GlobalKey<LogOutputState> logOutputKey = GlobalKey<LogOutputState>();

  late ScrollController _scrollController;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    windowManager.addListener(WindowsCloseListener(context, ref));
    _scrollController = ScrollController();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });

    log('initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () async {
        final globalState = ref.read(globalStateProvider);

        // Automatically search for paths if they are empty
        if (globalState.input.isEmpty) {
          globalLog('Input path is empty.');
          await InputDirectoryHandler().autoSearchInputPath(context, ref);
        }
      });
    });
  }

  Future<void> _initializeApp() async {
    unawaited(updateItemsByType(SideQuest, true, ref));
    unawaited(updateItemsByType(MapLocation, true, ref));
    unawaited(updateItemsByType(ScriptingPhase, true, ref));

    await FileChange.loadChanges();
    await FileChange.loadDLCOption(ref);
    await FileChange.loadIgnoredFiles();

    await _checkForUpdate();
  }

  void startBlinkAnimation() {
    if (!_blinkController.isAnimating) {
      _blinkController.forward(from: 0).then((_) {
        _blinkController.reverse();
      });
    }
  }

  void _togglePanel() {
    final globalState = ref.read(globalStateProvider.notifier);
    globalState.setIsPanelVisible(!globalState.readIsPanelVisible());
  }

  Future<void> _checkForUpdate() async {
    final updateService = UpdateService();
    try {
      final latestRelease = await updateService.getLatestRelease();
      if (latestRelease != null &&
          updateService.isUpdateAvailable(latestRelease['version']!)) {
        updateService.showUpdateDialog(context, ref, latestRelease['version']!,
            latestRelease['description']!);
      }
    } catch (e) {
      globalLog('Failed to check for updates: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _blinkController.dispose();
    windowManager.removeListener(WindowsCloseListener(context, ref));
    super.dispose();
    log('dispose called');
  }

  @override
  Widget build(BuildContext context) {
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final globalState = ref.watch(globalStateProvider);

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
                scrollToSetup: () => globalStateNotifier.scrollToSetup(),
                setupLogOutputKey: globalState.setupLogOutputKey,
                onMenuPressed: _togglePanel,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NaerBottomNavigationBar(),
      body: Stack(
        children: [
          AutomatoBackground(
            ref: ref,
            showRepeatingBorders: false,
            gradientColor: !validateInputOutput(globalState)
                ? AutomatoThemeColors.dangerZone(ref)
                : AutomatoThemeColors.gradient(ref),
            linesConfig: LinesConfig(
              lineColor: !validateInputOutput(globalState)
                  ? AutomatoThemeColors.dangerZone(ref)
                  : AutomatoThemeColors.bright(ref),
              strokeWidth: 2.5,
              spacing: 5.0,
              flickerDuration: const Duration(milliseconds: 5000),
              enableFlicker: true,
              drawHorizontalLines: true,
              drawVerticalLines: true,
            ),
          ),
          NaerMainPageSetup(ref: ref, logOutputKey: logOutputKey),
          OptionsPanel(
            isVisible: globalStateNotifier.readIsPanelVisible(),
            onToggle: _togglePanel,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
}
