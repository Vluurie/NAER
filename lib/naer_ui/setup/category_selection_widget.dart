// ignore_for_file: avoid_positional_boolean_parameters

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
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      final globalStateNotifier = ref.read(globalStateProvider.notifier);
      globalStateNotifier.updateCategories();
    });
  }

  @override
  Widget build(final BuildContext context) {
    final globalStateNotifier = ref.read(globalStateProvider.notifier);
    final categories = ref.watch(globalStateProvider).categories;

    Widget specialCheckbox(final String title, final bool value,
        final void Function(bool?) onChanged) {
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

    IconData getIconForItem(final dynamic item) {
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
            (final newValue) {
              globalStateNotifier.setSelectAllQuests(
                  selectAllQuests: newValue!);
              updateItemsByType(SideQuest, ref, checkAllItems: newValue);
              globalStateNotifier.updateCategories();
            },
          ),
          specialCheckbox(
            "All Maps",
            globalStateNotifier.readSelectAllMaps(),
            (final newValue) {
              globalStateNotifier.setSelectAllMaps(selectAllMaps: newValue!);
              updateItemsByType(MapLocation, ref, checkAllItems: newValue);
              globalStateNotifier.updateCategories();
            },
          ),
          specialCheckbox(
            "All Phases",
            globalStateNotifier.readSelectAllPhases(),
            (final newValue) {
              globalStateNotifier.setSelectAllPhases(
                  selectAllPhases: newValue!);
              updateItemsByType(ScriptingPhase, ref, checkAllItems: newValue);
              globalStateNotifier.updateCategories();
            },
          ),
          SizedBox(
            height: 375,
            child: SingleChildScrollView(
              child: Column(
                children: globalStateNotifier.getAllItems().map((final item) {
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
                          onChanged: (final bool? newValue) {
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

Future<void> updateItemsByType(final Type type, final WidgetRef ref,
    {required final bool checkAllItems}) async {
  final globalStateNotifier = ref.read(globalStateProvider.notifier);
  List<dynamic> allItems = globalStateNotifier.getAllItems();
  final modifiableCategories = Map.of(globalStateNotifier.readCategories());

  for (var item in allItems.where((final item) => item.runtimeType == type)) {
    modifiableCategories[item.id] = checkAllItems;
  }

  globalStateNotifier.setCategories(modifiableCategories);
  globalStateNotifier.updateCategories();
}

String getSelectedEnemiesNames(final WidgetRef ref) {
  List<String> selectedEnemies = EnemyList.getDLCFilteredEnemies(ref)
      .where((final enemy) => enemy.isSelected)
      .map((final enemy) => enemy.name)
      .toList();
  return selectedEnemies.join(',');
}
