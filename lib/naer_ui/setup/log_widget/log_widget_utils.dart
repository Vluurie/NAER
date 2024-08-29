import 'package:NAER/naer_cli/console_service.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';

class LogWidgetUtils {
  bool isLastMessageProcessing() {
    final globalLogs = LogState.getGlobalLogs();
    if (globalLogs.isNotEmpty) {
      String lastMessage = globalLogs.last;

      bool isProcessing = lastMessage.isNotEmpty &&
          !lastMessage.contains("Completed") &&
          !lastMessage.contains("Error") &&
          !lastMessage.contains("Randomization process finished") &&
          !lastMessage.contains("Modification process finished") &&
          !lastMessage.contains("Thank you for using the randomization tool") &&
          !lastMessage.contains("Command") &&
          !lastMessage.contains("NieR CLI") &&
          !lastMessage.contains("Last") &&
          !lastMessage.contains("Total randomization") &&
          !lastMessage.contains("Total modification") &&
          !lastMessage.contains("Found NieR:Automata") &&
          !lastMessage.contains("Search permission denied") &&
          !lastMessage.contains("NieR:Automata") &&
          !lastMessage.contains("Copied") &&
          !lastMessage.contains("Affected mods") &&
          !lastMessage.contains("Balance Mode") &&
          !lastMessage.contains("All data") &&
          !lastMessage.contains("You are on") &&
          !lastMessage.contains("Failed") &&
          !lastMessage.contains("Ignore") &&
          !lastMessage.contains("Loaded") &&
          !lastMessage.contains("Input path") &&
          !lastMessage.contains("Normalized") &&
          !lastMessage.contains("Undo functionality") &&
          !lastMessage.contains("Re-checking") &&
          !lastMessage.contains("Re-checked") &&
          !lastMessage.contains("Mod verification") &&
          !lastMessage.contains("Mod requires") &&
          !lastMessage.contains("Deleted") &&
          !lastMessage.contains("Deleted file");

      return isProcessing;
    }
    return false;
  }

  Color messageColor(final String message) {
    if (message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('deleted')) {
      return Colors.red;
    } else if (message.toLowerCase().contains('no selected') ||
        message.toLowerCase().contains('processed') ||
        message.toLowerCase().contains('found') ||
        message.toLowerCase().contains('balance mode') ||
        message.toLowerCase().contains('balancing') ||
        message.toLowerCase().contains('normalized') ||
        message.toLowerCase().contains('creating three') ||
        message.toLowerCase().contains('temporary')) {
      return Colors.yellow;
    } else if (message.toLowerCase().contains('completed') ||
        message.toLowerCase().contains('finished') ||
        message.toLowerCase().contains('all data') ||
        message.toLowerCase().contains('started')) {
      return const Color.fromARGB(255, 59, 255, 59);
    } else if (message.toLowerCase().contains('█ █')) {
      return const Color.fromARGB(255, 255, 115, 1);
    } else {
      return Colors.white;
    }
  }

  void scrollToBottom(final ScrollController scrollController) {
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<InlineSpan> buildLogMessageSpans(final BuildContext context) {
    final logState = LogState();
    final consoleHandler = ConsoleMessageHandler();
    return logState.logs.map((final message) {
      String logIcon;
      if (message.toLowerCase().contains('error') ||
          message.toLowerCase().contains('failed')) {
        logIcon = '💥 ';
      } else if (message.toLowerCase().contains('warning')) {
        logIcon = '⚠️ ';
      } else {
        logIcon = 'ℹ️ ';
      }

      consoleHandler.printAsciiMessage(message);

      return TextSpan(
        text: '$logIcon$message\n',
        style: TextStyle(
          fontSize: 11.0,
          fontFamily: 'Courier New',
          fontWeight: FontWeight.bold,
          color: messageColor(message),
        ),
      );
    }).toList();
  }
}
