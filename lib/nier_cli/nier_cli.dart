// ignore_for_file: avoid_print

import 'dart:io';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/handle_file_paths.dart';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/nier_enemy_data/category_data/nier_categories.dart';
import 'package:NAER/naer_services/handle_find_replace_em_data.dart';
import 'package:NAER/naer_services/file_utils/nier_category_manager.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_services/value_utils/handle_boss_stats.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/fileTypeHandler.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils.dart';

final logState = LogState();

void logAndPrint(String message) {
  print(message);
  logState.addLog(message);
}

Future<void> nierCli(List<String> arguments, bool? ismanagerFile) async {
  var t1 = DateTime.now();
  var configArgs = await readConfig();
  arguments = [...configArgs, ...arguments];
  var argParser = ArgParser();
  argParser.addOption("output", abbr: "o", help: "Output file or folder");
  argParser.addSeparator("Extraction Options:");
  argParser.addFlag("folder",
      help: "Extract all files in a folder", negatable: false);
  argParser.addFlag("recursive",
      abbr: "r",
      help: "Extract all files in a folder and all subfolders",
      negatable: false);
  argParser.addFlag("autoExtractChildren",
      help:
          "When unpacking DAT, CPK, PAK, etc. files automatically process all extracted files",
      negatable: false,
      defaultsTo: true);
  argParser.addSeparator("WAV to WEM Conversion Options:");
  argParser.addOption("sortedEnemies",
      help: "Path to the file with sorted enemies");
  argParser.addOption("wwiseCli", help: "Path to WwiseCLI.exe");
  argParser.addFlag("wemBGM", help: "Use music/BGM settings", negatable: false);
  argParser.addFlag("wemVolNorm",
      help: "Enable volume normalization", negatable: false);
  argParser.addSeparator("Extraction filters:");
  argParser.addOption("ignore",
      help: "List of files to ignore during repacking");
  for (var option in questOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in mapOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in phaseOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  argParser.addOption("bosses",
      help: "List of Selected bosses to change stats");
  argParser.addOption("bossStats",
      help: "The float stats value for the boss stats");
  argParser.addFlag("CPK", help: "Only extract CPK files", negatable: false);
  argParser.addFlag("DAT", help: "Only extract DAT files", negatable: false);
  argParser.addFlag("PAK", help: "Only extract PAK files", negatable: false);
  argParser.addFlag("BXM", help: "Only extract BXM files", negatable: false);
  argParser.addFlag("YAX", help: "Only extract YAX files", negatable: false);
  argParser.addFlag("RUBY", help: "Only extract RUBY files", negatable: false);
  argParser.addFlag("WTA", help: "Only extract WTA files", negatable: false);
  argParser.addFlag("WTP", help: "Only extract WTP files", negatable: false);
  argParser.addFlag("BNK", help: "Only extract BNK files", negatable: false);
  argParser.addOption("level", help: "Specify the enemy level");
  argParser.addOption("category", help: "Specify the enemy category");
  argParser.addOption("specialDatOutput",
      help: "Special output directory for DAT files");
  argParser.addFlag("WEM", help: "Only extract WEM files", negatable: false);
  argParser.addFlag("help",
      abbr: "h", help: "Print this help message", negatable: false);
  var args = argParser.parse(arguments);

  if (arguments.isEmpty || args["help"] == true) {
    printHelp(argParser);
    return;
  }

  String? sortedEnemiesPath;
  if (arguments.length >= 4) {
    sortedEnemiesPath = arguments[3];
  }

  if (sortedEnemiesPath == null || sortedEnemiesPath.isEmpty) {
    throw const FileHandlingException("Sorted enemies file path not specified");
  }

  String? output = args["output"];
  if (output == null) {
    throw const FileHandlingException("Output path not specified");
  }

  var options = CliOptions(
    output: null,
    folderMode: args["folder"],
    recursiveMode: args["recursive"],
    wwiseCliPath: args["wwiseCli"],
    isCpk: args["CPK"],
    isDat: args["DAT"],
    isPak: args["PAK"],
    isYax: args["YAX"],
    specialDatOutputPath: args["specialDatOutput"],
  );

  var fileModeOptionsCount =
      [options.recursiveMode, options.folderMode].where((b) => b).length;
  if (fileModeOptionsCount > 1) {
    logState
        .addLog("Only one of --folder, or --recursive can be used at a time");
    return;
  }
  if (fileModeOptionsCount > 0 && options.output != null) {
    logAndPrint("Cannot use --folder or --recursive with --output");
    return;
  }
  if (args.rest.isEmpty) {
    logAndPrint("No input files specified");
    return;
  }

  List<String> getActiveOptionPaths(ArgResults argResults, String output) {
    List<String> allOptions = [...questOptions, ...mapOptions, ...phaseOptions];

    var activePaths = allOptions
        .where((option) =>
            argResults[option] == true && FilePaths.paths.containsKey(option))
        .map((option) => FilePaths.paths[option]!)
        .map((path) => '$output\\$path')
        .toList();

    String? bossesArgument = argResults["bosses"] as String?;
    List<String> bossList = [];
    if (bossesArgument != null) {
      RegExp exp = RegExp(r'\[(.*?)\]');
      var matches = exp.allMatches(bossesArgument);
      for (var match in matches) {
        bossList.addAll(match.group(1)!.split(',').map((s) => s.trim()));
      }
    }

    var bossPaths = bossList
        .where((boss) => FilePaths.paths.containsKey(boss))
        .map((boss) => FilePaths.paths[boss]!)
        .map((path) => '$output\\$path')
        .toList();

    var fullPaths = (activePaths + bossPaths).toSet().toList();
    return fullPaths;
  }

  String input = args.rest[0];
  List<String> pendingFiles = [];
  Set<String> processedFiles = {};
  List<String> ignoreList = args["ignore"]?.split(',') ?? [];
  String enemyLevel = args["level"];
  String enemyCategory = args["category"] ?? '';
  double bossStats = double.parse(args["bossStats"]);
  List<String> bossList = (args["bosses"] as String?)?.split(',') ?? [];
  List<String> activeOptions = getActiveOptionPaths(args, output);

//-------------------------------------------------------------------

  var currentDir = input;
  logAndPrint(
      "Starting processing in directory: $currentDir, recursive mode: ${options.recursiveMode}");

  if (options.recursiveMode) {
    pendingFiles.addAll(Directory(currentDir)
        .listSync(recursive: true)
        .where((e) => e is File && !processedFiles.contains(e.path))
        .map((e) => e.path));
  } else {
    pendingFiles.addAll(Directory(currentDir)
        .listSync()
        .where((e) => e is File && !processedFiles.contains(e.path))
        .map((e) => e.path));
  }

  List<String> errorFiles = [];
  while (pendingFiles.isNotEmpty) {
    input = pendingFiles.removeAt(0);
    if (processedFiles.contains(input)) continue;
    String fileType =
        path.extension(input).toLowerCase(); // Extract file extension
    logAndPrint(
        "Processing file: $input, File type: $fileType"); // Log file path and type
    try {
      await handleInput(input, null, options, pendingFiles, processedFiles,
          bossList, activeOptions, ismanagerFile);
      processedFiles.add(input);
      logAndPrint("Successfully processed file: $input, File type: $fileType");
    } on FileHandlingException catch (e) {
      logAndPrint("Invalid input for file $input (File type: $fileType): $e");
      errorFiles.add(input);
    } catch (e, stackTrace) {
      logAndPrint("Failed to process file $input (File type: $fileType)");
      print(e);
      print(stackTrace);
      errorFiles.add(input);
    }
  }

  if (errorFiles.isNotEmpty) {
    logAndPrint("Failed to process ${errorFiles.length} files:");
    for (var file in errorFiles) {
      logAndPrint("- $file");
    }
  } else {
    logAndPrint("All files processed successfully.");
  }

  // Collect files
  List<String> yaxFiles = [];
  List<String> pakFolders = [];
  List<String> datFolders = [];
  var fileManager = FileCategoryManager(args);
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.yax')) {
        yaxFiles.add(entity.path);
      }
    } else if (entity is Directory) {
      if (entity.path.endsWith('.pak')) {
        pakFolders.add(entity.path);
        // ignore: curly_braces_in_flow_control_structures
      } else if (entity.path.endsWith('.dat')) datFolders.add(entity.path);
    }
  }

  var tD = DateTime.now().difference(t1);
  if (processedFiles.length == 1) {
    logAndPrint("Done (${timeStr(tD)}) :D");
  } else {
    if (errorFiles.isNotEmpty) {
      logAndPrint("Failed to process ${errorFiles.length} files:");
      for (var f in errorFiles) {
        logAndPrint("- $f");
      }
    }
  }
  logAndPrint("Processed ${processedFiles.length} files "
      "in ${timeStr(tD)} "
      ":D");
  findEnemiesInDirectory(
      currentDir, sortedEnemiesPath, enemyLevel, enemyCategory);
  if (bossList.isNotEmpty && !bossList.contains('None')) {
    logAndPrint("Started changing boss stats...");
    print(bossList);
    await findBossStatFiles(currentDir, bossList, bossStats);
  } else {
    logAndPrint("No Boss Stats modified as argument is 'None'");
    print(bossList);
  }

  var xmlFiles = yaxFiles.map((e) => e.replaceAll('.yax', '.xml'));
  var entitiesToProcess = xmlFiles.followedBy(pakFolders);
  for (var file in entitiesToProcess) {
    try {
      await handleInput(file, null, options, pendingFiles, processedFiles,
          bossList, activeOptions, ismanagerFile);
      processedFiles.add(file);
    } catch (e) {
      logAndPrint("input error");
    }
  }

  for (var datFolder in datFolders) {
    var baseNameWithExtension = basename(datFolder);

    bool processFile = false;

    if (bossList.isNotEmpty && !bossList.contains('None')) {
      if (baseNameWithExtension.startsWith('em')) {
        var cleanedBossList = bossList
            .map((criteria) =>
                criteria.replaceAll('[', '').replaceAll(']', '').trim())
            .toList();
        for (var criteria in cleanedBossList) {
          if (baseNameWithExtension.contains(criteria)) {
            processFile = true;
            continue;
          }
        }
      }
    } else {
      logAndPrint("Skipping processing due to Boss List conditions.");
    }

    var baseNameWithoutExtension = basenameWithoutExtension(datFolder);
    if (!baseNameWithExtension.startsWith('em') && !processFile) {
      if (!fileManager.shouldProcessFile(baseNameWithoutExtension)) {
        continue;
      } else {
        processFile = true;
      }
    }

    if (ignoreList.contains(baseNameWithExtension) ||
        baseNameWithExtension.startsWith('r5a5')) {
      continue;
    }

    if (processFile) {
      try {
        var datSubFolder = getDatFolder(baseNameWithExtension);
        var datOutput = join(output, datSubFolder, baseNameWithExtension);
        await handleInput(datFolder, datOutput, options, [], processedFiles,
            bossList, activeOptions, ismanagerFile);
        FileChange change = FileChange(datOutput, 'create');
        FileChange.changes.add(change);
        logState.addLog("Folder created: $datOutput");
      } catch (e) {
        logAndPrint("Failed to process DAT folder");
        print(e);
      }
    }
  }

  await deleteFolders(output, [
    'data002.cpk_extracted',
    'data012.cpk_extracted',
    'data100.cpk_extracted',
    'data016.cpk_extracted',
    'data006.cpk_extracted',
    "st5/nier2blender_extracted",
    "st2/nier2blender_extracted",
    "st1/nier2blender_extracted",
    "quest/nier2blender_extracted",
    "ph4/nier2blender_extracted",
    "ph3/nier2blender_extracted",
    "ph2/nier2blender_extracted",
    "ph1/nier2blender_extracted",
    "em/nier2blender_extracted",
    "core/nier2blender_extracted",
  ]);
  logAndPrint("Randomizing complete");
}

void printHelp(ArgParser argParser) {
  print("Usage:");
  print("  nier_cli <input1> [input2] [input...] [options]");
  print("or");
  print("  nier_cli <input> -o <output> [options]");
  print("Options:");
  print(argParser.usage);
}

String timeStr(Duration d) {
  var ms = d.inMilliseconds;
  if (ms < 1000) {
    return "${ms}ms";
  } else if (ms < 60000)
    // ignore: curly_braces_in_flow_control_structures
    return "${(ms / 1000).toStringAsFixed(2)}s";
  else {
    var m = d.inMinutes;
    var s = (ms / 1000) % 60;
    return "${m}m ${s.toStringAsFixed(2)}s";
  }
}

Future<List<String>> readConfig() async {
  const configName = "config.txt";
  var configPath = join(getAppDir(), configName);
  if (!await File(configPath).exists()) return [];
  var text = await File(configPath).readAsString();
  var seperator = text.contains("\r\n") ? "\r\n" : "\n";
  var args = text
      .split(seperator)
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && !e.startsWith("#"))
      .toList();
  return args;
}

Future<void> deleteFolders(
    String directoryPath, List<String> folderNames) async {
  for (var folderName in folderNames) {
    var folderPath = Directory(join(directoryPath, folderName));
    if (await folderPath.exists()) {
      try {
        await folderPath.delete(recursive: true);
        print('Deleted folder: $folderName');
      } catch (e) {
        print('Error deleting folder $folderName: $e');
      }
    }
  }
}
