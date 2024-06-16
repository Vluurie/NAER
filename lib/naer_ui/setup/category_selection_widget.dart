import 'package:NAER/data/boss_data/nier_boss_class_list.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorySelection extends StatefulWidget {
  const CategorySelection({super.key});

  @override
  State<CategorySelection> createState() => CategorySelectionState();
}

class CategorySelectionState extends State<CategorySelection> {
  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);
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
              activeColor: Colors.blue,
              checkColor: Colors.white,
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
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent[800],
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
            height: 320,
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
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: globalState.categories[item.id] ?? false,
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
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
  final globalState = Provider.of<GlobalState>(context, listen: false);
  List<dynamic> allItems = GlobalState().getAllItems();
  for (var item in allItems.where((item) => item.runtimeType == type)) {
    globalState.categories[item.id] = value;
  }
}

String getSelectedBossesNames() {
  List<String> selectedBosses = bossList
      .where((boss) => boss.isSelected)
      .map((boss) => boss.name)
      .toList();
  return selectedBosses.join(',');
}
