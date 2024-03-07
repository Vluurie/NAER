import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:provider/provider.dart';

class DragDropWidget extends StatefulWidget {
  final CLIArguments cliArguments;

  const DragDropWidget({Key? key, required this.cliArguments})
      : super(key: key);

  @override
  _DragDropWidgetState createState() => _DragDropWidgetState();
}

class _DragDropWidgetState extends State<DragDropWidget> {
  bool _dragging = false;
  final List<String> _files = [];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<LogState>(context).logs;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 60, top: 40),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 31, 29, 29),
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
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, index) => Text(
                      logs[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: DropTarget(
                  onDragEntered: (detail) => setState(() => _dragging = true),
                  onDragExited: (detail) => setState(() => _dragging = false),
                  onDragDone: (details) {
                    _processDraggedItems(
                        details.files.map((file) => file.path).toList());
                  },
                  child: Container(
                    width: 400,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _dragging
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dragging ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_copy,
                          size: 50,
                          color: _dragging
                              ? Colors.green
                              : const Color.fromARGB(255, 1, 215, 253),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _dragging
                              ? 'Release to process'
                              : 'Drag folders here to randomize them',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processDraggedItems(List<String> paths) {
    setState(() {
      _dragging = false;
      _files.clear();
    });

    // Access LogState from the Provider
    final logState = Provider.of<LogState>(context, listen: false);

    for (var path in paths) {
      var type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        _files.add(path);
        logState.addLog(
            "Processing folder: $path"); // Update logState with the log message

        // Continue with the directory processing
        randomizeDraggedFile([path]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please drop folders only, not files.',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> randomizeDraggedFile(List<String> droppedFolders) async {
    final logState = Provider.of<LogState>(context, listen: false);
    if (widget.cliArguments.input.isEmpty ||
        widget.cliArguments.specialDatOutputPath.isEmpty ||
        !Platform.isWindows) {
      return;
    }

    String command = widget.cliArguments.command;
    List<String> baseArgs = List.from(widget.cliArguments.processArgs);
    var currentDir = Directory.current.path;
    command = p.join(currentDir, 'bin', 'fork', 'nier_cli.exe');

    for (String folderPath in droppedFolders) {
      if (FileSystemEntity.typeSync(folderPath) ==
          FileSystemEntityType.directory) {
        List<String> arguments = List.from(baseArgs);
        arguments[0] = folderPath;

        try {
          Process process =
              await Process.start(command, arguments, runInShell: true);
          await for (var data in process.stdout.transform(utf8.decoder)) {
            for (var line in data.split('\n')) {
              logState.addLog(line);
            }
          }

          await process.exitCode;
          setState(() {
            _scrollToBottom();
          });
        } catch (e) {
          logState.addLog("Failed to process folder $folderPath: $e");
        }
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(
        Duration.zero,
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
  }
}
