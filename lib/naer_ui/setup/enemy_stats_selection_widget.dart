import 'package:NAER/data/enemy_lists_data/nier_all_em_for_stats__list.dart';
import 'package:NAER/naer_ui/animations/shacke_animation_widget.dart';
import 'package:NAER/naer_ui/other/shacking_message_list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

class EnemyStatsSelection extends ConsumerStatefulWidget {
  const EnemyStatsSelection({super.key});

  @override
  EnemyStatsSelectionState createState() => EnemyStatsSelectionState();
}

class EnemyStatsSelectionState extends ConsumerState<EnemyStatsSelection> {
  String getSelectedEnemiesArgument() {
    List<List<String>> selectedEnemies = allEmForStatsChangeList
        .where((enemy) => enemy.isSelected)
        .map((enemy) => enemy.emIdentifiers)
        .toList();
    return selectedEnemies.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final globalState = provider.Provider.of<GlobalState>(context);
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Adjust Enemy Stats.",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                        style: const TextStyle(
                          color: Colors.white,
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
                          color: Color.lerp(const Color.fromARGB(0, 41, 39, 39),
                                  Colors.red, globalState.enemyStats / 5.0)!
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
                              setState(() {
                                globalState.enemyStats = newValue;
                              });
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
                  title: const Text(
                    "Select All",
                    textScaler: TextScaler.linear(0.8),
                  ),
                  value: globalState.stats["Select All"],
                  onChanged: (bool? value) {
                    setState(() {
                      globalState.stats["Select All"] = value ?? false;
                      globalState.stats["None"] = !value!;
                      for (var enemy in allEmForStatsChangeList) {
                        enemy.isSelected = value;
                      }
                      getSelectedEnemiesArgument();
                    });
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  tristate: false,
                  activeColor: const Color.fromARGB(255, 209, 18, 18),
                  title: const Text("None", textScaler: TextScaler.linear(0.8)),
                  value: globalState.stats["None"],
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true || !globalState.stats["Select All"]!) {
                        globalState.stats["None"] = true;
                        for (var enemy in allEmForStatsChangeList) {
                          enemy.isSelected = false;
                        }
                        getSelectedEnemiesArgument();
                      }
                      globalState.stats["Select All"] = false;
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
                      children:
                          allEmForStatsChangeList.asMap().entries.map((entry) {
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
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: enemy.isSelected,
                            onChanged: (bool? newValue) {
                              setState(() {
                                enemy.isSelected = newValue ?? false;
                                globalState.stats["Select All"] =
                                    allEmForStatsChangeList
                                        .every((b) => b.isSelected);
                                globalState.stats["None"] =
                                    allEmForStatsChangeList
                                        .every((b) => !b.isSelected);
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
