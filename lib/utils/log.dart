import 'dart:io';
import 'package:NAER/customUI/DottedLineProgressAnimation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogViewerWidget extends StatefulWidget {
  LogViewerWidget({
    Key? key,
  }) : super(key: key);

  @override
  LogViewerWidgetState createState() => LogViewerWidgetState();
}

class LogViewerWidgetState extends State<LogViewerWidget> {
  final Set<String> loggedStages = {};
  final List<String> logMessages = [];
  final ScrollController scrollController = ScrollController();
  bool isProcessing = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Viewer'),
      ),
      body: setupLogOutput(
          logMessages, context, clearLogMessages, scrollController),
    );
  }

  Widget setupLogOutput(List<String> logMessages, BuildContext context,
      VoidCallback clearLogMessages, ScrollController scrollController) {
    // Function to determine text color based on message type
    Color _messageColor(String message) {
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
        return Colors.white; // Color for informational messages
      }
    }

    // Automatically scroll to the bottom of the list when new logs are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // Function to build styled text spans for each log message
    List<InlineSpan> _buildLogMessageSpans() {
      return logMessages.map((message) {
        String logIcon;
        if (message.toLowerCase().contains('error') ||
            message.toLowerCase().contains('failed')) {
          logIcon = '💥 ';
        } else if (message.toLowerCase().contains('warning')) {
          logIcon = '⚠️ ';
        } else {
          logIcon = 'ℹ️ '; // Icon for informational messages
        }

        return TextSpan(
          text: '$logIcon$message\n',
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            color: _messageColor(message),
          ),
        );
      }).toList();
    }

    // Building the log output widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
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
                    RichText(
                      text: TextSpan(
                        children: logMessages.isNotEmpty
                            ? _buildLogMessageSpans()
                            : [
                                TextSpan(
                                    text: "Hey there! It's quiet for now... 🤫")
                              ],
                      ),
                    ),
                    if (isLastMessageProcessing(logMessages))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 100.0),
                        child: DottedLineProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Center(
            child: ElevatedButton(
              onPressed: clearLogMessages,
              child: const Text('Clear Log'),
            ),
          ),
        ),
      ],
    );
  }

  bool isLastMessageProcessing(List<String> messages) {
    if (messages.isNotEmpty) {
      String lastMessage = messages.last;
      return lastMessage.isNotEmpty && !lastMessage.contains("Randomization");
    }
    return false;
  }

  void clearLogMessages() {
    setState(() {
      logMessages.clear(); // Clear the log messages
    });
  }

  void onNewLogMessage(BuildContext context, String newMessage) {
    if (newMessage.toLowerCase().contains('error')) {
      writeLog(newMessage); // Write the error to the log file

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' $newMessage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 255, 81, 81),
          ),
        );
      });
    }
  }

  Future<void> writeLog(String message) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log.txt');
    await file.writeAsString('$message\n', mode: FileMode.append);
  }

  void updateLog(String log) async {
    if (log.trim().isEmpty) {
      return;
    }

    // Scroll to the bottom of the list to show the new log message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate a delay
    var delay = const Duration(seconds: 1);
    setState(() {
      isProcessing = true;
    });

    await Future.delayed(delay);

    // Logic to handle different log messages
    String? stageIdentifier;
    if (log.startsWith("Repacking DAT file")) {
      stageIdentifier = 'repacking_dat';
      log = "Repacking DAT files initiated.";
    } else if (log.contains("Converting YAX to XML")) {
      stageIdentifier = 'converting_yax_to_xml';
      log = "Conversion from YAX to XML in progress...";
    } else if (log.contains("Converting XML to YAX")) {
      stageIdentifier = 'converting_xml_to_yax';
      log = "Conversion from XML to YAX in progress...";
    } else if (log.startsWith("Extracting CPK")) {
      stageIdentifier = 'extracting_cpk';
      log = "CPK Extraction started.";
    } else if (log.contains('Processing entity:')) {
      stageIdentifier = 'processing_entity';
      log = "Searching and replacing Enemies...";
    } else if (log.contains('Replaced objId')) {
      stageIdentifier = 'replacing_objid';
      log = "Replaced Enemies.";
    } else if (log.contains("Randomizing complete")) {
      stageIdentifier = 'randomizing_complete';
      log = "Randomizing process completed.";
    } else if (log.contains("Decompressing")) {
      stageIdentifier = 'decompressing';
      log = "Decompressing DAT files in progress.";
    } else if (log.contains("Skipping")) {
      stageIdentifier = 'skipping';
      log = "Skipping unnecessary DAT files.";
    } else if (log.contains("Object ID")) {
      stageIdentifier = 'id';
      log = "Replacing Enemies in process.";
    } else if (log.contains("Folder created")) {
      stageIdentifier = 'folder';
      log = "Processing files.. copy to output path.";
    } else if (log.contains("Export path")) {
      stageIdentifier = 'export';
      log = "Exporting dat files to output directory started.";
    } else if (log.contains("Deleted")) {
      stageIdentifier = 'deleted';
      log = "Deleting extracted CPK files in output directory...";
    } else if (log.contains("Reading")) {
      stageIdentifier = 'read';
      log = "Reading extracted files in process.";
    } else {
      // If the log message doesn't match any special case, add it directly
      setState(() {
        logMessages.add(log);
      });
    }

    // If a stage identifier is present and it's a new stage, add the log message
    if (stageIdentifier != null && !loggedStages.contains(stageIdentifier)) {
      setState(() {
        logMessages.add(log);
        loggedStages.add(stageIdentifier!);
      });
      // startBlinkAnimation(); // Uncomment if you have this method implemented
    }

    // Update processing state
    setState(() {
      isProcessing = false;
    });

    // Handle new log message (ensure this method exists and is properly implemented)
    // onNewLogMessage(context, log);
  }
}
