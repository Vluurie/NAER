import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DLCCheckBox extends ConsumerStatefulWidget {
  const DLCCheckBox({super.key});

  @override
  DLCCheckBoxState createState() => DLCCheckBoxState();
}

class DLCCheckBoxState extends ConsumerState<DLCCheckBox> {
  late Future<void> _loadDLCOptionFuture;

  @override
  void initState() {
    super.initState();
    _loadDLCOptionFuture = loadDLCOption();
  }

  Future<void> loadDLCOption() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedValue = prefs.getBool('dlc');
    if (savedValue != null) {
      ref.watch(globalStateProvider.notifier).updateDLCOption(savedValue);
    }
  }

  Future<void> _saveDLCOption(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dlc', value);
    ref.watch(globalStateProvider.notifier).updateDLCOption(value);
  }

  @override
  Widget build(BuildContext context) {
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final globalState = ref.watch(globalStateProvider);

    return FutureBuilder<void>(
      future: _loadDLCOptionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading DLC option');
        } else {
          return AutomatoCheckBox(
            initialValue: globalState.hasDLC,
            textColorUnchecked: AutomatoThemeColors.primaryColor(ref),
            onChanged: (bool? newValue) async {
              final updatedValue = newValue ?? false;
              await _saveDLCOption(updatedValue);
              globalStateNotifier.updateCategories();
            },
            text: globalState.hasDLC ? 'DLC: Enabled' : 'DLC: Disabled',
          );
        }
      },
    );
  }
}
