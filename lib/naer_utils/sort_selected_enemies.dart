import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats_list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_utils/state_provider/selected_enemy_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<Map<String, List<String>>> sortSelectedEnemiesState(
    List<String> selectedImages, WidgetRef ref) async {
  final globalState = ref.watch(globalStateProvider);
  var enemyGroups =
      SortedEnemyGroup.getDLCFilteredEnemyData(globalState.hasDLC);

  var formattedSelectedImages =
      selectedImages.map((image) => image.split('.').first).toList();

  var sortedSelection = {
    "Ground": <String>[],
    "Fly": <String>[],
    "Delete": List<String>.from(enemyGroups["Delete"] ?? [])
  };

  for (var enemy in formattedSelectedImages) {
    bool found = false;
    for (var group in ["Ground", "Fly"]) {
      if (enemyGroups[group]?.contains(enemy) ?? false) {
        sortedSelection[group]?.add(enemy);
        found = true;
        break;
      }
    }
    if (!found) {
      sortedSelection["Delete"]?.add(enemy);
    }
  }

  ref
      .read(sortedEnemyDataProvider.notifier)
      .updateSelectedEnemies(sortedSelection);

  // Return the sorted map
  return sortedSelection;
}

String getSelectedEnemiesArgument(WidgetRef ref) {
  List<List<String>> selectedEnemies = EnemyList.getDLCFilteredEnemies(ref)
      .where((enemy) => enemy.isSelected)
      .map((enemy) => enemy.emIdentifiers)
      .toList();
  return selectedEnemies.join(',');
}
