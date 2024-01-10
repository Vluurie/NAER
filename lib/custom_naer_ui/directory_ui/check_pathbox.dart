import 'dart:convert';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

class SavePathsWidget extends StatefulWidget {
  final String? input;
  final String? output;
  final String? scriptPath;
  final bool savePaths;
  final Function(bool) onCheckboxChanged;

  const SavePathsWidget({
    super.key,
    this.input,
    this.output,
    this.scriptPath,
    this.savePaths = false,
    required this.onCheckboxChanged,
  });

  @override
  _SavePathsWidgetState createState() => _SavePathsWidgetState();
}

class _SavePathsWidgetState extends State<SavePathsWidget> {
  @override
  Widget build(BuildContext context) {
    // Determine if the checkbox should be enabled
    bool isCheckboxEnabled = widget.input?.isNotEmpty == true &&
        widget.output?.isNotEmpty == true &&
        widget.scriptPath?.isNotEmpty == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          value: widget.savePaths,
          onChanged: isCheckboxEnabled
              ? (bool? newValue) {
                  if (newValue == true) {
                    savePathsToJson();
                  }
                  // Notify the parent widget of the change.
                  widget.onCheckboxChanged(newValue ?? false);
                }
              : null,
        ),
        const Text(
          'Save paths for future',
        ),
      ],
    );
  }

  // Function to save paths
  Future<void> savePathsToJson() async {
    String directoryPath = await FileChange.ensureSettingsDirectory();
    File settingsFile = File(p.join(directoryPath, 'paths.json'));

    Map<String, String> paths = {
      'input': widget.input ?? '',
      'output': widget.output ?? '',
      'scriptPath': widget.scriptPath ?? '',
    };

    await settingsFile.writeAsString(jsonEncode(paths));
  }
}
