import 'package:NAER/data/boss_data/nier_boss_class_list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart' as enemy_data;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<Map<String, List<String>>> readEnemyData() async {
  return enemy_data.enemyData;
}

Future<Map<String, List<String>>> sortSelectedEnemies(
    List<String> selectedImages, BuildContext context) async {
  final globalState = Provider.of<GlobalState>(context);
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

String getSelectedBossesArgument() {
  List<List<String>> selectedBosses = bossList
      .where((boss) => boss.isSelected)
      .map((boss) => boss.emIdentifiers)
      .toList();
  return selectedBosses.join(',');
}
