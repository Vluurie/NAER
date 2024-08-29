import 'dart:io';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form.dart';
import 'package:NAER/naer_mod_manager/ui/mod_loader_widget.dart';
import 'package:NAER/naer_mod_manager/ui/drag_n_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:automato_theme/automato_theme.dart';

class SecondPage extends ConsumerStatefulWidget {
  final CLIArguments cliArguments;

  const SecondPage({
    super.key,
    required this.cliArguments,
  });

  @override
  SecondPageState createState() => SecondPageState();
}

class SecondPageState extends ConsumerState<SecondPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double modLoaderWidgetOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        modLoaderWidgetOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMetadataFormPopup() {
    final modStateManager =
        provider.Provider.of<ModStateManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          child: MetadataForm(
            cliArguments: widget.cliArguments,
            modStateManager: modStateManager,
          ),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final outputPath = widget.cliArguments.specialDatOutputPath;
    final inputPath = widget.cliArguments.input;
    final globalState = ref.watch(globalStateProvider.notifier);

    final actionButtons = <Widget>[
      provider.Consumer<ModStateManager>(
        builder: (final context, final modStateManager, final child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AutomatoButton(
                label: modStateManager.isVerifying
                    ? "Stop Verification Checks"
                    : "Start Verification",
                onPressed: () {
                  modStateManager.toggleVerification();
                },
                uniqueId: "theme",
                maxScale: 0.8,
                showPointer: false,
                baseColor: AutomatoThemeColors.darkBrown(ref),
                activeFillColor: AutomatoThemeColors.primaryColor(ref),
                fillBehavior: FillBehavior.filledRightToLeft,
              ),
            ),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: AutomatoButton(
          label: "Clear Logs",
          onPressed: () async {
            setState(() {
              final logState =
                  provider.Provider.of<LogState>(context, listen: false);
              logState.clearLogs();
            });
          },
          uniqueId: "theme",
          maxScale: 0.8,
          showPointer: false,
          baseColor: AutomatoThemeColors.darkBrown(ref),
          activeFillColor: AutomatoThemeColors.primaryColor(ref),
          fillBehavior: FillBehavior.filledRightToLeft,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: IconButton(
          icon: const Icon(Icons.input, size: 32.0),
          color: AutomatoThemeColors.darkBrown(ref),
          tooltip: "Open Input Path",
          onPressed: () async => await openPaths(inputPath),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: IconButton(
          icon: const Icon(Icons.output, size: 32.0),
          color: AutomatoThemeColors.darkBrown(ref),
          onPressed: () => openPaths(outputPath),
          tooltip: "Open Output Path",
        ),
      ),
    ];

    return PopScope(
      onPopInvokedWithResult: (final canPop, final result) async {
        if (globalState.readIsModManagerPageProcessing()) {
          return;
        }
        canPop;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            title: Text(
              'MOD MANAGER',
              style: TextStyle(
                fontSize: 48.0,
                color: AutomatoThemeColors.darkBrown(ref),
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                      offset: const Offset(5.0, 5),
                      color:
                          AutomatoThemeColors.hoverBrown(ref).withOpacity(0.5)),
                ],
              ),
            ),
            foregroundColor: AutomatoThemeColors.darkBrown(ref),
            backgroundColor: AutomatoThemeColors.transparentColor(ref),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AutomatoThemeColors.primaryColor(ref),
                    AutomatoThemeColors.bright(ref),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            leading:
                canPop ? null : (actionButtons.isNotEmpty ? Container() : null),
            actions: globalState.readIsModManagerPageProcessing()
                ? null
                : (canPop ? actionButtons : null),
          ),
        ),
        body: Stack(
          children: [
            AutomatoBackground(
              showRepeatingBorders: false,
              gradientColor: AutomatoThemeColors.gradient(ref),
              linesConfig: LinesConfig(
                lineColor: AutomatoThemeColors.darkBrown(ref),
                strokeWidth: 1.0,
                spacing: 5.0,
                flickerDuration: const Duration(milliseconds: 10000),
                enableFlicker: false,
                drawHorizontalLines: true,
                drawVerticalLines: true,
              ),
              ref: ref,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: provider.Consumer<ModStateManager>(
                        builder: (final context, final modStateManager,
                            final child) {
                          return ModLoaderWidget(
                            cliArguments: widget.cliArguments,
                            modStateManager: modStateManager,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 250,
                            maxWidth: 450,
                            minHeight: 150,
                            maxHeight: 300,
                          ),
                          child:
                              DragDropWidget(cliArguments: widget.cliArguments),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 50.0,
                          top: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 250,
                            maxWidth: 550,
                            minHeight: 200,
                            maxHeight: 400,
                          ),
                          child: const LogOutput(),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showMetadataFormPopup,
          foregroundColor: AutomatoThemeColors.primaryColor(ref),
          backgroundColor: AutomatoThemeColors.darkBrown(ref),
          tooltip: 'Add Metadata',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> openPaths(final String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Path is empty')),
      );
      return;
    }
    if (Platform.isWindows) {
      await Process.run('explorer', [path]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Opening paths is not supported on this platform.')),
      );
    }
  }
}
