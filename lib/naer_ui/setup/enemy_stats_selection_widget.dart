import 'package:NAER/data/boss_data/nier_boss_class_list.dart';
import 'package:NAER/naer_ui/animations/shacke_animation_widget.dart';
import 'package:NAER/naer_ui/other/shacking_message_list.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnemyStatsSelection extends StatefulWidget {
  const EnemyStatsSelection({super.key});

  @override
  EnemyStatsSelectionState createState() => EnemyStatsSelectionState();
}

class EnemyStatsSelectionState extends State<EnemyStatsSelection> {
  String getSelectedBossesArgument() {
    List<List<String>> selectedBosses = bossList
        .where((boss) => boss.isSelected)
        .map((boss) => boss.emIdentifiers)
        .toList();
    return selectedBosses.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);
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
              "Adjust Boss Stats.",
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
                        "Boss Stats: ${globalState.enemyStats.toStringAsFixed(1)}",
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
                            activeColor: Color.lerp(Colors.cyan, Colors.red,
                                globalState.enemyStats / 5.0),
                            value: globalState.enemyStats,
                            min: 0.0,
                            max: 5.0,
                            divisions: 50,
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
                  activeColor: const Color.fromARGB(255, 18, 180, 209),
                  title: const Text(
                    "Select All",
                    textScaler: TextScaler.linear(0.8),
                  ),
                  value: globalState.stats["Select All"],
                  onChanged: (bool? value) {
                    setState(() {
                      globalState.stats["Select All"] = value ?? false;
                      globalState.stats["None"] = !value!;
                      for (var boss in bossList) {
                        boss.isSelected = value;
                      }
                      getSelectedBossesArgument();
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
                        for (var boss in bossList) {
                          boss.isSelected = false;
                        }
                        getSelectedBossesArgument();
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
                      children: bossList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var boss = entry.value;
                        final GlobalKey<ShakeAnimationWidgetState> shakeKey =
                            GlobalKey<ShakeAnimationWidgetState>();

                        double scale = boss.isSelected
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
                                child: Image.asset(boss.imageUrl),
                              ),
                            ),
                          ),
                          title: Text(
                            boss.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          trailing: Checkbox(
                            value: boss.isSelected,
                            onChanged: (bool? newValue) {
                              setState(() {
                                boss.isSelected = newValue ?? false;
                                globalState.stats["Select All"] =
                                    bossList.every((b) => b.isSelected);
                                globalState.stats["None"] =
                                    bossList.every((b) => !b.isSelected);
                              });
                              getSelectedBossesArgument();
                            },
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
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
