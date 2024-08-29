// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_cli/handle_cli.dart';
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
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart' as provider;

void main(final List<String> arguments) async {
  if (arguments.isNotEmpty) {
    handleCommandLineExecution(arguments);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await dotenv.load();
    final themeNotifier = await AutomatoThemeNotifier.loadFromPreferences();
    unawaited(windowManager.setPreventClose(true));

    runApp(
      ProviderScope(
        overrides: [
          automatoThemeNotifierProvider
              .overrideWith((final ref) => themeNotifier),
        ],
        child: MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (final _) => LogState()),
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
  Widget build(final BuildContext context, final WidgetRef ref) {
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

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _initializeApp();
    });

    log('initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((final _) {
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
    unawaited(updateItemsByType(SideQuest, ref, checkAllItems: true));
    unawaited(updateItemsByType(MapLocation, ref, checkAllItems: true));
    unawaited(updateItemsByType(ScriptingPhase, ref, checkAllItems: true));

    await FileChange.loadChanges();
    await FileChange.loadDLCOption(ref);
    await FileChange.loadIgnoredFiles();

    await _checkForUpdate();
  }

  void startBlinkAnimation() {
    if (!_blinkController.isAnimating) {
      _blinkController.forward(from: 0).then((final _) {
        _blinkController.reverse();
      });
    }
  }

  void _togglePanel() {
    final globalState = ref.read(globalStateProvider.notifier);
    globalState.setIsPanelVisible(
        isPanelVisible: !globalState.readIsPanelVisible());
  }

  Future<void> _checkForUpdate() async {
    final updateService = UpdateService();

    try {
      await updateService.showLoadingDialog(context, ref);

      final latestRelease = await updateService.getLatestRelease();

      Navigator.of(context).pop();

      if (latestRelease != null &&
          updateService.isUpdateAvailable(latestRelease['version']!)) {
        updateService.showUpdateDialog(
          context,
          ref,
          latestRelease['version']!,
          latestRelease['description']!,
          latestRelease['installerUrl']!,
        );
      } else {
        globalLog("You are on the latest Version of NAER!");
      }
    } catch (e) {
      Navigator.of(context).pop();
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
  Widget build(final BuildContext context) {
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
