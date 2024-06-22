import 'dart:io';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/modify_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';
import 'package:provider/provider.dart';
import 'package:NAER/nier_cli/nier_cli.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';

class LogoutOutWidget extends StatefulWidget {
  final CLIArguments cliArguments;
  const LogoutOutWidget({super.key, required this.cliArguments});

  @override
  State<LogoutOutWidget> createState() => _LogoutOutWidgetState();
}

class _LogoutOutWidgetState extends State<LogoutOutWidget> {
  final ScrollController _scrollController = ScrollController();
  LogState? logState;

  @override
  void initState() {
    super.initState();
    logState = Provider.of<LogState>(context, listen: false);
    logState?.addListener(_onLogUpdated);
  }

  void _onLogUpdated() {
    Future.microtask(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCirc,
        );
      }
    });
  }

  @override
  void dispose() {
    logState?.removeListener(_onLogUpdated);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<LogState>(context).logs;
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 0.8;
    final containerHeight = screenSize.height * 0.25;

    return Container(
      padding: const EdgeInsets.only(right: 80, top: 40),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: containerWidth,
          height: containerHeight,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AutomatoThemeColors.darkBrown(context),
            border: Border.all(color: AutomatoThemeColors.bright(context)),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AutomatoThemeColors.bright(context).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: logs.isEmpty ? 1 : logs.length,
            itemBuilder: (context, index) {
              if (logs.isEmpty) {
                return Center(
                  child: Text(
                    "NAER ( ˘ ³˘)ノ°ﾟº❍｡",
                    style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: AutomatoThemeColors.gradient(context),
                        fontStyle: FontStyle.normal),
                  ),
                );
              } else {
                return Text(
                  logs[index],
                  style: const TextStyle(color: Colors.white),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class RandomizeDraggedFile {
  final CLIArguments cliArguments;
  final BuildContext context;
  RandomizeDraggedFile({required this.cliArguments, required this.context});

  Future<void> randomizeDraggedFile(List<String> droppedFolders) async {
    final logState = Provider.of<LogState>(context, listen: false);
    if (cliArguments.input.isEmpty ||
        cliArguments.specialDatOutputPath.isEmpty ||
        !Platform.isWindows) {
      return;
    }

    List<String> baseArgs = List.from(cliArguments.processArgs);

    for (String folderPath in droppedFolders) {
      if (FileSystemEntity.typeSync(folderPath) ==
          FileSystemEntityType.directory) {
        List<String> arguments = List.from(baseArgs);
        arguments[0] = folderPath;
        arguments.modifyArgumentsForForcedEnemyList();

        try {
          bool isManagerFile = true;
          await nierCli(arguments, isManagerFile);
        } catch (e) {
          logState.addLog("Failed to process folder $folderPath: $e");
        }
      }
    }
  }
}
