import 'dart:io';
import 'package:NAER/custom_naer_ui/mod__ui/log_output_widget.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:provider/provider.dart';

class DragDropWidget extends StatefulWidget {
  final CLIArguments cliArguments;
  final EdgeInsetsGeometry padding; // Customizable padding

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: DropTarget(
        onDragEntered: (detail) => setState(() => _dragging = true),
        onDragExited: (detail) => setState(() => _dragging = false),
        onDragDone: (details) {
          _processDraggedItems(details.files.map((file) => file.path).toList());
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
                      : Color.fromARGB(255, 255, 255, 255),
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
                  Text(
                    _dragging
                        ? 'Release to process'
                        : 'Drag folders to randomize',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _processDraggedItems(List<String> paths) {
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

        random.randomizeDraggedFile([path]);
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
}
