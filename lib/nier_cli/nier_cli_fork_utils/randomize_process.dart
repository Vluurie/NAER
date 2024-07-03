import 'dart:io';
import 'dart:isolate';

import 'package:NAER/naer_services/file_utils/nier_category_manager.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_stats.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/nier_cli/cli_data_classes.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_input.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:path/path.dart' as path;

/// Processes the collected files based on the given parameters.
///
/// This function performs processing on XML and DAT files collected in the
/// `collectedFiles` map. It uses various options and file lists to determine
/// how the files should be processed.
///
/// Inizialize GamePackData with the following
/// - Parameters:
///   - currentDir: The current directory where the processing starts.
///   - collectedFiles: A map of collected files and folders with specific keys.
///   - options: CLI options that influence the processing behavior.
///   - pendingFiles: A list of files that are pending to be processed.
///   - processedFiles: A set of files that have already been processed.
///   - enemyList: A list of enemy criteria to be considered during processing.
///   - activeOptions: A list of active options for file processing.
///   - ismanagerFile: A flag indicating if a mod manager file is involved.
///   - ignoreList: A list of files or folders to be ignored during processing.
///   - output: The output directory where processed files should be saved.
///   - args: Command-line arguments passed to the program.
Future<void> repackModifiedGameFiles(GamePackData packData) async {
  // Prepare XML files by replacing .yax extension with .xml
  var xmlFiles = packData.collectedFiles['yaxFiles']
          ?.map((e) => e.replaceAll('.yax', '.xml'))
          .toList() ??
      <String>[];

  // Combine XML files and folders to process
  var entitiesToProcess = <String>[
    ...xmlFiles,
    ...?packData.collectedFiles['pakFolders']
  ];

  if (entitiesToProcess.isNotEmpty) {
    await processEntitiesInParallel(entitiesToProcess, packData);
  }

  var fileManager = FileCategoryManager(packData.args);

  // Process DAT folders if they exist
  await processDatFolders(
      fileManager, packData.collectedFiles['datFolders'], packData);
}

/// This method processes all given entities in parallel,
/// splitting the task into the amount of cores a device has for maximum computation time.
/// See [IsolateService]
Future<void> processEntitiesInParallel(
    Iterable<String> entities, GamePackData packData) async {
  final service = IsolateService();

  final fileList = entities.toList();
  final fileBatches = service.distributeFiles(fileList.cast<String>());
  final tasks = fileBatches.values.map((files) {
    return () => processEntities(files, packData);
  }).toList();

  await service.runTasks(tasks);
}

/// Processes a list of entities such as files or folders.
///
/// This function iterates over the given entities and processes each entity
/// using the provided files to process
///
Future<void> processEntities(
    Iterable<String> entities, GamePackData packData) async {
  for (var file in entities) {
    try {
      await handleInput(
          file,
          null,
          packData.options,
          packData.pendingFiles,
          packData.processedFiles,
          packData.enemyList,
          packData.activeOptions,
          packData.isManagerFile,
          packData.sendPort);
      packData.processedFiles.add(file);
    } catch (e) {
      // debugPrint("input error: $e");
    }
  }
}

/// Processes DAT folders based on the given criteria.
///
/// This function checks each DAT folder with the shouldProcessDatFolder method
/// and then processes it till the output path.
///
/// logState adds all created files to the last randomized shared preference list that can be undone with the undo button
///
Future<void> processDatFolders(FileCategoryManager fileManager,
    List<String>? datFolders, GamePackData packData) async {
  if (datFolders != null) {
    for (var datFolder in datFolders) {
      var baseNameWithExtension = path.basename(datFolder);

      // Check if the DAT folder should be processed
      if (shouldProcessDatFolder(baseNameWithExtension, packData.enemyList,
          fileManager, packData.ignoreList)) {
        try {
          var datSubFolder = getDatFolder(baseNameWithExtension);
          if (packData.output != null) {
            var datOutput = path.join(
                packData.output!, datSubFolder, baseNameWithExtension);
            await handleInput(
                datFolder,
                datOutput,
                packData.options,
                [],
                packData.processedFiles,
                packData.enemyList,
                packData.activeOptions,
                packData.isManagerFile,
                packData.sendPort);

            // Log the file change and send it to the main isolate
            FileChange.logChange(datOutput, 'create');
            logState.addLog("Folder created: $datOutput");
            packData.sendPort.send({
              'event': 'file_change',
              'filePath': datOutput,
              'action': 'create'
            });
          }
        } catch (e, stackTrace) {
          logAndPrint("Failed to process DAT folder");
          logAndPrint(e.toString());

          // Send error message to the main isolate
          packData.sendPort.send({
            'event': 'error',
            'details': "Failed to process DAT folder: ${e.toString()}",
            'stackTrace': stackTrace.toString()
          });
        }
      }
    }
  }
}

/// Determines whether a .dat folder should be processed.
///
/// This function checks the folder against the enemy list and ignore list
/// to decide if it should be processed.
///
/// - Parameters:
///   - baseNameWithExtension: The base name of the folder with its extension.
///   - enemyList: The enemy list
///   - fileManager: A manager with lists for the categories map, quest, logic files.
///   - ignoreList: The list of files to be ignored during processing.
/// - Returns: `true` if the folder should be processed, `false` otherwise.
bool shouldProcessDatFolder(
    String baseNameWithExtension,
    List<String> enemyList,
    FileCategoryManager fileManager,
    List<String> ignoreList) {
  // Check if the file should be ignored
  if (ignoreList.contains(baseNameWithExtension) ||
      baseNameWithExtension.startsWith('r5a5')) {
    return false;
  }

  // If the file is a enemy file, check if it should be processed
  if (baseNameWithExtension.startsWith('em')) {
    if (enemyList.isNotEmpty && !enemyList.contains('None')) {
      var cleanedEnemyList = enemyList
          .map((criteria) =>
              criteria.replaceAll('[', '').replaceAll(']', '').trim())
          .toList();
      for (var criteria in cleanedEnemyList) {
        if (baseNameWithExtension.contains(criteria)) {
          return true;
        }
      }
      // If none of the criteria match, do not process
      return false;
    } else {
      return false;
    }
  }

  // General file check
  var baseNameWithoutExtension =
      path.basenameWithoutExtension(baseNameWithExtension);

  return fileManager.shouldProcessFile(baseNameWithoutExtension);
}

/// Processes enemy stats based on the given enemy list.
///
/// This function modifies enemy stats if the enemy list is not empty and
/// contains enemies.
///
/// - Parameters:
///   - currentDir: The current directory where the processing starts.
///   - enemyList: A list of enemies to be considered during processing.
///   - enemyStats: The stats to be applied to the enemies.
Future<void> processEnemyStats(String currentDir, List<String> enemyList,
    double enemyStats, bool reverseStats, SendPort sendPort) async {
  if (enemyList.isNotEmpty && !enemyList.contains('None')) {
    sendPort.send("Started changing enemy stats...");
    await findEnemyStatFiles(currentDir, enemyList, enemyStats, reverseStats);
  } else {
    sendPort.send("No enemy Stats modified as argument is 'None'");
  }
}

/// Processes the directory for pending files.
///
/// This function scans the current directory (recursively if specified)
/// and adds files to the pending files list.
///
Future<void> getGameFilesForProcessing(
    String currentDir,
    CliOptions options,
    List<String> pendingFiles,
    Set<String> processedFiles,
    SendPort sendPort) async {
  sendPort.send(
      "Starting processing in directory: $currentDir, recursive mode: ${options.recursiveMode}");

  if (options.recursiveMode) {
    pendingFiles.addAll(Directory(currentDir)
        .listSync(recursive: true)
        .where((e) => e is File && !processedFiles.contains(e.path))
        .map((e) => e.path));
  } else {
    pendingFiles.addAll(Directory(currentDir)
        .listSync()
        .where((e) => e is File && !processedFiles.contains(e.path))
        .map((e) => e.path));
  }
}

/// Processes the files from the pending list.
///
/// This function processes each file in the pending list and adds it to the
/// processed files list upon successful processing.
///
/// Recursevly extracts the child files after extracting the parent
///
Future<List<String>> extractGameFiles(
    List<String> pendingFiles,
    Set<String> processedFiles,
    CliOptions options,
    List<String> enemyList,
    List<String> activeOptions,
    bool? ismanagerFile,
    SendPort sendPort) async {
  List<String> errorFiles = [];

  while (pendingFiles.isNotEmpty) {
    String input = pendingFiles.removeAt(0);
    if (processedFiles.contains(input)) continue;
    String fileType = path.extension(input).toLowerCase();

    //  logAndPrint("Processing file: $input, File type: $fileType");

    try {
      await handleInput(input, null, options, pendingFiles, processedFiles,
          enemyList, activeOptions, ismanagerFile, sendPort);
      processedFiles.add(input);
      //  logAndPrint("Successfully processed file: $input, File type: $fileType");
    } on FileHandlingException catch (e) {
      logAndPrint("Invalid input for file $input (File type: $fileType): $e");
      errorFiles.add(input);
    } catch (e, stackTrace) {
      logAndPrint("Failed to process file $input (File type: $fileType)");
      logAndPrint(e.toString());
      logAndPrint(stackTrace.toString());
      errorFiles.add(input);
    }
  }

  return errorFiles;
}
