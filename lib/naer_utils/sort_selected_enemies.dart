import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats__list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Map<String, List<String>>> readEnemyData() async {
  return SortedEnemyGroup.enemyData;
}

Future<Map<String, List<String>>> sortSelectedEnemies(
    List<String> selectedImages, BuildContext context) async {
  final globalState = Provider.of<GlobalState>(context, listen: false);
  List<String>? selectedImages =
      globalState.enemyImageGridKey.currentState?.selectedImages;
  var enemyGroups = await readEnemyData();

  var formattedSelectedImages =
      selectedImages!.map((image) => image.split('.').first).toList();

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
    if (!found) {}
  }

  return sortedSelection;
}

String getSelectedEnemiesArgument() {
  List<List<String>> selectedEnemies = allEmForStatsChangeList
      .where((enemy) => enemy.isSelected)
      .map((enemy) => enemy.emIdentifiers)
      .toList();
  return selectedEnemies.join(',');
}
