import 'package:NAER/naer_ui/directory_ui/savepath_checkbox.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PathCheckBoxWidget extends ConsumerWidget {
  const PathCheckBoxWidget({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final loadPathsFuture = ref.watch(loadPathsFromSharedPreferencesProvider);

    return loadPathsFuture.when(
      data: (final isLoaded) {
        return SavePathsWidget(
          onCheckboxChanged: (final bool value) async {
            if (!value) {
              await clearPathsFromSharedPreferences();
              ref.read(globalStateProvider.notifier).clearSavePaths();
              ref
                  .read(globalStateProvider.notifier)
                  .setIsPanelVisible(isPanelVisible: false);
            }
            ref
                .read(globalStateProvider.notifier)
                .updateSavePaths(newSavePaths: value);
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (final err, final stack) => Text('Error: $err'),
    );
  }

  Future<void> clearPathsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('input');
    await prefs.remove('output');
    await prefs.setBool('savePaths', false);
  }
}
