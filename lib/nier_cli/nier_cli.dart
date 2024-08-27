// ignore_for_file: avoid_print
import 'package:NAER/naer_cli/handle_help_argument.dart';
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
Future<void> nierCli(final NierCliArgs cliArgs) async {
  try {
    var t1 = DateTime.now();

    // Clone the arguments list to avoid side-effects
    List<String> clonedArguments = List.from(cliArgs.arguments);

    ArgParser argParser = allArguments();
    var args = argParser.parse(clonedArguments);

    if (args['help'] as bool) {
      String? helpOption;
      if (clonedArguments.length > 1) {
        helpOption = clonedArguments[1].replaceAll('--', '');
      }
      displayHelp(argParser, helpOption);
      return;
    }

    String? sortedEnemyGroupsIdentifierMap =
        getSortedEnemyGroupsIdentifierMap(clonedArguments);
    String? output = args["output"];
    validateIdentifierAndOutput(sortedEnemyGroupsIdentifierMap, output);

    CliOptions options = parseArguments(args);
    checkOptionsCompatibility(options);

    if (args.rest.isEmpty) {
      logAndPrint("No input files specified");
      return;
    }

    if (cliArgs.isBalanceMode!) {
      var modifiableArguments = List<String>.from(args.arguments);
      modifiableArguments.modifyArgumentsForForcedEnemyList();
      args = argParser.parse(modifiableArguments);
    }
    var argument = initializeArgumentVars(args, output!);

    ///#######################################[_FOR THE GLORY OF MANKIND_]#######################################################################
    ///#######[_START_NEW_SEED_PROCCESS]#########################################################################################################

    MainData mainData = MainData(
        argument: argument,
        sortedEnemyGroupsIdentifierMap: sortedEnemyGroupsIdentifierMap,
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
    logAndPrint("Mofification complete");
  } catch (e) {
    print('''
+---------------------------------------------------------------+
| Oops! An error occurred while running the Nier CLI tool.       |
+---------------------------------------------------------------+
| Possible Issues:                                               |
| - An invalid argument or option might have been used.          |
| - A required file or path may be missing or incorrectly set.   |
| - There might be an internal issue with the tool.              |
+---------------------------------------------------------------+
| What to do:                                                    |
| - Double-check the command you entered.                        |
| - Use the --help option to see the correct usage.              |
| - Ensure all necessary files and paths are correctly specified.|
+---------------------------------------------------------------+
| Error Details:                                                 |
| $e                                                             |
+---------------------------------------------------------------+
''');
    rethrow;
  }
}
