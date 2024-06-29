import 'package:NAER/naer_utils/global_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';

class LogOutput extends ConsumerStatefulWidget {
  const LogOutput({super.key});

  @override
  LogOutputState createState() => LogOutputState();
}

class LogOutputState extends ConsumerState<LogOutput> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    LogState().addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    LogState().removeListener(_scrollToBottom);
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearLogMessages() {
    LogState().clearLogs();
  }

  void onCopyArgsPressed(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      copyCLIArguments(context);
    });
  }

  void copyCLIArguments(BuildContext context) {
    GlobalState globalState;
    try {
      globalState = provider.Provider.of<GlobalState>(context, listen: false);
    } catch (e) {
      globalLog('Error accessing Provider: $e');
      return;
    }

    _performCopyCLIArguments(context, globalState);
  }

  Future<void> _performCopyCLIArguments(
      BuildContext context, GlobalState globalState) async {
    try {
      if (globalState.input.isEmpty ||
          globalState.specialDatOutputPath.isEmpty) {
        globalLog(
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
        globalLog(
            "NieR CLI Arguments: ${cliArgs.command} ${cliArgs.processArgs.join(' ')}");
      }

      Clipboard.setData(ClipboardData(text: cliArgs.fullCommand.join(' ')))
          .then((result) {
        const snackBar = SnackBar(content: Text('Command copied to clipboard'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((e) {
        globalLog("Error copying to clipboard: $e");
      });
    } catch (e) {
      if (context.mounted) {
        globalLog("Error gathering CLI arguments: $e");
      }
    }
  }

  List<InlineSpan> buildLogMessageSpans(BuildContext context) {
    final logState = LogState();
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

  bool isLastMessageProcessing() {
    final globalLogs = LogState.getGlobalLogs();
    if (globalLogs.isNotEmpty) {
      String lastMessage = globalLogs.last;

      bool isProcessing = lastMessage.isNotEmpty &&
          !lastMessage.contains("Completed") &&
          !lastMessage.contains("Error") &&
          !lastMessage.contains("Randomization process finished") &&
          !lastMessage.contains("Thank you for using the randomization tool") &&
          !lastMessage.contains("NieR CLI") &&
          !lastMessage.contains("Last") &&
          !lastMessage.contains("Total randomization");
      return isProcessing;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider.value(
      value: LogState(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, right: 150, left: 150),
            child: Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AutomatoThemeColors.darkBrown(ref),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.3),
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
                      provider.Consumer<LogState>(
                        builder: (context, logState, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: logState.logs.isNotEmpty
                                      ? buildLogMessageSpans(context)
                                      : [
                                          const TextSpan(
                                              style: TextStyle(fontSize: 30),
                                              text:
                                                  "Hey there! It's quiet for now... 🤫\n\n"),
                                        ],
                                ),
                              ),
                              if (isLastMessageProcessing())
                                Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        child: Lottie.asset(
                                            'assets/animations/loading.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        child: Lottie.asset(
                                            'assets/animations/loading.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        child: Lottie.asset(
                                            'assets/animations/loading.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 10.0),
                                        child: Lottie.asset(
                                            'assets/animations/loading.json',
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          );
                        },
                      ),
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 60.0, horizontal: 20.0),
                  child: AutomatoButton(
                      label: "Clear Log",
                      onPressed: clearLogMessages,
                      uniqueId: "clearLog")),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 10.0),
                  child: AutomatoButton(
                      label: "Copy CLI Arguments",
                      onPressed: () => onCopyArgsPressed(context),
                      uniqueId: "copyArguments")),
            ],
          )
        ],
      ),
    );
  }
}
