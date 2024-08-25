// ignore_for_file: avoid_print
import 'package:NAER/data/sorted_data/file_paths_data.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:args/args.dart';

/// Constructs and returns an [ArgParser] with all the expected command-line arguments.
ArgParser allArguments() {
  try {
    var argParser = ArgParser();

    argParser.addFlag('guided',
        help:
            'Start the guided mode where you will be prompted to input options step-by-step',
        negatable: false);

    // Folder extraction flag: extracts all files in a folder
    argParser.addFlag("folder", negatable: false);

    // Recursive extraction flag: extracts all files in a folder and all subfolders
    argParser.addFlag("recursive", abbr: "r", negatable: false);

    // File type extraction flags
    argParser.addFlag("CPK", help: "Only extract CPK files", negatable: false);
    argParser.addFlag("DAT", help: "Only extract DAT files", negatable: false);
    argParser.addFlag("PAK", help: "Only extract PAK files", negatable: false);
    argParser.addFlag("YAX", help: "Only extract YAX files", negatable: false);

    // Auto-extract children flag: automatically processes all extracted files when unpacking DAT, CPK, PAK, etc. files
    argParser.addFlag("autoExtractChildren",
        negatable: false, defaultsTo: true);

    argParser.addSeparator(
        "Game Category options - For more Info see: https://github.com/ArthurHeitmann/NierDocs/blob/master/docs/cpkAndDttContents/cpkAndDttContents.md");

    // Add flags for quest, map, phase, and enemy file options
    for (var option in GameFileOptions.questOptions) {
      argParser.addFlag(option,
          help: "Quest Identifier.", negatable: false, defaultsTo: false);
    }
    for (var option in GameFileOptions.mapOptions) {
      argParser.addFlag(option,
          help: "Map Identifier.", negatable: false, defaultsTo: false);
    }
    for (var option in GameFileOptions.phaseOptions) {
      argParser.addFlag(option,
          help: "Phase Identifier.", negatable: false, defaultsTo: false);
    }
    for (var option in GameFileOptions.enemyOptions) {
      argParser.addFlag(option,
          help: "Enemy Identifier.", negatable: false, defaultsTo: false);
    }

    // Output option: specifies the output file or folder
    argParser.addOption("output", abbr: "o", help: "Output file or folder");

    // Separator for extraction options
    argParser.addSeparator("NAER arguments:");

    // Sorted enemies file path option
    argParser.addOption("sortedEnemies",
        help: "Path to the temp file with sorted enemies or by ALL");

    // Enemies option: specifies the list of selected enemies to change stats
    argParser.addOption("enemies", help: "List of enemies to change stats");

    // Enemy stats option: specifies the float stats value for the enemy stats
    argParser.addOption("enemyStats",
        help: "The float stats value for the enemy stats");

    // Enemy level option: specifies the enemy level
    argParser.addOption("level", help: "Specify the enemy level");

    // Enemy category option: specifies the enemy category
    argParser.addOption("category", help: "Specify the enemy category");

    // Special DAT output directory option
    argParser.addOption("specialDatOutput",
        help: "Special output directory for DAT files");

    // Ignore list option: specifies files to ignore during repacking
    argParser.addOption("ignore",
        help: "List of files to ignore during repacking");

    argParser.addOption("Delete",
        help: "Delete enemies: This enemies are skipped from randomization.");

    argParser.addOption("Fly",
        help: "Fly enemies that are used for randomization");

    argParser.addOption("Ground",
        help: "Ground enemies that are used for randomization");

    // Additional flags for balance mode, DLC, and backup
    argParser.addFlag("balance", help: "Enable balance mode", negatable: false);
    argParser.addFlag("dlc", help: "Include DLC content", negatable: false);
    argParser.addFlag("backUp",
        help: "Create a backup before processing", negatable: false);

    argParser.addOption("create_temp", help: '''
+----------------------------------------------------------------------------+
| Create a sorted enemy template file in:                                    |
| NAER_Settings/temp_sorted_enemies.dart                                     |
|                                                                            |
| This file provides a structured template of enemy groups (Ground, Fly,     |
| Delete) that you can easily modify. Customize this file to specify         |
| different enemies according to your needs.                                 |
|                                                                            |
| Use this option to generate the template automatically, making it easier   |
| to set up your custom enemy configurations without starting from scratch.  |
+----------------------------------------------------------------------------+
''');

    // Help flag to provide an overview or detailed explanation of options
    argParser.addFlag("help",
        abbr: "h",
        help: '''
+----------------------------------------------------------------------------+
| Display help information for options.                                      |
| Use --help [option] for a deeper explanation.                              |
| Example: naer --help sortedEnemies                                         |
+----------------------------------------------------------------------------+
''',
        negatable: false);

    return argParser;
  } catch (e) {
    print('''
+---------------------------------------------------+
| Oops! An error occurred while parsing arguments.  |
+---------------------------------------------------+
| Possible Issues:                                  |
| - An invalid option was used.                     |
| - There might be a typo in one of the arguments.  |
+---------------------------------------------------+
| What to do:                                       |
| - Double-check the command you entered.           |
| - Use the --help option to see the correct usage. |
+---------------------------------------------------+
| Error Details:                                    |
| $e                                                |
+---------------------------------------------------+
''');
    rethrow;
  }
}

/// Retrieves active option paths based on the provided [ArgResults] and output directory.
///
/// Combines quest options, map options, and phase options, and generates a list of paths
/// for options that are active. Additionally, processes any specified enemies and their paths.
List<String> getActiveGameOptionPaths(ArgResults argResults, String output) {
  List<String> allOptions = [
    ...GameFileOptions.questOptions,
    ...GameFileOptions.mapOptions,
    ...GameFileOptions.phaseOptions,
    ...GameFileOptions.enemyOptions
  ];

  var activePaths = allOptions
      .where((option) =>
          argResults[option] == true && FilePaths.paths.containsKey(option))
      .map((option) => FilePaths.paths[option]!)
      .map((path) => '$output\\$path')
      .toList();

  String? enemiesArgument = argResults["enemies"] as String?;
  List<String> enemyList = [];
  if (enemiesArgument != null) {
    RegExp exp = RegExp(r'\[(.*?)\]');
    var matches = exp.allMatches(enemiesArgument);
    for (var match in matches) {
      enemyList.addAll(match.group(1)!.split(',').map((s) => s.trim()));
    }
  }

  var enemyPaths = enemyList
      .where((enemy) => FilePaths.paths.containsKey(enemy))
      .map((enemy) => FilePaths.paths[enemy]!)
      .map((path) => '$output\\$path')
      .toList();

  var fullPaths = (activePaths + enemyPaths).toSet().toList();
  return fullPaths;
}

/// Get all possible options of the GameFileOptions with the [input] + [GameFileOptions] + [FilePaths.paths] combined path toList.
/// Can be used to extract everything from the data input directory that can be modified (Stats or Randomization).
List<String> getAllPossibleOptions(String input) {
  return [
    ...GameFileOptions.questOptions,
    ...GameFileOptions.mapOptions,
    ...GameFileOptions.phaseOptions,
    ...GameFileOptions.enemyOptions,
  ]
      .where((option) => FilePaths.paths.containsKey(option))
      .map((option) => '$input/${FilePaths.paths[option]!}')
      .toList();
}

/// Creates the needed map based on --Ground, --Fly, and --Delete arguments.
Map<String, List<String>> createCustomSelectedEnemiesMap(ArgResults? args) {
  Map<String, List<String>> customSelectedEnemies = {
    "Ground": _parseJsonArray(args?['Ground']),
    "Fly": _parseJsonArray(args?['Fly']),
    "Delete": _parseJsonArray(args?['Delete']),
  };

  return customSelectedEnemies;
}

List<String> _parseJsonArray(String? arg) {
  if (arg == null) {
    return [];
  }

  try {
    String cleanedArg = arg.trim();

    // Remove surrounding square brackets if present
    if (cleanedArg.startsWith('[') && cleanedArg.endsWith(']')) {
      cleanedArg = cleanedArg.substring(1, cleanedArg.length - 1);
    }

    List<String> elements = cleanedArg.split(',').map((e) {
      String element = e.trim();
      if (element.startsWith('"') && element.endsWith('"')) {
        element = element.substring(1, element.length - 1);
      }
      return element;
    }).toList();

    return elements;
  } catch (e) {
    throw ArgumentError("Error parsing JSON array: $arg. ${e.toString()}");
  }
}

/// Parses command-line arguments into a [CliOptions] object.
CliOptions parseArguments(ArgResults args) {
  return CliOptions(
    output: null,
    folderMode: args["folder"],
    recursiveMode: args["recursive"],
    isCpk: args["CPK"],
    isDat: args["DAT"],
    isPak: args["PAK"],
    isYax: args["YAX"],
    specialDatOutputPath: args["specialDatOutput"],
  );
}

void checkOptionsCompatibility(CliOptions options) {
  var fileModeOptionsCount =
      [options.recursiveMode, options.folderMode].where((b) => b).length;
  if (fileModeOptionsCount > 1) {
    logState
        .addLog("Only one of --folder, or --recursive can be used at a time");
    return;
  }
  if (fileModeOptionsCount > 0 && options.specialDatOutputPath != null) {
    logAndPrint("Cannot use --folder or --recursive with --output");
    return;
  }
}
