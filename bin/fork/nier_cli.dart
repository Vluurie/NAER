// ignore_for_file: avoid_print

import 'dart:io';

import 'package:NAER/naer_services/value_utils/handle_boss_stats.dart';
import 'package:args/args.dart';
import 'package:NAER/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli_fork_utils/utils/fileTypeHandler.dart';
import 'package:NAER/nier_cli_fork_utils/utils/utils.dart';
import 'package:path/path.dart';
import 'package:NAER/naer_services/handle_find_replace_em_data.dart';

Future<void> main(List<String> arguments) async {
  var t1 = DateTime.now();

  // arguments: [input, -o (optional) output, (optional) args]])]
  // arguments: [input1, [input2], [input...], (optional) args]])]
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
  // Set autoExtractChildren to true by default
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
  argParser.addFlag("allquests",
      help: "Randomize all quests", negatable: false, defaultsTo: false);
  argParser.addFlag("allmaps",
      help: "Randomize all maps", negatable: false, defaultsTo: false);
  argParser.addFlag("allphases",
      help: "Randomize the DLC", negatable: false, defaultsTo: false);
  argParser.addFlag("ignoredlc",
      help: "Randomize all phases", negatable: false, defaultsTo: false);
  argParser.addOption("ignore",
      help: "List of files to ignore during repacking");
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
    sortedEnemiesPath = arguments[3]; // Assuming it's the fourth argument
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
    // Set autoExtractChildren to true by default
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
    print("Only one of --folder, or --recursive can be used at a time");
    return;
  }
  if (fileModeOptionsCount > 0 && options.output != null) {
    print("Cannot use --folder or --recursive with --output");
    return;
  }
  if (args.rest.isEmpty) {
    print("No input files specified");
    return;
  }

  String input = args.rest[0];
  List<String> pendingFiles = [];
  Set<String> processedFiles = {};
  bool randomizeAllQuests = args["allquests"];
  bool randomizeAllMaps = args["allmaps"];
  bool randomizeAllPhases = args["allphases"];
  List<String> ignoreList = args["ignore"]?.split(',') ?? [];
  String enemyLevel = args["level"];
  String enemyCategory = args["category"];
  bool ignoredlc = args["ignoredlc"];
  double bossStats = double.parse(args["bossStats"]);
  List<String> bossList = (args["bosses"] as String?)?.split(',') ?? [];

//-------------------------------------------------------------------

  var currentDir = input;

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
    try {
      await handleInput(
          input, null, options, pendingFiles, processedFiles, bossList);
      processedFiles.add(input);
    } on FileHandlingException catch (e) {
      print("Invalid input");
      print(e);
      errorFiles.add(input);
    } catch (e, stackTrace) {
      print("Failed to process file");
      print(e);
      print(stackTrace);
      errorFiles.add(input);
    }
  }

  // Collect files
  List<String> yaxFiles = [];
  List<String> pakFolders = [];
  List<String> datFolders = [];
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
    print("Done (${timeStr(tD)}) :D");
  } else {
    if (errorFiles.isNotEmpty) {
      print("Failed to process ${errorFiles.length} files:");
      for (var f in errorFiles) {
        print("- $f");
      }
    }
  }
  print("Processed ${processedFiles.length} files "
      "in ${timeStr(tD)} "
      ":D");
  print("Calling enemy find script...");
  findEnemiesInDirectory(
      currentDir, sortedEnemiesPath, enemyLevel, enemyCategory);
  if (bossList.isNotEmpty && !bossList.contains('None')) {
    print("Started changing boss stats...");
    print(bossList);
    await findBossStatFiles(currentDir, bossList, bossStats);
  } else {
    print("No Boss Stats modified as argument is 'None'");
    print(bossList);
  }

  var xmlFiles = yaxFiles.map((e) => e.replaceAll('.yax', '.xml'));
  var entitiesToProcess = xmlFiles.followedBy(pakFolders);
  for (var file in entitiesToProcess) {
    try {
      await handleInput(
          file, null, options, pendingFiles, processedFiles, bossList);
      processedFiles.add(file);
    } catch (e) {
      // handle exceptions
    }
  }

// Repack & Export DAT files
  for (var datFolder in datFolders) {
    var baseName = basename(datFolder); // This is the file name
    bool processFile = false;

    bossList = bossList
        .map((criteria) => criteria.replaceAll('[', '').replaceAll(']', ''))
        .toList();

    if (bossList.isNotEmpty && !bossList.contains('None')) {
      if (baseName.startsWith('em')) {
        for (var criteria in bossList) {
          if (baseName.contains(criteria)) {
            processFile = true;
            break;
          }
        }
      }
    }

    // Check if the file should be ignored due to 'ignoredlc'
    if (ignoredlc &&
        (baseName.startsWith('q085') ||
            baseName.startsWith('q086') ||
            baseName.startsWith('q090') ||
            baseName.startsWith('q091') ||
            baseName.startsWith('q092') ||
            baseName.startsWith('q095') ||
            baseName.startsWith('q060') ||
            baseName.startsWith('qa60') ||
            baseName.startsWith('qa61') ||
            baseName.startsWith('qa62') ||
            baseName.startsWith('qa63') ||
            baseName.startsWith('qa64') ||
            baseName.startsWith('qc50') ||
            baseName.startsWith('r5a8') ||
            baseName.startsWith('r5a9') ||
            baseName.startsWith('r5aa') ||
            baseName.startsWith('r5ac') ||
            baseName.startsWith('p400'))) {
      continue; // Skip the file
    }

    // Check if the file is in the ignoreList
    if (ignoreList.contains(baseName) || baseName.startsWith('r5a5')) {
      continue;
    }

    // Check if the file matches the selected categories
    if (randomizeAllQuests && baseName.startsWith('q')) {
      processFile = true;
    } else if (randomizeAllMaps && baseName.startsWith('r')) {
      processFile = true;
    } else if (randomizeAllPhases && baseName.startsWith('p') ||
        baseName.startsWith('corehap')) {
      processFile = true;
    }

    // Process the file if it matches any of the selected categories
    if (processFile) {
      try {
        var datSubFolder = getDatFolder(baseName);
        var datOutput = join(output, datSubFolder, baseName);
        await handleInput(
            datFolder, datOutput, options, [], processedFiles, bossList);
        print("Folder created: $datOutput");
      } catch (e) {
        print("Failed to process DAT folder");
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
  ]);
  print("Randomizing complete");
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
