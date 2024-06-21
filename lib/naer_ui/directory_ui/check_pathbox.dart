import 'package:flutter/material.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';
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
  SavePathsWidgetState createState() => SavePathsWidgetState();
}

class SavePathsWidgetState extends State<SavePathsWidget> {
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

  Future<void> clearPathsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('input');
    await prefs.remove('output');
    await prefs.remove('scriptPath');
    await prefs.setBool('savePaths', false);
    setState(() {
      checkboxValue = false;
      widget.onCheckboxChanged(checkboxValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isCheckboxEnabled =
        widget.input?.isNotEmpty == true && widget.output?.isNotEmpty == true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Checkbox(
          fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (!isCheckboxEnabled) {
              return const Color.fromARGB(246, 78, 75, 75);
            }
            return checkboxValue
                ? AutomatoThemeColors.saveZone(context)
                : AutomatoThemeColors.darkBrown(context);
          }),
          value: checkboxValue,
          onChanged: isCheckboxEnabled
              ? (bool? newValue) async {
                  setState(() {
                    checkboxValue = newValue ?? false;
                    widget.onCheckboxChanged(checkboxValue);
                  });
                  if (checkboxValue) {
                    await savePathsToPreferences();
                  } else {
                    await clearPathsFromPreferences();
                  }
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
