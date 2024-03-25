import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NAER/nier_cli.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
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
            color: const Color.fromARGB(255, 31, 29, 29),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
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
                return const Center(
                  child: Text(
                    "⊂(◉‿◉)つ",
                    style: TextStyle(
                        fontSize: 70,
                        color: Colors.grey,
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

        try {
          await nierCli(arguments);
        } catch (e) {
          logState.addLog("Failed to process folder $folderPath: $e");
        }
      }
    }
  }
}
