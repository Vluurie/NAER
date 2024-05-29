import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:args/args.dart';

/// Initializes the argument variables needed for processing the game files.
///
/// [args] are the parsed command-line arguments.
/// [output] is the output path for the processed files.
Map<String, dynamic> initializeArgumentVars(ArgResults args, String output) {
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
  List<String> activeOptions = getActiveGameOptionPaths(args, output);

  return {
    'input': input,
    'pendingFiles': pendingFiles,
    'processedFiles': processedFiles,
    'ignoreList': ignoreList,
    'enemyLevel': enemyLevel,
    'enemyCategory': enemyCategory,
    'bossStats': bossStats,
    'bossList': bossList,
    'activeOptions': activeOptions
  };
}
