import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    required this.savePaths,
    required this.onCheckboxChanged,
  });

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

  Future<void> savePathsToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('input', widget.input ?? '');
    await prefs.setString('output', widget.output ?? '');
    await prefs.setString('scriptPath', widget.scriptPath ?? '');
    await prefs.setBool('savePaths', checkboxValue);
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
                      savePathsToPreferences(); // Updated method name here
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
