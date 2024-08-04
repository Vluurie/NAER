import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_mod_manager/ui/modlog_output_widget.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form.dart';
import 'package:NAER/naer_mod_manager/ui/mod_loader_widget.dart';
import 'package:NAER/naer_mod_manager/ui/drag_n_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecondPage extends ConsumerStatefulWidget {
  final CLIArguments cliArguments;

  const SecondPage({
    super.key,
    required this.cliArguments,
  });

  @override
  ConsumerState<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends ConsumerState<SecondPage>
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
      builder: (BuildContext context) {
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
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final modStateManager =
        provider.Provider.of<ModStateManager>(context, listen: false);
    final outputPath = widget.cliArguments.specialDatOutputPath;
    final inputPath = widget.cliArguments.input;

    final actionButtons = <Widget>[
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

    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if (globalState.isModManagerPageProcessing) {
          // Prevent navigation if the page is processing
          return false;
        }
        return true;
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
            actions: globalState.isModManagerPageProcessing
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
                      child: ModLoaderWidget(
                        cliArguments: widget.cliArguments,
                        modStateManager: modStateManager,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DragDropWidget(cliArguments: widget.cliArguments),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            LogoutOutWidget(cliArguments: widget.cliArguments),
                      ),
                    ),
                  ],
                ),
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

  Future<void> openPaths(String path) async {
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
