import 'package:NAER/naer_ui/setup/category_selection_widget.dart';
import 'package:NAER/naer_ui/setup/enemy_level_selection_widget.dart';
import 'package:NAER/naer_ui/setup/enemy_stats_selection_widget.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget setupAllSelections(BuildContext context, WidgetRef ref) {
  final globalState = ref.watch(globalStateProvider.notifier);
  Map<String, bool> levelMap = globalState.readLevelMap();
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AutomatoThemeColors.brown25(ref),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const SingleChildScrollView(
              child: EnemyLevelSelection(),
            ),
          ),
        ),
        if (levelMap['All Enemies without Randomization'] == false)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AutomatoThemeColors.brown25(ref),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const SingleChildScrollView(
                child: CategorySelection(),
              ),
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AutomatoThemeColors.brown25(ref),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const SingleChildScrollView(
              child: EnemyStatsSelection(),
            ),
          ),
        ),
      ],
    ),
  );
}
