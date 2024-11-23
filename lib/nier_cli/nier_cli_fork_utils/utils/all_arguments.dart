// ignore_for_file: avoid_print
import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:NAER/data/sorted_data/file_paths_data.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

/// Constructs and returns an [ArgParser] with all the expected command-line arguments.
ArgParser allArguments() {
  try {
    var argParser = ArgParser();

    argParser.addFlag('guided',
        help:
            'Start the guided mode where you will be prompted to input options step-by-step',
        negatable: false);


    argParser.addSeparator(
        "Game Category options - For more Info see: https://github.com/ArthurHeitmann/NierDocs/blob/master/docs/cpkAndDttContents/cpkAndDttContents.md");

    // Add flags for quest, map, phase, and enemy file options
    for (var option in GameFileOptions.questOptions) {
      argParser.addFlag(option, help: "Quest Identifier.", negatable: false);
    }
    for (var option in GameFileOptions.mapOptions) {
      argParser.addFlag(option, help: "Map Identifier.", negatable: false);
    }
    for (var option in GameFileOptions.phaseOptions) {
      argParser.addFlag(option, help: "Phase Identifier.", negatable: false);
    }
    for (var option in GameFileOptions.enemyOptions) {
      argParser.addFlag(option, help: "Enemy Identifier.", negatable: false);
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
  } catch (e, stackTrace) {
    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage: '''
An error occurred while constructing the argument parser.
Potential causes:
- Invalid option or typo in the argument parser code.
- Unexpected input while parsing arguments.
''',
    );

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
/// Combines quest options, map options, phase options to generate
/// a list of active paths. Additionally processes any specified enemies and their paths.
List<DatFolder> getActiveGameOptionPaths(
  final ArgResults argResults,
  final String output,
  final OptionIdentifier? sortedEnemyGroupsIdentifierMap,
) {
  // Step 1: Gather all game file options
  final List<String> allOptions = [
    ...GameFileOptions.questOptions,
    ...GameFileOptions.mapOptions,
    ...GameFileOptions.phaseOptions,
    ...GameFileOptions.enemyOptions,
  ];

  // Step 2: Parse enemies argument
  final String? enemiesArgument = argResults['enemies'] as String?;
  final List<DatFolder> enemyList = parseEnemyList(enemiesArgument);

  // Step 3: Determine active paths from args
  final List<DatFolder> activePathsFromArgs = allOptions
      .where((final option) => argResults.wasParsed(option) && FilePaths.paths.containsKey(option))
      .map((final option) => path.join(output, FilePaths.paths[option]!))
      .map((final path) => DatFolder(path: path))
      .toList();

  // Step 4: Handle cases based on the sortedEnemyGroupsIdentifierMap
  switch (sortedEnemyGroupsIdentifierMap) {
    case OptionIdentifier.all:
      // Use all map, phase, and quest options, with optional enemy paths
      return _mapAllOptions(output, enemyList);

    case OptionIdentifier.statsOnly:
      // Return only enemy paths for stats-only mode
      return _mapEnemyPaths(enemyList, output);

    case OptionIdentifier.customSelected:
      // Return parsed active paths or fallback to all options if none are active
      final List<DatFolder> enemyPaths = _mapEnemyPaths(enemyList, output);
      return (activePathsFromArgs.isNotEmpty
          ? (activePathsFromArgs + enemyPaths)
          : _mapAllOptions(output, enemyList))
          .toSet()
          .toList();

    case null:
      // Default behavior if identifier is null
      return _mapAllOptions(output, enemyList);

    default:
      throw ArgumentError('Error: Unsupported OptionIdentifier: $sortedEnemyGroupsIdentifierMap');
  }
}

/// Parses the enemy list from the given argument string.
List<DatFolder> parseEnemyList(final String? enemiesArgument) {
  if (enemiesArgument == null) return [];

  final RegExp exp = RegExp(r'\[(.*?)\]');
  return exp
      .allMatches(enemiesArgument)
      .expand((final match) => match.group(1)!.split(',').map((final s) => s.trim()))
      .map((final path) => DatFolder(path: path))
      .toList();
}

/// Maps the enemy list to their corresponding paths in the output directory.
List<DatFolder> _mapEnemyPaths(final List<DatFolder> enemyList, final String output) {
  return enemyList
      .where((final enemy) => FilePaths.paths.containsKey(enemy.path))
      .map((final enemy) => path.join(output, FilePaths.paths[enemy.path]!))
       .map((final path) => DatFolder(path: path))
      .toList();
}

/// Maps all available options to their corresponding paths in the output directory,
/// optionally including enemy paths if `enemyList` is not empty.
List<DatFolder> _mapAllOptions(final String output, final List<DatFolder> enemyList) {
  final List<DatFolder> allPaths = [
    ...GameFileOptions.mapOptions,
    ...GameFileOptions.phaseOptions,
    ...GameFileOptions.questOptions,
  ]
      .where((final option) => FilePaths.paths.containsKey(option))
      .map((final option) => path.join(output, FilePaths.paths[option]!))
      .map((final path) => DatFolder(path: path))
      .toList();

  if (enemyList.isNotEmpty) {
    final List<DatFolder> enemyPaths = _mapEnemyPaths(enemyList, output);
    return (allPaths + enemyPaths).toSet().toList();
  }

  return allPaths;
}

/// Get all possible options of the GameFileOptions with the combined paths.
/// Can be used to extract everything from the data input directory that can be modified.
List<DatFolder> getAllPossibleOptionsExtract(final String input) {
  return [
    ...GameFileOptions.questOptions,
    ...GameFileOptions.mapOptions,
    ...GameFileOptions.phaseOptions,
    ...GameFileOptions.enemyOptions,
  ]
      .where((final option) => FilePaths.paths.containsKey(option))
      .map((final option) => path.join(input, FilePaths.paths[option]!))
      .map((final path) => DatFolder(path: path))
      .toList();
}

/// Creates the needed map based on --Ground, --Fly, and --Delete arguments.
Map<String, List<String>> createCustomSelectedEnemiesMap(
    final ArgResults? args) {
  Map<String, List<String>> customSelectedEnemies = {
    "Ground": _parseJsonArray(args?['Ground']),
    "Fly": _parseJsonArray(args?['Fly']),
    "Delete": _parseJsonArray(args?['Delete']),
  };

  return customSelectedEnemies;
}

List<String> _parseJsonArray(final String? arg) {
  if (arg == null) {
    return [];
  }

  try {
    String cleanedArg = arg.trim();

    // Remove surrounding square brackets if present
    if (cleanedArg.startsWith('[') && cleanedArg.endsWith(']')) {
      cleanedArg = cleanedArg.substring(1, cleanedArg.length - 1);
    }

    // Split the string by commas and remove any quotes from each element
    List<String> elements = cleanedArg.split(',').map((final e) {
      return e.trim().replaceAll(RegExp(r'^"|"$'), '');
    }).toList();

    // Check if the list contains only an empty string and return an empty list if true
    if (elements.length == 1 && elements[0].isEmpty) {
      return [];
    }

    return elements;
  } catch (e, stackTrace) {
    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage: '''
Failed to parse JSON array:
- Input Argument: $arg
Ensure the input is a valid JSON array string format, e.g., "[item1, item2]".
''',
    );
    throw ArgumentError("Error parsing JSON array: $arg. ${e.toString()}");
  }
}

