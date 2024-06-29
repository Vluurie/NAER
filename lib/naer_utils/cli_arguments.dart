import 'dart:io';
import 'package:stack_trace/stack_trace.dart';

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
  final String enemyList;
  final List<String> processArgs;
  final String command;
  final List<String> fullCommand;
  final List<String> ignoreList;

  CLIArguments({
    required this.input,
    required this.specialDatOutputPath,
    required this.tempFilePath,
    required this.enemyList,
    required this.processArgs,
    required this.command,
    required this.fullCommand,
    required this.ignoreList,
  });
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
    if (selectedImages != null && selectedImages.isNotEmpty) {
      var sortedEnemies = await sortSelectedEnemies(selectedImages, context);
      var tempFile = await File(
              '${await FileChange.ensureSettingsDirectory()}/temp_sorted_enemies.dart')
          .create();
      print('Temporary file created at: ${tempFile.path}');
      var buffer = StringBuffer();
      buffer.writeln("const Map<String, List<String>> sortedEnemyData = {");
      sortedEnemies.forEach((group, enemies) {
        var enemiesFormatted = enemies.map((e) => '"$e"').join(', ');
        buffer.writeln('  "$group": [$enemiesFormatted],');
      });
      buffer.writeln("};");
      await tempFile.writeAsString(buffer.toString());
      tempFilePath = tempFile.path.convertAndEscapePath();
      print('Temporary file path: $tempFilePath');
    } else {
      tempFilePath = "ALL";
    }
  } catch (e, stacktrace) {
    print('Error creating temporary file: $e');
    print(Trace.from(stacktrace).toString());
    throw ArgumentError("Error creating temporary file");
  }

  String enemyList = getSelectedEnemiesArgument();
  List<String> processArgs = [
    input,
    '--output',
    specialDatOutputPath,
    tempFilePath,
    '--enemies',
    enemyList.isNotEmpty ? enemyList : 'None',
    '--enemyStats',
    enemyStats.toString(),
    '--level=$enemyLevel',
    ...categories.entries
        .where((entry) => entry.value)
        .map((entry) => "--${entry.key.replaceAll(' ', '').toLowerCase()}"),
  ];

  if (level["All Enemies"] == true) {
    processArgs.add("--category=allenemies");
  }

  if (level["All Enemies without Randomization"] == true) {
    processArgs.add("--category=onlylevel");
  }

  if (level["None"] == true) {
    processArgs.add("--category=default");
  }

  if (ignoredModFiles.isNotEmpty) {
    String ignoreArgs = '--ignore=${ignoredModFiles.join(',')}';
    processArgs.add(ignoreArgs);
    print('Ignore arguments added: $ignoreArgs');
  }

  String command = scriptPath;
  if (Platform.isMacOS || Platform.isLinux) {
    processArgs.insert(0, scriptPath);
    command = 'sudo';
  } else if (Platform.isWindows) {
    var currentDir = Directory.current.path;
    command = p.join(currentDir, 'NAER.exe');
  }

  List<String> fullCommand = [command] + processArgs;

  return CLIArguments(
    input: input,
    specialDatOutputPath: specialDatOutputPath,
    tempFilePath: tempFilePath,
    enemyList: enemyList,
    processArgs: processArgs,
    command: command,
    fullCommand: fullCommand,
    ignoreList: ignoredModFiles,
  );
}
