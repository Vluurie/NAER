// ignore_for_file: avoid_print

import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:args/args.dart';

/// Initializes the argument variables needed for processing the game files.
/// Provides clear and helpful error messages if something goes wrong.
///
/// [args] are the parsed command-line arguments.
/// [output] is the output path for the processed files.
Map<String, dynamic> initializeArgumentVars(
    final ArgResults args, final String output, final OptionIdentifier? sortedEnemyGroupsIdentifierMap) {
  try {
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

    /// Stats of the enemy, parsed as a double from the provided arg
    /// Example enemyStats: 5.0
    double enemyStats = double.parse(args["enemyStats"]);

    /// List of the enemies, parsed from the comma-separated string arg array, with a default empty list
    /// Example structure:  "[em1030],[em1040],[em1074],[em1100, em1101],....
    List<String> enemyList = (args["enemies"] as String?)?.split(',') ?? [];

    /// List of active options, determined by getActiveOptionPaths()
    /// See the method for more information
    List<String> activeOptions = getActiveGameOptionPaths(args, output, sortedEnemyGroupsIdentifierMap);

    /// Builds the map out of the group args
    Map<String, List<String>> customSelectedEnemies =
        createCustomSelectedEnemiesMap(args);

    return {
      'input': input,
      'pendingFiles': pendingFiles,
      'processedFiles': processedFiles,
      'ignoreList': ignoreList,
      'enemyLevel': enemyLevel,
      'enemyCategory': enemyCategory,
      'enemyStats': enemyStats,
      'enemyList': enemyList,
      'activeOptions': activeOptions,
      'customSelectedEnemies': customSelectedEnemies
    };
  } catch (e, stackTrace) {
    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage: '''
An error occurred during the initialization of argument variables.
Potential causes include:
- Missing or incorrect options or paths.
- Invalid values provided (e.g., text instead of a number).
- Misconfigured or missing input files.
Helpful tips:
1. Double-check the paths and values you provided.
2. Use --help to review available options.
If the problem persists, consider using the GUI version or seeking assistance.
''',
    );

    print('''
+-------------------------------------------+
| Oops! Something went wrong.               |
+-------------------------------------------+
| Possible Issues:                          |
| - Missing or incorrect options/paths.     |
| - Incorrect values (e.g., text instead    |
|   of a number).                           |
+-------------------------------------------+
| What to do:                               |
| 1. Double-check the paths and values.     |
| 2. Use --help for available options.      |
+-------------------------------------------+
| Error Details:                            |
| $e                                        |
+-------------------------------------------+
| If the issue persists, consider using the |
| GUI version or seek further assistance.   |
+-------------------------------------------+
''');
    return {};
  }
}
