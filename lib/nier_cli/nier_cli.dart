import 'package:args/args.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';

import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/count_runtime.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';

/// The main function for the Nier CLI tool refactored and modified for enemy randomization, level and boss stats.
///
/// [arguments] is a list of command-line arguments provided, see at all_arguments.dart.
/// [ismanagerFile] is a boolean flag indicating that a file is coming from the mod manager, this modifies the argument with the modify_arguments.dart method.
Future<void> nierCli(List<String> arguments, bool? ismanagerFile) async {
  // Record start of the start time for processing
  var t1 = DateTime.now();

  // Clone the arguments list to avoid side-effects
  arguments = [...arguments];

  // Parse command-line arguments using ArgParser
  ArgParser argParser = allArguments();
  var args = argParser.parse(arguments);

  /// Retrieves and validates the necessary path for the [temp_sorted_enemies.dart] created file in the settings folder, when enemies got selected by hand
  String? sortedEnemiesPath = getSortedEnemiesPath(arguments);
  String? output = args["output"];
  validatePaths(sortedEnemiesPath, output);

  // Parse additional options and ensure they are compatible
  var options = parseArguments(args);
  checkOptionsCompatibility(options);

  // If no input files are specified, log a message and exit
  if (args.rest.isEmpty) {
    logAndPrint("No input files specified");
    return;
  }

// Initialize required variables for processing

  /// Input path argument gotten from the very first arg
  /// Example path: ?:\SteamLibrary\steamapps\common\NieRAutomata\data
  String input = args.rest[0];

  /// List to hold files that are pending processing
  /// Example file: ?:\SteamLibrary\steamapps\common\data002.cpk_extracted\core\corehap.dat
  List<String> pendingFiles = [];

  /// Set to keep track of files that have been processed
  /// Example file: ?:\SteamLibrary\steamapps\common\data002.cpk_extracted\core\corehap.dat
  Set<String> processedFiles = {};

  /// List of mods or other game files to ignore during processing
  /// Example files: "[corehap.dat, em1020.dat, r120.dat]
  List<String> ignoreList = args["ignore"]?.split(',') ?? [];

  /// The level arg for the enemies
  /// Example level: 99
  String enemyLevel = args["level"];

  /// Category of the enemy, with a default value of an empty string
  /// Example category: 'allenemies'
  String enemyCategory = args["category"] ?? '';

  /// Stats of the boss, parsed as a double from the provided arg
  /// Example bossStat: 5.0
  double bossStats = double.parse(args["bossStats"]);

  /// List of the bosses, parsed from the comma-separated string arg array, with a default empty list
  /// Example structure:  "[em1030],[em1040],[em1074],[em1100, em1101],....
  List<String> bossList = (args["bosses"] as String?)?.split(',') ?? [];

  /// List of active options, determined by getActiveOptionPaths()
  /// See the method for more information
  List<String> activeOptions = getActiveOptionPaths(args, output!);

  ///#######################################[_FOR THE GLORY OF MANKIND_]#######################################################################
  ///#######[_START_NEW_SEED_PROCCESS]#########################################################################################################

//##### Processing the input directory to identify files to be processed #####
  await processDirectory(input, options, pendingFiles, processedFiles);

//##### Extracts the files to be processed and capture any errors encountered #####
  List<String> errorFiles = await processFiles(pendingFiles, processedFiles,
      options, bossList, activeOptions, ismanagerFile);

//##### Handles any errors that occurred during file processing #####
  handleErrors(errorFiles);

//##### Collects the files for modification out of the extracted files to be processed #####
  var collectedFiles = collectFiles(input);

//##### Finds enemies within the input .xml files to be processed and modifies/randomizes them #####
  await modifyEnemiesInDirectory(
      input, sortedEnemiesPath!, enemyLevel, enemyCategory);

//##### Find and process bossStats for the specified bosses out of the bossList #####
  await processBossStats(input, bossList, bossStats);

//##### Checks all modified files against the ignoreList or bossList etc. #####
//##### If the inner shouldProcessDatFolder method returns true, dat files will get repacked #####
//##### and output to the output path indicating successful modification *-* #####
  await processCollectedFiles(
      input,
      collectedFiles,
      options,
      pendingFiles,
      processedFiles,
      bossList,
      activeOptions,
      ismanagerFile,
      ignoreList,
      output,
      args);

//##### Delete any extracted folders to clean up, so the .exe does not read them (this would crash the game) #####
  await deleteFolders(output);

  ///####[_END_NEW_SEED_PROCCESS]###################################################################################################################

//##### Logs the final processing time for the glory of mankind#####
  processTime(t1, processedFiles, errorFiles);
  logAndPrint("Randomizing complete");
}
