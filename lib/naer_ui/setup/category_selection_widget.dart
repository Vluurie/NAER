import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats_list.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategorySelection extends ConsumerStatefulWidget {
  const CategorySelection({super.key});

  @override
  ConsumerState<CategorySelection> createState() => CategorySelectionState();
}

class CategorySelectionState extends ConsumerState<CategorySelection> {
  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);

    Widget specialCheckbox(
        String title, bool value, void Function(bool?) onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: AutomatoThemeColors.textColor(ref), fontSize: 16),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AutomatoThemeColors.primaryColor(ref),
              checkColor: AutomatoThemeColors.darkBrown(ref),
            ),
          ],
        ),
      );
    }

    IconData getIconForItem(dynamic item) {
      if (item is MapLocation) {
        return Icons.map;
      } else if (item is SideQuest) {
        return Icons.question_answer;
      } else if (item is ScriptingPhase) {
        return Icons.timeline;
      }
      return Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AutomatoThemeColors.brown25(ref),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Select Categories for Randomization",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AutomatoThemeColors.textColor(ref),
              ),
            ),
          ),
          specialCheckbox(
            "All Quests",
            globalState.selectAllQuests,
            (newValue) {
              setState(() {
                globalState.selectAllQuests = newValue!;
                updateItemsByType(SideQuest, newValue, ref);
              });
            },
          ),
          specialCheckbox(
            "All Maps",
            globalState.selectAllMaps,
            (newValue) {
              setState(() {
                globalState.selectAllMaps = newValue!;
                updateItemsByType(MapLocation, newValue, ref);
              });
            },
          ),
          specialCheckbox(
            "All Phases",
            globalState.selectAllPhases,
            (newValue) {
              setState(() {
                globalState.selectAllPhases = newValue!;
                updateItemsByType(ScriptingPhase, newValue, ref);
              });
            },
          ),
          SizedBox(
            height: 375,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: globalState.getAllItems().map((item) {
                  IconData icon = getIconForItem(item);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(icon,
                          color: AutomatoThemeColors.textColor(ref), size: 28),
                      title: Text(
                        item.description,
                        style: TextStyle(
                            color: AutomatoThemeColors.textColor(ref),
                            fontSize: 14),
                      ),
                      trailing: Transform.scale(
                        scale: 1,
                        child: Checkbox(
                          value: globalState.categories[item.id] ??
                              (item.dlc == true ? globalState.hasDLC : false),
                          activeColor: AutomatoThemeColors.primaryColor(ref),
                          checkColor: AutomatoThemeColors.darkBrown(ref),
                          onChanged: (bool? newValue) {
                            setState(() {
                              globalState.categories[item.id] = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void updateItemsByType(Type type, bool value, WidgetRef ref) {
  final globalState = ref.read(globalStateProvider);
  List<dynamic> allItems = globalState.getAllItems();
  for (var item in allItems.where((item) => item.runtimeType == type)) {
    globalState.categories[item.id] = value;
  }
}

String getSelectedEnemiesNames(WidgetRef ref) {
  List<String> selectedEnemies = EnemyList.getDLCFilteredEnemies(ref)
      .where((enemy) => enemy.isSelected)
      .map((enemy) => enemy.name)
      .toList();
  return selectedEnemies.join(',');
}
