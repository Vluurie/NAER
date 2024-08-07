import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/naer_services/file_utils/nier_category_manager.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_stats.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_input.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:path/path.dart' as path;

/// Processes the collected files based on the given parameters.
///
/// This function performs processing on XML and DAT files collected in the
/// collectedFiles map. It uses various options and file lists to determine
/// how the files should be processed.
///
/// MainData container data to use are:
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
Future<void> repackModifiedGameFiles(
    Map<String, List<String>> collectedFiles, MainData mainData) async {
  mainData.sendPort.send("Started repacking process of modified game files...");

  // Prepare XML files by replacing .yax extension with .xml
  var xmlFiles = collectedFiles['yaxFiles']
          ?.map((e) => e.replaceAll('.yax', '.xml'))
          .toList() ??
      <String>[];

  // Combine XML files and folders to process
  var entitiesToProcess = <String>[
    ...xmlFiles,
    ...?collectedFiles['pakFolders']
  ];

  if (entitiesToProcess.isNotEmpty) {
    await processEntitiesInParallel(entitiesToProcess, mainData);
  }

  var fileManager = FileCategoryManager(mainData.args);

  // Process DAT folders if they exist
  mainData.sendPort.send('Isolates created, repacking...');
  await processDatFolders(fileManager, collectedFiles['datFolders'], mainData);
}

/// This method processes all given entities in parallel,
/// splitting the task into the amount of cores a device has for maximum computation time.
/// See [IsolateService]
Future<void> processEntitiesInParallel(
    Iterable<String> entities, MainData mainData) async {
  final service = IsolateService();
  mainData.sendPort.send('Creating Isolates for parallel repacking...');

  final fileList = entities.toList();
  final fileBatches = await service.distributeFilesAsync(fileList);
  final tasks = fileBatches.values.map((files) {
    return (dynamic _) async {
      await processEntities(files, mainData);
    };
  }).toList();

  await service.runTasks(tasks);
}

/// Processes a list of entities such as files or folders.
///
/// This function iterates over the given entities and processes each entity
/// using the provided files to process
///
Future<void> processEntities(
    Iterable<String> entities, MainData mainData) async {
  final processedFiles = mainData.argument['processedFiles'] as Set<String>;
  final pendingFilesQueue =
      ListQueue<String>.from(mainData.argument['pendingFiles'] as List<String>);

  for (var file in entities) {
    if (processedFiles.contains(file)) continue;

    try {
      await handleInput(
          file,
          null,
          mainData.options,
          pendingFilesQueue,
          processedFiles,
          mainData.argument['enemyList'] as List<String>,
          mainData.argument['activeOptions'] as List<String>,
          mainData.isManagerFile,
          mainData.sendPort);
      processedFiles.add(file);
    } catch (e) {
      mainData.sendPort.send("Input error: $e");
    }
  }
}

/// Processes DAT folders based on the given criteria.
///
/// This function checks each DAT folder with the shouldProcessDatFolder method
/// and then processes it till the output path.
///
/// logState adds all created files to the last randomized shared preference list that can be undone with the undo button.
///
/// - Parameters:
///   - fileManager: A manager with lists for the categories map, quest, logic files.
///   - datFolders: A list of DAT folders to be processed.
///   - mainData: MainData container with various options and parameters for processing.
///
Future<void> processDatFolders(FileCategoryManager fileManager,
    List<String>? datFolders, MainData mainData) async {
  if (datFolders == null) return;

  final tasks = datFolders.map((datFolder) async {
    var baseNameWithExtension = path.basename(datFolder);

    // Check if the DAT folder should be processed
    if (shouldProcessDatFolder(
        baseNameWithExtension,
        mainData.argument['enemyList'] as List<String>,
        fileManager,
        mainData.argument['ignoreList'] as List<String>)) {
      try {
        var datSubFolder = getDatFolder(baseNameWithExtension);
        var datOutput =
            path.join(mainData.output, datSubFolder, baseNameWithExtension);
        await handleInput(
            datFolder,
            datOutput,
            mainData.options,
            ListQueue<String>(),
            mainData.argument['processedFiles'] as Set<String>,
            mainData.argument['enemyList'] as List<String>,
            mainData.argument['activeOptions'] as List<String>,
            mainData.isManagerFile,
            mainData.sendPort);

        // Log the file change and send it to the main isolate
        FileChange.logChange(datOutput, 'create');
        logState.addLog("Folder created: $datOutput");
        mainData.sendPort.send({
          'event': 'file_change',
          'filePath': datOutput,
          'action': 'create'
        });
      } catch (e, stackTrace) {
        logAndPrint("Failed to process DAT folder");
        logAndPrint(e.toString());

        // Send error message to the main isolate
        mainData.sendPort.send({
          'event': 'error',
          'details': "Failed to process DAT folder: ${e.toString()}",
          'stackTrace': stackTrace.toString()
        });
      }
    }
  }).toList();

  await Future.wait(tasks);
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
/// - Returns: true if the folder should be processed, false otherwise.
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

  // If the file is an enemy file, check if it should be processed
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
///   - mainData: The main data containing arguments and configurations.
///   - reverseStats: A boolean indicating whether to reverse the stats modification.
///
Future<void> processEnemyStats(
  String currentDir,
  MainData mainData,
  bool reverseStats,
) async {
  List<String> enemyList = mainData.argument['enemyList'];
  List<String> enemiesToBalance = SpecialEntities.enemiesToBalance;
  double balanceFactor = 0.1;

  List<File> enemyFiles = await findEnemyStatFiles(currentDir);
  List<File> filteredFiles =
      await filterEnemyFiles(enemyFiles, enemiesToBalance);

  if (mainData.isBalanceMode! && reverseStats != true) {
    mainData.sendPort.send("Balancing enemy stats files.");
    for (var file in filteredFiles) {
      await balanceEnemyToBalanceCsvFiles(file, balanceFactor);
    }
  }

  if (enemyList.isNotEmpty && !enemyList.contains('None')) {
    for (var file in enemyFiles) {
      await processCsvFile(file, mainData.argument['enemyStats'], reverseStats);
    }

    if (reverseStats && mainData.isBalanceMode == true) {
      mainData.sendPort.send(
          "Normalized balanced modified stats files for next modification.");
      for (var filteredFile in filteredFiles) {
        await normalizeEnemyToBalanceCsvFiles(filteredFile, balanceFactor);
      }
    }
  }
}

/// Processes the directory for pending files.
///
/// This function scans the current directory (recursively if specified)
/// and adds files to the pending files list.
///
Future<void> getGameFilesForProcessing(
    String currentDir, MainData mainData) async {
  mainData.sendPort.send(
      "Starting processing in directory: $currentDir, recursive mode: ${mainData.options.recursiveMode}");
  List<String> pendingFiles = mainData.argument['pendingFiles'];
  Set<String> processedFiles = mainData.argument['processedFiles'];

  if (mainData.options.recursiveMode) {
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
  SendPort sendPort,
) async {
  final isolateService = IsolateService();
  final List<String> errorFiles = [];

  // Convert pendingFiles to ListQueue for efficient queue operations
  final fileBatches = await isolateService.distributeFilesAsync(pendingFiles);

  final tasks = fileBatches.values.map((batch) {
    return (dynamic _) async {
      final batchErrors = await _processFileBatch(
        batch,
        processedFiles,
        options,
        ListQueue<String>.from(batch),
        enemyList,
        activeOptions,
        ismanagerFile,
        sendPort,
      );
      errorFiles.addAll(batchErrors);
    };
  }).toList();

  await isolateService.runTasks(tasks);

  return errorFiles;
}

Future<List<String>> _processFileBatch(
  List<String> batch,
  Set<String> processedFiles,
  CliOptions options,
  ListQueue<String> pendingFiles,
  List<String> enemyList,
  List<String> activeOptions,
  bool? ismanagerFile,
  SendPort sendPort,
) async {
  final List<String> errorFiles = [];

  while (pendingFiles.isNotEmpty) {
    final input = pendingFiles.removeFirst();
    if (processedFiles.contains(input)) continue;
    final fileType = path.extension(input).toLowerCase();

    try {
      await handleInput(
        input,
        null,
        options,
        pendingFiles,
        processedFiles,
        enemyList,
        activeOptions,
        ismanagerFile,
        sendPort,
      );
      processedFiles.add(input);
    } on FileHandlingException catch (e) {
      globalLog("Invalid input for file $input (File type: $fileType): $e");
      errorFiles.add(input);
    } catch (e, stackTrace) {
      globalLog("Failed to process file $input (File type: $fileType)");
      globalLog(e.toString());
      globalLog(stackTrace.toString());
      errorFiles.add(input);
    }
  }

  return errorFiles;
}
