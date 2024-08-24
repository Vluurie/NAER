import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';

final checkboxValueProvider = StateProvider<bool>((ref) => false);

class SavePathsWidget extends ConsumerWidget {
  final Function(bool) onCheckboxChanged;

  const SavePathsWidget({
    super.key,
    required this.onCheckboxChanged,
  });

  Future<void> savePathsToPreferences(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final checkboxValue = ref.read(checkboxValueProvider);

    final globalState = ref.read(globalStateProvider);
    await prefs.setString('input', globalState.input);
    await prefs.setString('output', globalState.specialDatOutputPath);
    await prefs.setBool('savePaths', checkboxValue);
  }

  Future<void> clearPathsFromPreferences(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('input');
    await prefs.remove('output');
    await prefs.setBool('savePaths', false);

    ref.read(globalStateProvider.notifier).clearPaths();
    ref.read(checkboxValueProvider.notifier).state = false;
    onCheckboxChanged(false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    final checkboxValue = ref.watch(checkboxValueProvider);

    bool isCheckboxEnabled = globalState.input.isNotEmpty &&
        globalState.specialDatOutputPath.isNotEmpty;

    Future.microtask(() {
      if (isCheckboxEnabled && !checkboxValue) {
        ref.read(checkboxValueProvider.notifier).state = true;
        onCheckboxChanged(true);
        savePathsToPreferences(ref);
      } else if (!isCheckboxEnabled && checkboxValue) {
        clearPathsFromPreferences(ref);
      }
    });

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
                    if (newValue != null) {
                      ref.read(checkboxValueProvider.notifier).state = newValue;
                      onCheckboxChanged(newValue);

                      if (newValue) {
                        await savePathsToPreferences(ref);
                      } else {
                        await clearPathsFromPreferences(ref);
                      }
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
