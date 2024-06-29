import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats__list.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

class CategorySelection extends ConsumerStatefulWidget {
  const CategorySelection({super.key});

  @override
  ConsumerState<CategorySelection> createState() => CategorySelectionState();
}

class CategorySelectionState extends ConsumerState<CategorySelection> {
  @override
  Widget build(BuildContext context) {
    final globalState = provider.Provider.of<GlobalState>(context);
    Widget specialCheckbox(
        String title, bool value, void Function(bool?) onChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Select Categories for Randomization",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          specialCheckbox(
            "All Quests",
            globalState.selectAllQuests,
            (newValue) {
              setState(() {
                globalState.selectAllQuests = newValue!;
                updateItemsByType(SideQuest, newValue, context);
              });
            },
          ),
          specialCheckbox(
            "All Maps",
            globalState.selectAllMaps,
            (newValue) {
              setState(() {
                globalState.selectAllMaps = newValue!;
                updateItemsByType(MapLocation, newValue, context);
              });
            },
          ),
          specialCheckbox(
            "All Phases",
            globalState.selectAllPhases,
            (newValue) {
              setState(() {
                globalState.selectAllPhases = newValue!;
                updateItemsByType(ScriptingPhase, newValue, context);
              });
            },
          ),
          SizedBox(
            height: 375,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: GlobalState().getAllItems().map((item) {
                  IconData icon = getIconForItem(item);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(icon, color: Colors.white, size: 28),
                      title: Text(
                        item.description,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      trailing: Transform.scale(
                        scale: 1,
                        child: Checkbox(
                          value: globalState.categories[item.id] ?? false,
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

void updateItemsByType(Type type, bool value, BuildContext context) {
  final globalState = provider.Provider.of<GlobalState>(context, listen: false);
  List<dynamic> allItems = GlobalState().getAllItems();
  for (var item in allItems.where((item) => item.runtimeType == type)) {
    globalState.categories[item.id] = value;
  }
}

String getSelectedEnemiesNames() {
  List<String> selectedEnemies = allEmForStatsChangeList
      .where((enemy) => enemy.isSelected)
      .map((enemy) => enemy.name)
      .toList();
  return selectedEnemies.join(',');
}
