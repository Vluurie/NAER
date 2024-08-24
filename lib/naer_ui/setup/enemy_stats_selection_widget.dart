import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats_list.dart';
import 'package:NAER/naer_ui/animations/shacke_animation_widget.dart';
import 'package:NAER/naer_ui/other/shacking_message_list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnemyStatsSelection extends ConsumerStatefulWidget {
  const EnemyStatsSelection({super.key});

  @override
  EnemyStatsSelectionState createState() => EnemyStatsSelectionState();
}

class EnemyStatsSelectionState extends ConsumerState<EnemyStatsSelection> {
  String getSelectedEnemiesArgument() {
    List<List<String>> selectedEnemies = EnemyList.getDLCFilteredEnemies(ref)
        .where((enemy) => enemy.isSelected)
        .map((enemy) => enemy.emIdentifiers)
        .toList();
    return selectedEnemies.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);
    final globalStateNotifier = ref.read(globalStateProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Adjust Enemy Stats.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AutomatoThemeColors.textColor(ref),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !globalState.stats["None"]!
                    ? Text(
                        "Enemy Stats Multiplier - ${globalState.enemyStats.toStringAsFixed(1)}",
                        style: TextStyle(
                          color: AutomatoThemeColors.textColor(ref),
                          fontSize: 16,
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                                  const Color.fromARGB(0, 41, 39, 39),
                                  AutomatoThemeColors.dangerZone(ref),
                                  globalState.enemyStats / 5.0)!
                              .withOpacity(0.1),
                          blurRadius:
                              10.0 + (globalState.enemyStats / 5.0) * 10.0,
                          spreadRadius: (globalState.enemyStats / 5.0) * 5.0,
                        ),
                      ],
                    ),
                    child: !globalState.stats["None"]!
                        ? Slider(
                            activeColor: Color.lerp(
                                AutomatoThemeColors.primaryColor(ref),
                                AutomatoThemeColors.dangerZone(ref),
                                globalState.enemyStats / 5.0),
                            value: globalState.enemyStats,
                            min: 0.0,
                            max: 5.0,
                            label: globalState.enemyStats.toStringAsFixed(1),
                            onChanged: (double newValue) {
                              globalStateNotifier.updateEnemyStats(newValue);
                            },
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CheckboxListTile(
                  activeColor: AutomatoThemeColors.primaryColor(ref),
                  title: Text(
                    "Select All",
                    style: TextStyle(color: AutomatoThemeColors.textColor(ref)),
                  ),
                  value: globalState.stats["Select All"],
                  onChanged: (bool? value) {
                    setState(() {
                      // Create a mutable copy of stats
                      final updatedStats =
                          Map<String, bool>.from(globalState.stats);
                      updatedStats["Select All"] = value ?? false;
                      updatedStats["None"] = !value!;
                      for (var enemy in EnemyList.getDLCFilteredEnemies(ref)) {
                        enemy.isSelected = value;
                      }
                      // Update the state with the new stats map
                      globalStateNotifier.setStats(updatedStats);
                      getSelectedEnemiesArgument();
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  tristate: false,
                  activeColor: AutomatoThemeColors.dangerZone(ref),
                  title: Text("None",
                      style:
                          TextStyle(color: AutomatoThemeColors.textColor(ref))),
                  value: globalState.stats["None"],
                  onChanged: (bool? value) {
                    setState(() {
                      // Create a mutable copy of stats
                      final updatedStats =
                          Map<String, bool>.from(globalState.stats);
                      if (value == true || !globalState.stats["Select All"]!) {
                        updatedStats["None"] = true;
                        for (var enemy
                            in EnemyList.getDLCFilteredEnemies(ref)) {
                          enemy.isSelected = false;
                        }
                        getSelectedEnemiesArgument();
                      }
                      updatedStats["Select All"] = false;
                      // Update the state with the new stats map
                      globalStateNotifier.setStats(updatedStats);
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                const Scrollbar(
                  trackVisibility: true,
                  child: SizedBox(width: 10),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: EnemyList.getDLCFilteredEnemies(ref)
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        var enemy = entry.value;
                        final GlobalKey<ShakeAnimationWidgetState> shakeKey =
                            GlobalKey<ShakeAnimationWidgetState>();

                        double scale = enemy.isSelected
                            ? 1.0 + 0.5 * (globalState.enemyStats / 5.0)
                            : 1.0;

                        return ListTile(
                          leading: GestureDetector(
                            onTap: () => shakeKey.currentState?.shake(),
                            child: Transform.scale(
                              scale: scale,
                              child: ShakeAnimationWidget(
                                key: shakeKey,
                                message: index < messages.length
                                    ? messages[index]
                                    : "",
                                onEnd: () {},
                                child: Image.asset(enemy.imageUrl),
                              ),
                            ),
                          ),
                          title: Text(
                            enemy.name,
                            style: TextStyle(
                                color: AutomatoThemeColors.textColor(ref),
                                fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: enemy.isSelected,
                            onChanged: (bool? newValue) {
                              setState(() {
                                enemy.isSelected = newValue ?? false;
                                final updatedStats =
                                    Map<String, bool>.from(globalState.stats);
                                updatedStats["Select All"] =
                                    EnemyList.getDLCFilteredEnemies(ref)
                                        .every((b) => b.isSelected);
                                updatedStats["None"] =
                                    EnemyList.getDLCFilteredEnemies(ref)
                                        .every((b) => !b.isSelected);
                                globalStateNotifier.setStats(updatedStats);
                              });
                              getSelectedEnemiesArgument();
                            },
                            activeColor: AutomatoThemeColors.primaryColor(ref),
                            checkColor: AutomatoThemeColors.darkBrown(ref),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
