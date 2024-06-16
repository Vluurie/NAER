import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnemyLevelSelection extends StatefulWidget {
  const EnemyLevelSelection({super.key});

  @override
  State<EnemyLevelSelection> createState() => _EnemyLevelSelectionState();
}

class _EnemyLevelSelectionState extends State<EnemyLevelSelection> {
  IconData getIconForLevel(String levelEnemy) {
    switch (levelEnemy) {
      case "All Enemies":
        return Icons.emoji_events;
      case "All Enemies without Randomization":
        return Icons.emoji_flags_outlined;
      // case "Only Bosses":
      //   return Icons.emoji_emotions_rounded;
      // case "Only Selected Enemies":
      //   return Icons.radio_button_checked;
      case "None":
        return Icons.not_interested;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);
    return Align(
        alignment: Alignment.topRight,
        child: Container(
          padding:
              const EdgeInsets.only(top: 30, bottom: 5, right: 30, left: 30),
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
                  "Select if you want to change the Enemies Levels.",
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
                    if (globalState.level['None'] == false)
                      Text(
                        "Enemy Level: ${globalState.enemyLevel}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    if (globalState.level['None'] == false)
                      Slider(
                        activeColor: const Color.fromRGBO(0, 255, 255, 1),
                        value: globalState.enemyLevel.toDouble(),
                        min: 1,
                        max: 99,
                        divisions: 98,
                        label: globalState.enemyLevel.toString(),
                        onChanged: (double newValue) {
                          setState(() {
                            globalState.enemyLevel = newValue.round();
                          });
                        },
                      ),
                  ],
                ),
              ),
              ...globalState.level.keys.map((levelKey) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CheckboxListTile(
                    title: Text(
                      levelKey,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    value: globalState.level[levelKey],
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue == true ||
                            globalState.level.values.every((v) => v == false)) {
                          globalState.level.updateAll((key, value) => false);
                          globalState.level[levelKey] = newValue!;
                        }
                      });
                    },
                    secondary: Icon(getIconForLevel(levelKey),
                        color: Colors.white, size: 28),
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              }),
            ],
          ),
        ));
  }
}
