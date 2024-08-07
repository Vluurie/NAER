import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart';

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
  List<String>? selectedImages,
  required Map<String, bool> categories,
  required Map<String, bool> level,
  required List<String> ignoredModFiles,
  required String input,
  required String specialDatOutputPath,
  required String scriptPath,
  required double enemyStats,
  required int enemyLevel,
  required WidgetRef ref,
}) async {
  final globalState = ref.watch(globalStateProvider);
  String tempFilePath;

  try {
    if (selectedImages != null && selectedImages.isNotEmpty) {
      var sortedEnemies =
          await sortSelectedEnemies(selectedImages, context, ref);
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
  } catch (e, stacktrace) {
    globalLog(Trace.from(stacktrace).toString());
    throw ArgumentError("Error creating temporary file");
  }

  String enemyList = getSelectedEnemiesArgument(ref);
  List<String> processArgs = [
    input,
    '--output',
    specialDatOutputPath,
    tempFilePath,
    '--enemies',
    enemyList.isNotEmpty ? enemyList : 'None',
    '--enemyStats',
    globalState.enemyStats.toString(),
    '--level=$enemyLevel',
    ...globalState.categories.entries
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
    globalLog('Ignore arguments added: $ignoreArgs');
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
