import 'dart:io';
import 'package:NAER/custom_naer_ui/mod__ui/log_output_widget.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:provider/provider.dart';

class DragDropWidget extends StatefulWidget {
  final CLIArguments cliArguments;
  final EdgeInsetsGeometry padding;

  const DragDropWidget(
      {super.key,
      required this.cliArguments,
      this.padding = const EdgeInsets.only(top: 40, right: 20, left: 80)});

  @override
  _DragDropWidgetState createState() => _DragDropWidgetState();
}

class _DragDropWidgetState extends State<DragDropWidget> {
  bool _dragging = false;
  final List<String> _files = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DropTarget(
              onDragEntered: (detail) => setState(() => _dragging = true),
              onDragExited: (detail) => setState(() => _dragging = false),
              onDragDone: (details) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Are You Sure?'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'This feature is more advanced. It randomizes any folder with the settings from the main page, but be warned:'),
                            Text(
                                'The modified files will not be added to the ignore list and will get overwritten on next randomization with other files if they are the same.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Proceed'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _processDraggedItems(details.files
                                .map((file) => file.path)
                                .toList());
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width =
                      constraints.maxWidth < 300 ? constraints.maxWidth : 300;
                  double height =
                      constraints.maxHeight < 150 ? constraints.maxHeight : 150;

                  return Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      color: _dragging
                          ? Colors.blue.withOpacity(0.4)
                          : const Color.fromARGB(255, 31, 29, 29),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dragging
                            ? Colors.blue
                            : const Color.fromARGB(255, 255, 255, 255),
                        width: 1,
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
                        Center(
                          child: Text(
                            _dragging
                                ? 'Release to process'
                                : 'Advanced: Drag folders to randomize',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _processDraggedItems(List<String> paths) async {
    setState(() => _isLoading = true); // Start loading

    final RandomizeDraggedFile random = RandomizeDraggedFile(
        cliArguments: widget.cliArguments, context: context);
    final logState = Provider.of<LogState>(context, listen: false);

    setState(() {
      logState.clearLogs();
      _dragging = false;
      _files.clear();
    });

    for (var path in paths) {
      var type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        _files.add(path);
        logState.addLog("Processing folder: $path");

        await random.randomizeDraggedFile([path]);
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
        return setState(() => _isLoading = false);
      }
    }

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(
          'Dragged folders randomized successfully and send to output path: ${widget.cliArguments.specialDatOutputPath}',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 103, 9),
      ),
    );
  }
}
