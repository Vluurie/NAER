import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnemyLevelSelection extends ConsumerStatefulWidget {
  const EnemyLevelSelection({super.key});

  @override
  ConsumerState<EnemyLevelSelection> createState() =>
      _EnemyLevelSelectionState();
}

class _EnemyLevelSelectionState extends ConsumerState<EnemyLevelSelection> {
  IconData getIconForLevel(String levelEnemy) {
    switch (levelEnemy) {
      case "All Enemies":
        return Icons.emoji_events;
      case "All Enemies without Randomization":
        return Icons.emoji_flags_outlined;
      case "None":
        return Icons.not_interested;
      default:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.only(top: 30, bottom: 5, right: 30, left: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                "Select if you want to change the Enemies Levels.",
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
                  if (globalState.level['None'] == false)
                    Text(
                      "Enemy Level: ${globalState.enemyLevel}",
                      style: TextStyle(
                        color: AutomatoThemeColors.textColor(ref),
                        fontSize: 16,
                      ),
                    ),
                  if (globalState.level['None'] == false)
                    Slider(
                      activeColor: AutomatoThemeColors.primaryColor(ref),
                      value: globalState.enemyLevel.toDouble(),
                      min: 1,
                      max: 99,
                      divisions: 98,
                      label: globalState.enemyLevel.toString(),
                      onChanged: (double newValue) {
                        ref
                            .read(globalStateProvider.notifier)
                            .updateEnemyLevel(newValue.round());
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
                    style: TextStyle(
                      color: AutomatoThemeColors.textColor(ref),
                      fontSize: 16,
                    ),
                  ),
                  value: globalState.level[levelKey],
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      ref
                          .read(globalStateProvider.notifier)
                          .updateLevel(levelKey, newValue);
                    }
                  },
                  secondary: Icon(getIconForLevel(levelKey),
                      color: AutomatoThemeColors.textColor(ref), size: 28),
                  activeColor: AutomatoThemeColors.primaryColor(ref),
                  checkColor: AutomatoThemeColors.darkBrown(ref),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
