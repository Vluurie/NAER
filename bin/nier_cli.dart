import 'dart:io';

import 'package:args/args.dart';
import 'package:nier_cli/CliOptions.dart';
import 'package:nier_cli/exception.dart';
import 'package:nier_cli/fileTypeHandler.dart';
import 'package:nier_cli/utils.dart';
import 'package:path/path.dart';
import '../lib/enemyfinder.dart';

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
      help: "Randomize all phases", negatable: false, defaultsTo: false);
  argParser.addOption("ignore",
      help: "List of files to ignore during repacking");
  argParser.addFlag("CPK", help: "Only extract CPK files", negatable: false);
  argParser.addFlag("DAT", help: "Only extract DAT files", negatable: false);
  argParser.addFlag("PAK", help: "Only extract PAK files", negatable: false);
  argParser.addFlag("BXM", help: "Only extract BXM files", negatable: false);
  argParser.addFlag("YAX", help: "Only extract YAX files", negatable: false);
  argParser.addFlag("RUBY", help: "Only extract RUBY files", negatable: false);
  argParser.addFlag("WTA", help: "Only extract WTA files", negatable: false);
  argParser.addFlag("WTP", help: "Only extract WTP files", negatable: false);
  argParser.addFlag("BNK", help: "Only extract BNK files", negatable: false);
  argParser.addOption("specialDatOutput",
      help: "Special output directory for DAT files");
  argParser.addFlag("WEM", help: "Only extract WEM files", negatable: false);
  argParser.addFlag("help",
      abbr: "h", help: "Print this help message", negatable: false);
  var args = argParser.parse(arguments);
  print("Parsed args: $args");

  if (arguments.length < 1 || args["help"] == true) {
    printHelp(argParser);
    return;
  }

  String? sortedEnemiesPath;
  if (arguments.length >= 4) {
    sortedEnemiesPath = arguments[3]; // Assuming it's the fourth argument
  }

  if (sortedEnemiesPath == null || sortedEnemiesPath.isEmpty) {
    throw FileHandlingException("Sorted enemies file path not specified");
  }

  String? output = args["output"];
  if (output == null) throw FileHandlingException("Output path not specified");

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
      await handleInput(input, null, options, pendingFiles, processedFiles);
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
      if (entity.path.endsWith('.pak'))
        pakFolders.add(entity.path);
      else if (entity.path.endsWith('.dat')) datFolders.add(entity.path);
    }
  }

  var tD = DateTime.now().difference(t1);
  if (processedFiles.length == 1)
    print("Done (${timeStr(tD)}) :D");
  else {
    if (errorFiles.isNotEmpty) {
      print("Failed to process ${errorFiles.length} files:");
      for (var f in errorFiles) print("- $f");
    }
  }
  print("Processed ${processedFiles.length} files "
      "in ${timeStr(tD)} "
      ":D");
  print("Calling enemy find script...");
  findEnemiesInDirectory(currentDir, sortedEnemiesPath);
  // Process YAX and PAK files
  var xmlFiles = yaxFiles.map((e) => e.replaceAll('.yax', '.xml'));
  var entitiesToProcess = xmlFiles.followedBy(pakFolders);
  for (var file in entitiesToProcess) {
    try {
      await handleInput(file, null, options, pendingFiles, processedFiles);
      processedFiles.add(file);
    } catch (e) {
      // handle exceptions
    }
  }

// Repack & Export DAT files
  for (var datFolder in datFolders) {
    var baseName = basename(datFolder); // This is the file name
    bool processFile = false;

    // Check if the file matches the selected categories
    if (randomizeAllQuests && baseName.startsWith('q')) {
      if (ignoreList.contains(baseName)) {
        continue;
      }
      processFile = true;
    }

    if (randomizeAllMaps && baseName.startsWith('r')) {
      if (ignoreList.contains(baseName)) {
        continue;
      }
      processFile = true;
    }

    if (randomizeAllPhases &&
        (baseName.startsWith('p') || baseName.contains('core'))) {
      if (ignoreList.contains(baseName)) {
        continue;
      }
      processFile = true;
    }

    // Process the file if it matches any of the selected categories
    if (processFile) {
      try {
        var datSubFolder = getDatFolder(baseName);
        var datOutput = join(output, datSubFolder, baseName);
        await handleInput(datFolder, datOutput, options, [], processedFiles);
      } catch (e) {
        print("Failed to process DAT folder");
        print(e);
      }
    }
  }
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
  if (ms < 1000)
    return "${ms}ms";
  else if (ms < 60000)
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
