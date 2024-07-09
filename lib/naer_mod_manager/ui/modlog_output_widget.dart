import 'dart:io';
import 'dart:isolate';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/modify_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_utils/cli_arguments.dart';

class LogoutOutWidget extends ConsumerStatefulWidget {
  final CLIArguments cliArguments;
  const LogoutOutWidget({super.key, required this.cliArguments});

  @override
  ConsumerState<LogoutOutWidget> createState() => _LogoutOutWidgetState();
}

class _LogoutOutWidgetState extends ConsumerState<LogoutOutWidget> {
  final ScrollController _scrollController = ScrollController();
  LogState? logState;

  @override
  void initState() {
    super.initState();
    logState = provider.Provider.of<LogState>(context, listen: false);
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
    final logs = provider.Provider.of<LogState>(context).logs;
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
            color: AutomatoThemeColors.darkBrown(ref),
            border: Border.all(color: AutomatoThemeColors.bright(ref)),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AutomatoThemeColors.bright(ref).withOpacity(0.3),
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
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: AutomatoThemeColors.gradient(ref),
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
    final globalState =
        provider.Provider.of<GlobalState>(context, listen: false);
    final logState = provider.Provider.of<LogState>(context, listen: false);
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
          final receivePort = ReceivePort();

          receivePort.listen((message) {
            if (message is String) {
              logState.addLog(message);
            }
          });

          Map<String, dynamic> args = {
            'processArgs': arguments,
            'isManagerFile': true,
            'sendPort': receivePort.sendPort,
            'backUp': false,
            'isBalanceMode': globalState.isBalanceMode
          };
          globalState.isModManagerPageProcessing = true;
          await compute(runNierCliIsolated, args);
          globalState.isModManagerPageProcessing = false;
          globalLog(
              "Randomization process finished the dragged file successfully.");
        } catch (e) {
          globalState.isModManagerPageProcessing = false;
          logState.addLog("Failed to process folder $folderPath: $e");
        }
      }
    }
  }
}
