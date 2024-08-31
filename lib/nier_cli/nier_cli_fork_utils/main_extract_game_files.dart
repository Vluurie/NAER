// ignore_for_file: unnecessary_string_escapes

import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/randomize_process.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/all_arguments.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/collect_files.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/count_runtime.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';

/// Extracts the game files with various checks beforehand.
/// Creates after extracting three identical folders on the outer input path if backup is true.
/// If the three folders already exist, it skips extracting.
/// If the bool [isManagerFile] is true, it skips the extracting.
///
Future<void> extractGameFilesProcess(
    final String outputDir, final MainData mainData) async {
  bool extractedFoldersExist = await checkIfExtractedFoldersExist(outputDir);
  if (extractedFoldersExist && (!mainData.isManagerFile!)) {
    mainData.sendPort
        .send('Extracted folders exist. Skipping extraction of game files.');
    return;
  }

  if (!mainData.isManagerFile!) {
    mainData.sendPort.send('DO NOT CLOSE TILL FINISHED!');
    mainData.sendPort.send(
        'Extracting game files, this can take some time so prepair your coffee....');
  }

  // Processing the input directory to identify files to be processed and then adds them to the pending or processed files list
  await getGameFilesForProcessing(mainData.argument['input'], mainData);

  // Start the timer before extractGameFiles
  final startTime = DateTime.now();

  List<String> errorFiles = await extractGameFiles(
      mainData.argument['pendingFiles'],
      mainData.argument['processedFiles'],
      mainData.options,
      mainData.argument['enemyList'],
      List.from(mainData.argument['activeOptions'])
        ..addAll(getAllPossibleOptions(mainData.argument[
            'input'])), // <--- Sneaky workaround to get all extracted, no matter what was selected as the active option. ;)
      mainData.sendPort,
      isManagerFile: mainData.isManagerFile);

  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);
  mainData.sendPort.send(
      '''Time for extracting the game files with the Rust DLL: ${duration.inSeconds} seconds. 
      
█ █         █ █  RUST RUST RUST 
▀█  ▄█████▄  █▀
 ▀▄███▀█▀███▄▀   
 ▄▀███▀▀▀███▀▄ 
 █ ▄▀▀▀▀▀▀▀▄ █ 

 ''');

  handleExtractErrors(errorFiles);

  mainData.sendPort
      .send('Extraction of game files in parallel finished successfully!');

  if (!mainData.isManagerFile!) {
    if (mainData.backUp!) {
      mainData.sendPort.send(
          'Creating three backup extracted game folders for modifications in upper directory (9GB disk space)...');

      // Collects the files for modification out of the extracted files to be processed
      var collectedFiles =
          collectExtractedGameFiles(mainData.argument['input']);

      // Helper method to copy the collected files to the upper directory
      await CountRuntime().runWithTimer(
          copyCollectedGameFiles, [collectedFiles, mainData.argument['input']],
          sendPort: mainData.sendPort);
      mainData.sendPort.send('Copying finished.');
    }
  }
}
