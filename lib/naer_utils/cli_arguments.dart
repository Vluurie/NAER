import 'dart:io';

import 'package:NAER/custom_naer_ui/image_ui/enemy_image_grid.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:NAER/naer_utils/sort_selected_enemies.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class CLIArguments {
  final String input;
  final String specialDatOutputPath;
  final String tempFilePath;
  final String bossList;
  final List<String> processArgs;
  final String command;
  final List<String> fullCommand;
  List<String> ignoreList;

  CLIArguments(
      {required this.input,
      required this.specialDatOutputPath,
      required this.tempFilePath,
      required this.bossList,
      required this.processArgs,
      required this.command,
      required this.fullCommand,
      required this.ignoreList});
}

Future<CLIArguments> gatherCLIArguments({
  required BuildContext context,
  required ScrollController scrollController,
  required GlobalKey<EnemyImageGridState> enemyImageGridKey,
  required Map<String, bool> categories,
  required Map<String, bool> level,
  required List<String> ignoredModFiles,
  required String input,
  required String specialDatOutputPath,
  required String scriptPath,
  required double enemyStats,
  required int enemyLevel,
}) async {
  String tempFilePath;
  List<String>? selectedImages = enemyImageGridKey.currentState?.selectedImages;

  try {
    if (selectedImages!.isNotEmpty) {
      var sortedEnemies = await sortSelectedEnemies(selectedImages, context);
      var tempFile = await File(
              '${await FileChange.ensureSettingsDirectory()}/temp_sorted_enemies.dart')
          .create();
      var buffer = StringBuffer();
      buffer.writeln("const Map<String, List<String>> sortedEnemyData = {");
      sortedEnemies.forEach((group, enemies) {
        var enemiesFormatted = enemies.map((e) => '"$e"').join(', ');
        buffer.writeln('  "$group": [$enemiesFormatted],');
      });
      buffer.writeln("};");
      await tempFile.writeAsString(buffer.toString());
      tempFilePath = tempFile.path.convertAndEscapePath();
    } else {
      tempFilePath = "ALL";
    }
  } catch (e) {
    throw ArgumentError("Error creating temporary file");
  }

  String bossList = getSelectedBossesArgument();
  List<String> processArgs = [
    input,
    '--output',
    specialDatOutputPath,
    tempFilePath,
    '--bosses',
    bossList.isNotEmpty ? bossList : 'None',
    '--bossStats',
    enemyStats.toString(),
    '--level=$enemyLevel',
    ...categories.entries
        .where((entry) => entry.value)
        .map((entry) => "--${entry.key.replaceAll(' ', '').toLowerCase()}"),
  ];

  // if (level["Only Selected Enemies"] == true) {
  //   processArgs.add("--category=onlyselectedenemies");
  // }

  // if (level["Only Bosses"] == true) {
  //   processArgs.add("--category=onlybosses");
  // }

  if (level["All Enemies"] == true) {
    processArgs.add("--category=allenemies");
  }

  if (level["All Enemies without Randomization"] == true) {
    processArgs.add("--category=onlylevel");
  }

  if (level["None"] == true) {
    processArgs.add("--category=default");
  }

  List<String> ignoredModFiles = FileChange.ignoredFiles;
  if (ignoredModFiles.isNotEmpty) {
    String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
    processArgs.add(ignoreArgs);
    print("Ignore arguments added: $ignoreArgs");
  }

  String command = scriptPath;
  if (Platform.isMacOS || Platform.isLinux) {
    processArgs.insert(0, scriptPath);
    command = 'sudo';
  } else if (Platform.isWindows) {
    var currentDir = Directory.current.path;
    command = p.join(currentDir, 'NAER.exe');
  }

  List<String> fullCommand = [scriptPath] + processArgs;

  if (Platform.isMacOS || Platform.isLinux) {
    fullCommand = [scriptPath] + processArgs;
  } else if (Platform.isWindows) {
    fullCommand = [command] + processArgs;
  }

  return CLIArguments(
      input: input,
      specialDatOutputPath: specialDatOutputPath,
      tempFilePath: tempFilePath,
      bossList: bossList,
      processArgs: processArgs,
      command: command,
      fullCommand: fullCommand,
      ignoreList: ignoredModFiles);
}
