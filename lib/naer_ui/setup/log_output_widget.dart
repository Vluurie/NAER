import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_ui/other/asciiArt.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';

class LogOutput extends StatefulWidget {
  const LogOutput({super.key});

  @override
  LogOutputState createState() => LogOutputState();
}

class LogOutputState extends State<LogOutput> {
  final ScrollController scrollController = ScrollController();

  void clearLogMessages() {
    Provider.of<LogState>(context, listen: false).clearLogs();
  }

  void onCopyArgsPressed(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      copyCLIArguments(context);
    });
  }

  void copyCLIArguments(BuildContext context) {
    GlobalState globalState;
    try {
      globalState = Provider.of<GlobalState>(context, listen: false);
    } catch (e) {
      logAndPrint('Error accessing Provider: $e');
      return;
    }

    // Call the asynchronous method separately
    _performCopyCLIArguments(context, globalState);
  }

  Future<void> _performCopyCLIArguments(
      BuildContext context, GlobalState globalState) async {
    try {
      if (globalState.input.isEmpty ||
          globalState.specialDatOutputPath.isEmpty) {
        updateLog(
            "Error: Please select both input and output directories. 💋 ");
        return;
      }

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

      if (context.mounted) {
        updateLog(
            "NieR CLI Arguments: ${cliArgs.command} ${cliArgs.processArgs.join(' ')}");
      }

      Clipboard.setData(ClipboardData(text: cliArgs.fullCommand.join(' ')))
          .then((result) {
        const snackBar = SnackBar(content: Text('Command copied to clipboard'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((e) {
        updateLog("Error copying to clipboard: $e");
      });
    } catch (e) {
      if (context.mounted) {
        updateLog("Error gathering CLI arguments: $e");
      }
    }
  }

  void updateLog(String log) {
    final logState = Provider.of<LogState>(context, listen: false);
    if (log.trim().isEmpty) {
      return;
    }

    final processedLog = LogState.processLog(log);

    if (processedLog.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    logState.addLog(processedLog);
    onNewLogMessage(context, log);
  }

  void onNewLogMessage(BuildContext context, String newMessage) {
    if (newMessage.toLowerCase().contains('error')) {
      log(newMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' $newMessage',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 81, 81),
          ),
        );
      });
    }
  }

  List<InlineSpan> buildLogMessageSpans(BuildContext context) {
    final logState = Provider.of<LogState>(context);
    return logState.logs.map((message) {
      String logIcon;
      if (message.toLowerCase().contains('error') ||
          message.toLowerCase().contains('failed')) {
        logIcon = '💥 ';
      } else if (message.toLowerCase().contains('warning')) {
        logIcon = '⚠️ ';
      } else {
        logIcon = 'ℹ️ ';
      }

      return TextSpan(
        text: '$logIcon$message\n',
        style: TextStyle(
          fontSize: 16.0,
          fontFamily: 'Courier New',
          fontWeight: FontWeight.bold,
          color: messageColor(message),
        ),
      );
    }).toList();
  }

  Color messageColor(String message) {
    if (message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('failed')) {
      return Colors.red;
    } else if (message.toLowerCase().contains('no selected') ||
        message.toLowerCase().contains('processed') ||
        message.toLowerCase().contains('found') ||
        message.toLowerCase().contains('temporary')) {
      return Colors.yellow;
    } else if (message.toLowerCase().contains('completed') ||
        message.toLowerCase().contains('finished')) {
      return const Color.fromARGB(255, 59, 255, 59);
    } else {
      return Colors.white;
    }
  }

  bool isLastMessageProcessing(BuildContext context) {
    final logState = Provider.of<LogState>(context);
    if (logState.logs.isNotEmpty) {
      String lastMessage = logState.logs.last;

      bool isProcessing = lastMessage.isNotEmpty &&
          !lastMessage.contains("Completed") &&
          !lastMessage.contains("Error") &&
          !lastMessage.contains("Randomization") &&
          !lastMessage.contains("NieR CLI") &&
          !lastMessage.contains("Last") &&
          !lastMessage.contains("Total randomization");

      return isProcessing;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100.0, right: 150, left: 150),
          child: Container(
            height: 300,
            width: double.infinity,
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
                  blurRadius: 50,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(5.0),
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<LogState>(
                      builder: (context, logState, _) {
                        return RichText(
                          text: TextSpan(
                            children: logState.logs.isNotEmpty
                                ? buildLogMessageSpans(context)
                                : [
                                    const TextSpan(
                                        text:
                                            "Hey there! It's quiet for now... 🤫\n\n"),
                                    TextSpan(text: asciiArt2B),
                                  ],
                          ),
                        );
                      },
                    ),
                    if (isLastMessageProcessing(context))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 50.0),
                        child: Lottie.asset(
                            'assets/animations/loading.json', // Ensure you have this file in your assets folder
                            width: 200,
                            height: 200,
                            fit: BoxFit.fill),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 240, 71, 71)),
                ),
                onPressed: clearLogMessages,
                child: const Text('Clear Log'),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy CLI Arguments'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 25, 25, 26)),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 71, 192, 240)),
                ),
                onPressed: () => onCopyArgsPressed(context),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class LogControlButtons extends StatelessWidget {
  const LogControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final logState = context.read<LogOutputState>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 25, 25, 26)),
              foregroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 240, 71, 71)),
            ),
            onPressed: logState.clearLogMessages,
            child: const Text('Clear Log'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy CLI Arguments'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 25, 25, 26)),
              foregroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 71, 192, 240)),
            ),
            onPressed: () => logState.onCopyArgsPressed(context),
          ),
        ),
      ],
    );
  }
}
