import 'dart:convert';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class SavePathsWidget extends StatefulWidget {
  final String? input;
  final String? output;
  final String? scriptPath;
  final bool savePaths;
  final Function(bool) onCheckboxChanged;

  const SavePathsWidget({
    Key? key,
    this.input,
    this.output,
    this.scriptPath,
    required this.savePaths,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  _SavePathsWidgetState createState() => _SavePathsWidgetState();
}

class _SavePathsWidgetState extends State<SavePathsWidget> {
  late bool checkboxValue;

  @override
  void initState() {
    super.initState();
    checkboxValue = widget.savePaths;
  }

  Future<void> savePathsToJson() async {
    String directoryPath = await FileChange.ensureSettingsDirectory();
    File settingsFile = File(p.join(directoryPath, 'paths.json'));

    Map<String, dynamic> paths = {
      'input': widget.input ?? '',
      'output': widget.output ?? '',
      'scriptPath': widget.scriptPath ?? '',
      'savePaths': checkboxValue,
    };

    await settingsFile.writeAsString(jsonEncode(paths));
  }

  @override
  Widget build(BuildContext context) {
    bool isCheckboxEnabled =
        widget.input?.isNotEmpty == true && widget.output?.isNotEmpty == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (!isCheckboxEnabled) {
              return const Color.fromARGB(246, 78, 75, 75);
            }
            return checkboxValue
                ? const Color.fromRGBO(0, 255, 0, 1.0)
                : const Color.fromARGB(246, 0, 0, 0);
          }),
          value: checkboxValue,
          onChanged: isCheckboxEnabled
              ? (bool? newValue) {
                  setState(() {
                    checkboxValue = newValue ?? false;
                    widget.onCheckboxChanged(checkboxValue);
                    if (checkboxValue) {
                      savePathsToJson();
                    }
                  });
                }
              : null,
        ),
        Text(
          checkboxValue ? 'Paths currently saved' : 'Save paths for future',
        ),
      ],
    );
  }
}
