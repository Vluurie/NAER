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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalStateNotifier = ref.read(globalStateProvider.notifier);
      globalStateNotifier.updateCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalStateNotifier = ref.read(globalStateProvider.notifier);
    final categories = ref.watch(globalStateProvider).categories;

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
              "Select Categories for Modification",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AutomatoThemeColors.textColor(ref),
              ),
            ),
          ),
          specialCheckbox(
            "All Quests",
            globalStateNotifier.readSelectAllQuests(),
            (newValue) {
              globalStateNotifier.setSelectAllQuests(newValue!);
              updateItemsByType(SideQuest, newValue, ref);
              globalStateNotifier.updateCategories();
            },
          ),
          specialCheckbox(
            "All Maps",
            globalStateNotifier.readSelectAllMaps(),
            (newValue) {
              globalStateNotifier.setSelectAllMaps(newValue!);
              updateItemsByType(MapLocation, newValue, ref);
              globalStateNotifier.updateCategories();
            },
          ),
          specialCheckbox(
            "All Phases",
            globalStateNotifier.readSelectAllPhases(),
            (newValue) {
              globalStateNotifier.setSelectAllPhases(newValue!);
              updateItemsByType(ScriptingPhase, newValue, ref);
              globalStateNotifier.updateCategories();
            },
          ),
          SizedBox(
            height: 375,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: globalStateNotifier.getAllItems().map((item) {
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
                          value: categories[item.id] ??
                              (item.dlc == true
                                  ? globalStateNotifier.readHasDLC()
                                  : false),
                          activeColor: AutomatoThemeColors.primaryColor(ref),
                          checkColor: AutomatoThemeColors.darkBrown(ref),
                          onChanged: (bool? newValue) {
                            final modifiableCategories = Map.of(categories);
                            modifiableCategories[item.id] = newValue!;
                            globalStateNotifier
                                .setCategories(modifiableCategories);
                            globalStateNotifier.updateCategories();
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

Future<void> updateItemsByType(Type type, bool value, WidgetRef ref) async {
  final globalStateNotifier = ref.read(globalStateProvider.notifier);
  List<dynamic> allItems = globalStateNotifier.getAllItems();
  final modifiableCategories = Map.of(globalStateNotifier.readCategories());

  for (var item in allItems.where((item) => item.runtimeType == type)) {
    modifiableCategories[item.id] = value;
  }

  globalStateNotifier.setCategories(modifiableCategories);
  globalStateNotifier.updateCategories();
}

String getSelectedEnemiesNames(WidgetRef ref) {
  List<String> selectedEnemies = EnemyList.getDLCFilteredEnemies(ref)
      .where((enemy) => enemy.isSelected)
      .map((enemy) => enemy.name)
      .toList();
  return selectedEnemies.join(',');
}
