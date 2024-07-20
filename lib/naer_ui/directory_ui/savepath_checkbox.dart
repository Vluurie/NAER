import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavePathsWidget extends ConsumerStatefulWidget {
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

class SavePathsWidgetState extends ConsumerState<SavePathsWidget> {
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
    await prefs.setBool('savePaths', checkboxValue);
  }

  Future<void> clearPathsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('input');
    await prefs.remove('output');
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

    return Container(
      decoration: BoxDecoration(
        color: AutomatoThemeColors.darkBrown(ref),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(right: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (!isCheckboxEnabled) {
                return AutomatoThemeColors.dangerZone(ref);
              }
              return checkboxValue
                  ? AutomatoThemeColors.saveZone(ref)
                  : AutomatoThemeColors.darkBrown(ref);
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
            checkboxValue ? 'Paths are saved.' : 'Paths not saved!',
            style: checkboxValue
                ? TextStyle(color: AutomatoThemeColors.primaryColor(ref))
                : TextStyle(color: AutomatoThemeColors.dangerZone(ref)),
          ),
        ],
      ),
    );
  }
}
