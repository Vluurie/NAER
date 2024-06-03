import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:args/args.dart';

/// Processes the game files for modification.
///
/// Handles:
/// 1. get's the game files to be processed
/// 2. extracts the game files that got added to the pending list
/// 3. collects the extracted game files for processing
/// 4. processes the enemies modification/randomization
/// 5. processes the boss stats modification
/// 6. repacks the modified game files and exports them
/// 7. deletes the extracted game files that are not needed anymore
///
/// [argument] is the map containing initialized variables.
/// [sortedEnemiesPath] is the path for the sorted enemies file.
/// [options] are the parsed additional options.
/// [ismanagerFile] indicates if the file is from the mod manager.
/// [output] is the output path for the processed files.
/// [args] are the parsed command-line arguments.
Future<void> mainFuncProcessGameFiles(
  Map<String, dynamic> argument,
  String sortedEnemiesPath,
  CliOptions options,
  bool? ismanagerFile,
  String output,
  ArgResults args,
) async {
  String inputDir = argument['input'];
  String outputDir = path.dirname(inputDir);

// TODO: If the files get's the first time extracted, extract all enemies too
// TODO: Steps for it: 1. Create a list of all enemies for the cli options and future development of enemy stats modification
// TODO: 2. If extractGameFilesProcess gets started because targetOptions do not exist, add all enemies options forced to the argument options
// TODO: 3. Test the results
  await extractGameFilesProcess(argument, options, ismanagerFile, outputDir);

  final onlyLevelPath = getTargetOptionDirectoryPath(outputDir, 'onlylevel');
  final randomizedPath = getTargetOptionDirectoryPath(outputDir, 'default');
  final randomizedAndLevelPath =
      getTargetOptionDirectoryPath(outputDir, 'allenemies');

  if (argument['enemyCategory'] == 'onlylevel') {
    inputDir = onlyLevelPath;
  } else if (argument['enemyCategory'] == 'default') {
    inputDir = randomizedPath;
  } else if (argument['enemyCategory'] == 'allenemies') {
    inputDir = randomizedAndLevelPath;
  }

  // Processing the input directory to identify files to be processed and then adds them to the pending or processed files list
  await getGameFilesForProcessing(
      inputDir, options, argument['pendingFiles'], argument['processedFiles']);

  logAndPrint(inputDir);
  var collectedFiles = collectExtractedGameFiles(inputDir);

  // Finds enemies within the input .xml files to be processed and modifies/randomizes them based on the arguments
  await processEnemies(inputDir, sortedEnemiesPath, argument['enemyLevel'],
      argument['enemyCategory']);

  // Find and process bossStats for the specified bosses out of the bossList
  await processBossStats(inputDir, argument['bossList'], argument['bossStats']);

  // Checks all modified files against the ignoreList or bossList etc.
  // If the inner shouldProcessDatFolder method returns true, dat files will get repacked
  // and output to the output path indicating successful modification *-*
  await repackModifiedGameFiles(
    inputDir,
    collectedFiles,
    options,
    argument['pendingFiles'],
    argument['processedFiles'],
    argument['bossList'],
    argument['activeOptions'],
    ismanagerFile,
    argument['ignoreList'],
    output,
    args,
  );

  // Delete any extracted folders to clean up, so the .exe does not read them (this would crash the game)
  await deleteExtractedGameFolders(output);
}

Future<void> extractGameFilesProcess(Map<String, dynamic> argument,
    CliOptions options, bool? ismanagerFile, String outputDir) async {
  if (checkIfExtractedFoldersExist(outputDir)) {
    logAndPrint(
        'The folders "naer_onlylevel", "naer_randomized", and "naer_randomized_and_level" already exist.');
    return;
  }
  // Processing the input directory to identify files to be processed and then adds them to the pending or processed files list
  await getGameFilesForProcessing(argument['input'], options,
      argument['pendingFiles'], argument['processedFiles']);

  // Extracts the files to be processed specified by the activeOptions and capture any errors encountered
  List<String> errorFiles = await extractGameFiles(
    argument['pendingFiles'],
    argument['processedFiles'],
    options,
    argument['bossList'],
    argument['activeOptions'],
    ismanagerFile,
  );

  // Handles any errors that occurred during file extraction
  handleExtractErrors(errorFiles);

  // Collects the files for modification out of the extracted files to be processed
  var collectedFiles = collectExtractedGameFiles(argument['input']);
  // Helper method to copy the collected files to the upper directory
  await copyCollectedGameFiles(collectedFiles, argument['input']);
}