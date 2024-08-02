import 'dart:io';
import 'package:NAER/naer_mod_manager/ui/modlog_output_widget.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

class DragDropWidget extends ConsumerStatefulWidget {
  final CLIArguments cliArguments;
  final EdgeInsetsGeometry padding;

  const DragDropWidget(
      {super.key,
      required this.cliArguments,
      this.padding = const EdgeInsets.only(top: 40, right: 20, left: 80)});

  @override
  DragDropWidgetState createState() => DragDropWidgetState();
}

class DragDropWidgetState extends ConsumerState<DragDropWidget> {
  bool _dragging = false;
  final List<String> _files = [];
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: _isLoading
          ? Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: AutomatoLoading(
                  color: AutomatoThemeColors.bright(ref),
                  translateX: 0,
                  svgString: AutomatoSvgStrings.automatoSvgStrHead,
                ),
              ),
            )
          : DropTarget(
              onDragEntered: (detail) => setState(() => _dragging = true),
              onDragExited: (detail) => setState(() => _dragging = false),
              onDragDone: (details) {
                AutomatoDialogManager().showYesNoDialog(
                  context: context,
                  ref: ref,
                  title: "Are You Sure?",
                  content: Text(
                    "This feature randomizes any folder with the settings from the main page. The modified files will not be added to the ignore list and will get overwritten on next randomization with other files if they are the same. You can undo them also with the main page undo button",
                    style: TextStyle(
                      color: AutomatoThemeColors.textDialogColor(ref),
                      fontSize: 20,
                    ),
                  ),
                  onYesPressed: () {
                    Navigator.of(context).pop();
                    _processDraggedItems(
                        details.files.map((file) => file.path).toList());
                  },
                  onNoPressed: () {
                    Navigator.of(context).pop();
                  },
                  yesLabel: "Proceed",
                  noLabel: "Cancel",
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
                          color:
                              AutomatoThemeColors.bright(ref).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      color: _dragging
                          ? AutomatoThemeColors.primaryColor(ref)
                              .withOpacity(0.4)
                          : AutomatoThemeColors.darkBrown(ref),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _dragging
                            ? AutomatoThemeColors.primaryColor(ref)
                            : AutomatoThemeColors.bright(ref),
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
                              ? AutomatoThemeColors.saveZone(ref)
                              : AutomatoThemeColors.primaryColor(ref),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            _dragging
                                ? 'Release to process'
                                : 'Drag folders to randomize them.',
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
    final logState = provider.Provider.of<LogState>(context, listen: false);

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
          SnackBar(
            content: const Text(
              'Please drop folders only, not files.',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
            backgroundColor: AutomatoThemeColors.dangerZone(ref),
          ),
        );
        return setState(() => _isLoading = false);
      }
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text(
            'Dragged folders randomized successfully and send to output path: ${widget.cliArguments.specialDatOutputPath}',
            style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: AutomatoThemeColors.darkBrown(ref),
        ),
      );
    }
  }
}
