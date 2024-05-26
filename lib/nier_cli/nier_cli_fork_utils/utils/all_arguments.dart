import 'package:NAER/naer_utils/handle_file_paths.dart';
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
/// - Specification of bosses and their stats.
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

  // Add flags for quest, map, and phase options
  for (var option in questOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in mapOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }
  for (var option in phaseOptions) {
    argParser.addFlag(option, negatable: false, defaultsTo: false);
  }

  // Bosses option: specifies the list of selected bosses to change stats
  argParser.addOption("bosses",
      help: "List of Selected bosses to change stats");

  // Boss stats option: specifies the float stats value for the boss stats
  argParser.addOption("bossStats",
      help: "The float stats value for the boss stats");

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
/// for options that are active. Additionally, processes any specified bosses and their paths.
///
/// [argResults] contains the parsed command-line arguments.
/// [output] is the directory where the paths should be output.
///
/// Returns a list of active option paths.
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
