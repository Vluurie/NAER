import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/initialize_variables.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/main_process_game_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/count_runtime.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/modify_arguments.dart';
import 'package:args/args.dart';

/// The main function for the Nier CLI tool refactored and modified for enemy randomization, level and boss stats.
///
/// [arguments] is a list of command-line arguments provided, see at all_arguments.dart.
/// [ismanagerFile] is a boolean flag indicating that a file is coming from the mod manager, this modifies the argument with the modify_arguments.dart method.
Future<void> nierCli(NierCliArgs cliArgs) async {
  // Record start of the start time for processing
  var t1 = DateTime.now();

  // Clone the arguments list to avoid side-effects
  List<String> clonedArguments = List.from(cliArgs.arguments);

  // Parse command-line arguments using ArgParser
  ArgParser argParser = allArguments();
  var args = argParser.parse(clonedArguments);

  /// Retrieves and validates the necessary path for the [temp_sorted_enemies.dart] created file in the settings folder, when enemies got selected by hand
  String? sortedEnemiesPath = getSortedEnemiesPath(clonedArguments);
  String? output = args["output"];
  validatePaths(sortedEnemiesPath, output);

  // Parse additional options and ensure they are compatible
  CliOptions options = parseArguments(args);
  checkOptionsCompatibility(options);

  // If no input files are specified, log a message and exit
  if (args.rest.isEmpty) {
    logAndPrint("No input files specified");
    return;
  }

  if (cliArgs.isBalanceMode!) {
    var modifiableArguments = List<String>.from(args.arguments);
    modifiableArguments.modifyArgumentsForForcedEnemyList();
    args = argParser.parse(modifiableArguments);
  }
  //Initialize required argument variables for processing
  var argument = initializeArgumentVars(args, output!);

  ///#######################################[_FOR THE GLORY OF MANKIND_]#######################################################################
  ///#######[_START_NEW_SEED_PROCCESS]#########################################################################################################

  MainData mainData = MainData(
      argument: argument,
      sortedEnemiesPath: sortedEnemiesPath,
      options: options,
      isManagerFile: cliArgs.isManagerFile,
      output: output,
      args: args,
      sendPort: cliArgs.sendPort,
      backUp: cliArgs.backUp,
      isBalanceMode: cliArgs.isBalanceMode,
      hasDLC: cliArgs.hasDLC);

  await mainFuncProcessGameFiles(mainData);

  ///####[_END_NEW_SEED_PROCCESS]###################################################################################################################

  // Logs the final processing time for the glory of mankind
  CountRuntime()
      .processTime(t1, argument['processedFiles'], [], mainData.sendPort);
  logAndPrint("Randomizing complete");
}
