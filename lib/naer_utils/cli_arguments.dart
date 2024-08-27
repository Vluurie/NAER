import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:NAER/naer_utils/sort_selected_enemies.dart';
import 'package:path/path.dart' as p;

class CLIArguments {
  final String input;
  final String specialDatOutputPath;
  final String sortedEnemyGroupsIdentifierMap;
  final String enemyList;
  final List<String> processArgs;
  final String command;
  final List<String> fullCommand;
  final List<String> ignoreList;

  CLIArguments({
    required this.input,
    required this.specialDatOutputPath,
    required this.sortedEnemyGroupsIdentifierMap,
    required this.enemyList,
    required this.processArgs,
    required this.command,
    required this.fullCommand,
    required this.ignoreList,
  });
}

Future<CLIArguments> gatherCLIArguments(
    {final List<String>? selectedImages,
    required final Map<String, bool> categories,
    required final Map<String, bool> level,
    required final List<String> ignoredModFiles,
    required final String input,
    required final String specialDatOutputPath,
    required final double enemyStats,
    required final int enemyLevel,
    required final WidgetRef ref}) async {
  final globalState = ref.watch(globalStateProvider);
  String sortedEnemyGroupsIdentifierMap;
  Map<String, List<String>> customSelectedEnemies = {
    "Ground": [],
    "Fly": [],
    "Delete": [],
  };

  try {
    if (selectedImages != null && selectedImages.isNotEmpty) {
      customSelectedEnemies =
          await sortSelectedEnemiesState(selectedImages, ref);

      sortedEnemyGroupsIdentifierMap = "CUSTOM_SELECTED";
    } else {
      sortedEnemyGroupsIdentifierMap = "ALL";
    }
  } catch (e, stacktrace) {
    globalLog(Trace.from(stacktrace).toString());
    throw ArgumentError("Error processing selected enemies");
  }

  String enemyList = getSelectedEnemiesArgument(ref);

  List<String> customEnemiesArgs =
      customSelectedEnemies.entries.map((final entry) {
    String group = entry.key;
    String enemies = entry.value.map((final e) => '"$e"').join(', ');
    return '--$group=[$enemies]';
  }).toList();

  List<String> processArgs = [
    input,
    '--output',
    specialDatOutputPath,
    sortedEnemyGroupsIdentifierMap,
    '--enemies',
    enemyList.isNotEmpty ? enemyList : 'None',
    '--enemyStats',
    globalState.enemyStats.toString(),
    '--level=$enemyLevel',
    ...globalState.categories.entries.where((final entry) => entry.value).map(
        (final entry) => "--${entry.key.replaceAll(' ', '').toLowerCase()}"),
    ...customEnemiesArgs
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

  String command = '';
  if (Platform.isWindows) {
    var currentDir = Directory.current.path;
    command = p.join(currentDir, 'NAER.exe');
  }

  List<String> fullCommand = [command] + processArgs;

  return CLIArguments(
      input: input,
      specialDatOutputPath: specialDatOutputPath,
      sortedEnemyGroupsIdentifierMap: sortedEnemyGroupsIdentifierMap,
      enemyList: enemyList,
      processArgs: processArgs,
      command: command,
      fullCommand: fullCommand,
      ignoreList: ignoredModFiles);
}

Future<CLIArguments> getGlobalArguments(final WidgetRef ref) async {
  final globalState = ref.watch(globalStateProvider.notifier);
  CLIArguments cliArgs = await gatherCLIArguments(
      selectedImages: globalState.readSelectedImages(),
      categories: globalState.readCategories(),
      level: globalState.readLevelMap(),
      ignoredModFiles: globalState.readIgnoredModFiles(),
      input: globalState.readInput(),
      specialDatOutputPath: globalState.readSpecialDatOutputPath(),
      enemyStats: globalState.readEnemyStats(),
      enemyLevel: globalState.readEnemyLevel(),
      ref: ref);
  return cliArgs;
}
