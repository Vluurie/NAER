import 'package:NAER/naer_services/value_utils/modify_enemy_stats.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/main_extract_game_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';

/// Performs several tasks to modify and process game files, including:
/// 1. Retrieving the game files to be processed.
/// 2. Extracting the game files that are added to the pending list.
/// 3. Collecting the extracted game files for further processing.
/// 4. Modifying or randomizing the enemies within the game files.
/// 5. Modifying the enemy stats.
/// 6. Repackaging the modified game files and exporting them.
/// 7. Deleting the extracted game files that are no longer needed.
/// 8. Reversing the enemy stats back to their original state.
///
/// [mainData] contains the necessary data and configuration for processing the game files.
Future<void> mainFuncProcessGameFiles(final MainData mainData) async {
  final isolateService = IsolateService();

  String inputDir = mainData.argument['input'];
  String outputDir = path.dirname(inputDir);
  bool extractedFoldersExist = await checkIfExtractedFoldersExist(outputDir);

  if (mainData.isManagerFile!) {
    await isolateService.initialize();
    await isolateService.runInIsolate(deleteExtractedGameFolders, [inputDir]);
  }

  // Extract the game files if they are not already extracted and create copies of the extracted files.
  // Skip copying extracted files if they are a mod manager file.
  await extractGameFilesProcess(outputDir, mainData);

  if (!mainData.isManagerFile!) {
    if (mainData.backUp! || extractedFoldersExist) {
      // Change the input directory to an already extracted folder for faster processing.
      inputDir =
          getExtractedOptionDirectories(outputDir, inputDir, mainData.argument);
    }
  }

  // Identify files to be processed and add them to the pending files list.
  if (mainData.isManagerFile!) {
    await isolateService.initialize();
    await getGameFilesForProcessing(inputDir, mainData);
  }

  // Collect the extracted game files from the input directory.
  var collectedFiles = collectExtractedGameFiles(inputDir);

  // Modify or randomize enemies within the input .xml files based on the arguments.
  await isolateService.runInAwaitedIsolate(
      processEnemies, [mainData, collectedFiles, inputDir]);

  // Process enemy stats for the specified enemies from the enemy list.
  await ModifyEnemyStats.ensureFilesAreLoaded(inputDir);
  await ModifyEnemyStats.processEnemyStats(mainData, inputDir);

  if (mainData.isBalanceMode!) {
    await ModifyEnemyStats.balanceEnemyStats(mainData, inputDir);
  }

  // Check all modified files against the ignore list or enemy list, etc.
  // If the inner shouldProcessDatFolder method returns true, dat files will get repacked.
  await repackModifiedGameFiles(collectedFiles, mainData);

  // Reverse the modified .csv files to their original state.
  await ModifyEnemyStats.restoreEnemyStats();

  // Start cleaning tasks and let them run in an isolate.
  await isolateService
      .runInIsolate(deleteExtractedGameFolders, [mainData.output]);
  await isolateService
      .runInIsolate(deleteExtractedGameFolders, [mainData.argument['input']]);

  await isolateService.cleanup();
}
