import 'package:NAER/data/sorted_data/file_paths_data.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:args/args.dart';

/// Constructs and returns an [ArgParser] with all the expected command-line arguments.
///
/// This parser includes options for:
/// - Output file or folder.
/// - Extraction options for folders and subfolders.
/// - Auto extraction of children files.
/// - Extraction filters for various file types.
/// - Specification of enemies and their stats.
/// - Level and category of enemies.
/// - Special output directories for DAT files.
///
/// Returns an [ArgParser] configured with all the necessary command-line options.
ArgParser allArguments() {
  var argParser = ArgParser();

  // Output option: specifies the output file or folder
  argParser.addOption("output", abbr: "o", help: "Output file or folder");

  // Separator for extraction options
  argParser.addSeparator("Extraction Options:");

  // Folder extraction flag: extracts all files in a folder
  argParser.addFlag("folder",
      help: "Extract all files in a folder", negatable: false);

  // Recursive extraction flag: extracts all files in a folder and all subfolders
  argParser.addFlag("recursive",
      abbr: "r",
      help: "Extract all files in a folder and all subfolders",
      negatable: false);

  // Auto-extract children flag: automatically processes all extracted files when unpacking DAT, CPK, PAK, etc. files
  argParser.addFlag("autoExtractChildren",
      help:
          "When unpacking DAT, CPK, PAK, etc. files automatically process all extracted files",
      negatable: false,
      defaultsTo: true);

  // Sorted enemies file path option
  argParser.addOption("sortedEnemies",
      help: "Path to the file with sorted enemies");

  // Separator for extraction filters
  argParser.addSeparator("Extraction filters:");

  // Ignore list option: specifies files to ignore during repacking
  argParser.addOption("ignore",
      help: "List of files to ignore during repacking");

  // Add flags for quest, map, phase and enemy file options
  for (var option in GameFileOptions.questOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in GameFileOptions.mapOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in GameFileOptions.phaseOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in GameFileOptions.enemyOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }

  // Enemies option: specifies the list of selected enemies to change stats
  argParser.addOption("enemies",
      help: "List of Selected enemies to change stats");

  // Enemy stats option: specifies the float stats value for the enemy stats
  argParser.addOption("enemyStats",
      help: "The float stats value for the enemy stats");

  // File type extraction flags
  argParser.addFlag("CPK", help: "Only extract CPK files", negatable: false);
  argParser.addFlag("DAT", help: "Only extract DAT files", negatable: false);
  argParser.addFlag("PAK", help: "Only extract PAK files", negatable: false);
  argParser.addFlag("YAX", help: "Only extract YAX files", negatable: false);

  // Enemy level option: specifies the enemy level
  argParser.addOption("level", help: "Specify the enemy level");

  // Enemy category option: specifies the enemy category
  argParser.addOption("category", help: "Specify the enemy category");

  // Special DAT output directory option
  argParser.addOption("specialDatOutput",
      help: "Special output directory for DAT files");

  // WEM file extraction flag
  argParser.addFlag("WEM", help: "Only extract WEM files", negatable: false);

  return argParser;
}

/// Retrieves active option paths based on the provided [ArgResults] and output directory.
///
/// Combines quest options, map options, and phase options, and generates a list of paths
/// for options that are active. Additionally, processes any specified enemies and their paths.
///
/// [argResults] contains the parsed command-line arguments.
/// [output] is the directory where the paths should be output.
///
/// Returns a list of active option paths.
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

/// Parses command-line arguments into a [CliOptions] object.
///
/// This function extracts relevant options from the provided [ArgResults] and
/// initializes a [CliOptions] object with those values.
///
/// [args] contains the parsed command-line arguments.
///
/// Returns a [CliOptions] object with the parsed argument values.
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

/// Checks for compatibility of provided CLI options.
///
/// Ensures that conflicting options are not used together, such as
/// --folder and --recursive, or combining these with --output.
///
/// [options] contains the parsed CLI options.
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
