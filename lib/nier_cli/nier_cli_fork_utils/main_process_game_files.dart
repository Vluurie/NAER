import 'dart:isolate';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:args/args.dart';

/// Processes the game files for modification.
///
/// Handles:
/// 1. Gets the game files to be processed
/// 2. Extracts the game files that got added to the pending list
/// 3. Collects the extracted game files for processing
/// 4. Processes the enemies modification/randomization
/// 5. Processes the boss stats modification
/// 6. Repackages the modified game files and exports them
/// 7. Deletes the extracted game files that are not needed anymore
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
    SendPort sendPort,
    bool? backUp) async {
  String inputDir = argument['input'];
  String outputDir = path.dirname(inputDir);
  bool extractedFoldersExist = checkIfExtractedFoldersExist(outputDir);
  if (ismanagerFile!) {
    /// delete existing extracted folders in the mod package folder before randomization to start a fresh extract
    await deleteExtractedGameFolders(inputDir);
  }

  /// Start extracting the game files if they where not already extracted and create copies of the extracted files
  /// Only if they are a mod manager file skip copying extracted files
  await extractGameFilesProcess(
      argument, options, ismanagerFile, outputDir, output, sendPort, backUp);

  if (!ismanagerFile) {
    if (backUp! || extractedFoldersExist) {
      /// change the input directory to an already extracted folder for faster processing
      inputDir = getExtractedOptionDirectories(outputDir, argument, inputDir);
    }
  }

  // Processing the input directory to identify files to be processed and then adds them to the pending or processed files list
  if (!ismanagerFile) {
    await getGameFilesForProcessing(inputDir, options, argument['pendingFiles'],
        argument['processedFiles'], sendPort);
  }
// Collect the extracted game files from the input dir
  var collectedFiles = collectExtractedGameFiles(inputDir);

  // Finds enemies within the input .xml files to be processed and modifies/randomizes them based on the arguments
  await processEnemies(inputDir, sortedEnemiesPath, argument['enemyLevel'],
      argument['enemyCategory'], collectedFiles);

  // Find and process bossStats for the specified bosses out of the bossList
  await processEnemyStats(
      inputDir, argument['enemyList'], argument['enemyStats'], false, sendPort);

  // Checks all modified files against the ignoreList or bossList etc.
  // If the inner shouldProcessDatFolder method returns true, dat files will get repacked
  // and output to the output path indicating successful modification *-*
  await repackModifiedGameFiles(
      inputDir,
      collectedFiles,
      options,
      argument['pendingFiles'],
      argument['processedFiles'],
      argument['enemyList'],
      argument['activeOptions'],
      ismanagerFile,
      argument['ignoreList'],
      output,
      args,
      sendPort);

  // Delete any extracted folders to clean up, so the .exe does not read them (this would crash the game)
  await deleteExtractedGameFolders(output);
// Reverse the extracted .csv files that where modified to original
  sendPort.send('Reversing enemy stats back to normal on extracted files..');
  await processEnemyStats(
      inputDir, argument['enemyList'], argument['enemyStats'], true, sendPort);
}

/// Extracts the game files with various checks beforehand.
/// Creates after extracting three identical folders on the outer input path.
/// If the three folders already exist, it skips extracting.
/// If the bool [isManagerFile] is true, it skips the extracting.
///
Future<void> extractGameFilesProcess(
    Map<String, dynamic> argument,
    CliOptions options,
    bool? isManagerFile,
    String outputDir,
    String output,
    SendPort sendPort,
    bool? backUp) async {
  // Check the folders existence
  bool extractedFoldersExist = checkIfExtractedFoldersExist(outputDir);
  if (extractedFoldersExist && (!isManagerFile!)) {
    sendPort.send(
        'The copied "naer_onlylevel", "naer_randomized", and "naer_randomized_and_level" folders already exist.');
    sendPort.send('Skipping extraction of game files.');
    return;
  }

  // If either isManagerFile or isInGameDataDirectory is false, send initial messages
  if (!isManagerFile!) {
    sendPort.send('DO NOT CLOSE THE TOOL TILL FINISHED!');

    sendPort.send('Extracting game files, can take up to ~ 1 min....');
  }

  // Processing the input directory to identify files to be processed and then adds them to the pending or processed files list
  await getGameFilesForProcessing(argument['input'], options,
      argument['pendingFiles'], argument['processedFiles'], sendPort);

  // Extracts the files to be processed specified by the activeOptions and capture any errors encountered
  List<String> errorFiles = await extractGameFiles(
      argument['pendingFiles'],
      argument['processedFiles'],
      options,
      argument['enemyList'],
      List.from(argument['activeOptions'])
        ..addAll(getAllPossibleOptions(argument[
            'input'])), // <--- Sneaky workaround to get all extracted, no matter what was selected as the active option. ;)
      isManagerFile,
      sendPort);

  // Handles any errors that occurred during file extraction
  handleExtractErrors(errorFiles);

  if (!isManagerFile) {
    if (backUp!) {
      sendPort.send(
          'Creating three backup extracted game folders for randomization in upper directory...');
      sendPort.send('(this reduces next randomization speed to ~ 10 seconds)');

      // Collects the files for modification out of the extracted files to be processed
      var collectedFiles = collectExtractedGameFiles(argument['input']);

      // Helper method to copy the collected files to the upper directory
      await copyCollectedGameFiles(collectedFiles, argument['input']);
      sendPort.send('Copying finished.');
    }
  }
}
