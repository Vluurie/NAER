import 'package:NAER/naer_ui/setup/category_selection_widget.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Widget> generateModificationDetails(final WidgetRef ref) {
  final globalState = ref.watch(globalStateProvider);
  List<Widget> details = [];

  String enemyList = getSelectedEnemiesNames(ref);
  String categoryDetail = globalState.levelMap.entries
      .firstWhere((final entry) => entry.value,
          orElse: () => const MapEntry("None", false))
      .key;

  // DLC
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.extension,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("DLC enabled:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: Text(
            globalState.hasDLC ? "Yes" : "No",
            style: TextStyle(
                fontSize: 16, color: AutomatoThemeColors.textDialogColor(ref)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Category
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Level Category Selected:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: Text(categoryDetail,
              style: TextStyle(
                  fontSize: 16,
                  color: AutomatoThemeColors.textDialogColor(ref))),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Change Level
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.change_circle,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Change all Enemy Level to:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: Text(
            categoryDetail == 'None' ? "None" : "${globalState.enemyLevel}",
            style: TextStyle(
                fontSize: 16, color: AutomatoThemeColors.textDialogColor(ref)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Change Enemy Stats
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Change Enemy Stats:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: enemyList.isNotEmpty && globalState.enemyStats != 0.0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Multiplier: x${globalState.enemyStats}",
                        style: TextStyle(
                            fontSize: 16,
                            color: AutomatoThemeColors.textDialogColor(ref))),
                    const SizedBox(height: 5),
                    Text("Affected Enemies:",
                        style: TextStyle(
                            fontSize: 16,
                            color: AutomatoThemeColors.textDialogColor(ref))),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: enemyList
                          .split(',')
                          .map((final enemy) => Text("- $enemy",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AutomatoThemeColors.textDialogColor(
                                      ref))))
                          .toList(),
                    ),
                  ],
                )
              : Text("None",
                  style: TextStyle(
                      fontSize: 16,
                      color: AutomatoThemeColors.textDialogColor(ref))),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Selected Enemies
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.group,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Selected Enemies:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: globalState.selectedImages.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: globalState.selectedImages
                          .map((final image) => Text("- $image",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AutomatoThemeColors.textDialogColor(
                                      ref))))
                          .toList(),
                    ),
                  ],
                )
              : Text(
                  "No Enemy selected, will use ALL Enemies for Randomization",
                  style: TextStyle(
                      fontSize: 16,
                      color: AutomatoThemeColors.textDialogColor(ref))),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Level Change Details
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.details,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Enemy modification:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: Text(
            categoryDetail == 'All Enemies'
                ? "Every enemy in the game will be included for level change and randomization except bosses and alias tagged enemies."
                : categoryDetail == 'None'
                    ? "No level will be modified but randomization will happen."
                    : "You selected that only the level of enemies will be changed and no enemy will be randomized.",
            style: TextStyle(
                fontSize: 16, color: AutomatoThemeColors.textDialogColor(ref)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  // Selected Categories
  List<String> selectedCategories = globalState.categories.entries
      .where((final entry) => entry.value)
      .map((final entry) => entry.key)
      .toList();
  details.add(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category,
                color: AutomatoThemeColors.textDialogColor(ref), size: 24),
            const SizedBox(width: 8),
            Text("Selected Categories:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AutomatoThemeColors.textDialogColor(ref))),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 5),
          child: selectedCategories.isNotEmpty
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: selectedCategories
                      .map((final category) => Text("- $category",
                          style: TextStyle(
                              fontSize: 16,
                              color: AutomatoThemeColors.textDialogColor(ref))))
                      .toList(),
                )
              : Text(
                  "No specific categories selected. Will use all categories.",
                  style: TextStyle(
                      fontSize: 16,
                      color: AutomatoThemeColors.textDialogColor(ref))),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );

  return details;
}
