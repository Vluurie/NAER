import 'package:NAER/naer_utils/isolate_service.dart';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/main_extract_game_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';

/// Processes the game files for modification.
///
/// This function performs several tasks to modify and process game files, including:
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
Future<void> mainFuncProcessGameFiles(MainData mainData) async {
  String inputDir = mainData.argument['input'];
  String outputDir = path.dirname(inputDir);
  bool extractedFoldersExist = checkIfExtractedFoldersExist(outputDir);

  if (mainData.isManagerFile!) {
    // Start deleting existing extracted folders and let it run in an isolate.
    IsolateService().runInIsolate(deleteExtractedGameFolders, [inputDir]);
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
    // init pending files
    //  mainData.argument['pendingFiles'];
    await getGameFilesForProcessing(inputDir, mainData);
  }

  // Collect the extracted game files from the input directory.
  var collectedFiles = collectExtractedGameFiles(inputDir);

  // Modify or randomize enemies within the input .xml files based on the arguments.
  await processEnemies(mainData, collectedFiles, inputDir);

  // Process enemy stats for the specified enemies from the enemy list.
  bool reverseStats = false;
  await processEnemyStats(inputDir, mainData, reverseStats);

  // Check all modified files against the ignore list or enemy list, etc.
  // If the inner shouldProcessDatFolder method returns true, dat files will get repacked.
  await repackModifiedGameFiles(collectedFiles, mainData);

  // Start cleaning tasks and let them run in an isolate.
  IsolateService().runInIsolate(deleteExtractedGameFolders, [mainData.output]);
  IsolateService()
      .runInIsolate(deleteExtractedGameFolders, [mainData.argument['input']]);

  // Reverse the modified .csv files to their original state.
  IsolateService().runInIsolate(
      processEnemyStats, [inputDir, mainData, reverseStats = true]);
}
