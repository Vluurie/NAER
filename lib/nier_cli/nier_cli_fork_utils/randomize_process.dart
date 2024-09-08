import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:NAER/naer_services/file_utils/nier_category_manager.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_input.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';

Future<void> repackModifiedGameFiles(
    final Map<String, List<String>> collectedFiles,
    final MainData mainData) async {
  mainData.sendPort.send("Started repacking process of modified game files...");

  // Prepare XML files by replacing .yax extension with .xml
  var xmlFiles = collectedFiles['yaxFiles']
          ?.map((final e) => e.replaceAll('.yax', '.xml'))
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
/// splitting the task into the number of cores a device has for maximum computation efficiency.
/// See [IsolateService]
Future<void> processEntitiesInParallel(
    final Iterable<String> entities, final MainData mainData) async {
  // Instantiate IsolateService without auto-initialization.
  final service = IsolateService();
  mainData.sendPort.send('Creating Isolates for parallel repacking...');

  // Initialize isolates explicitly for this task
  await service.initialize();

  final fileList = entities.toList();

  // Distribute the files across the available cores
  final fileBatches = await service.distributeFilesAsync(fileList);

  // Prepare tasks to be run in parallel using isolates
  final tasks = fileBatches.values.map((final files) {
    return (final dynamic _) async {
      await processEntities(files, mainData);
    };
  }).toList();

  // Run all tasks in parallel using the isolates
  await service.runTasks(tasks);

  // Clean up the isolates after processing
  await service.cleanup();
}

Future<void> processEntities(
    final Iterable<String> entities, final MainData mainData) async {
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
          mainData.sendPort,
          isManagerFile: mainData.isManagerFile);
      processedFiles.add(file);
    } catch (e) {
      mainData.sendPort.send("Input error: $e");
    }
  }
}

/// Processes DAT folders based on the given criteria.
///
/// Checks each DAT folder with the shouldProcessDatFolder method
/// and then processes it till the output path.
///
/// logState adds all created files to the last randomized shared preference list that can be undone with the undo button.
Future<void> processDatFolders(final FileCategoryManager fileManager,
    final List<String>? datFolders, final MainData mainData) async {
  if (datFolders == null) return;

  final List<Map<String, dynamic>> fileChanges = [];

  final tasks = datFolders.map((final datFolder) async {
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
            mainData.sendPort,
            isManagerFile: mainData.isManagerFile);

        // Collect the file change details
        fileChanges.add({
          'filePath': datOutput,
          'action': 'create',
          'isAddition': mainData.isAddition
        });
      } catch (e, stackTrace) {
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

  // After all tasks are completed, send all collected file changes back to the main isolate
  mainData.sendPort.send({
    'event': 'file_changes_batch',
    'fileChanges': fileChanges,
  });
}

/// Determines whether a .dat folder should be processed.
bool shouldProcessDatFolder(
    final String baseNameWithExtension,
    final List<String> enemyList,
    final FileCategoryManager fileManager,
    final List<String> ignoreList) {
  // Check if the file should be ignored
  if (ignoreList.contains(baseNameWithExtension) ||
      baseNameWithExtension.startsWith('r5a5')) {
    return false;
  }

  // If the file is an enemy file, check if it should be processed
  if (baseNameWithExtension.startsWith('em')) {
    if (enemyList.isNotEmpty && !enemyList.contains('None')) {
      var cleanedEnemyList = enemyList
          .map((final criteria) =>
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

/// Processes the directory for pending files.
///
/// This function scans the current directory (recursively if specified)
/// and adds files to the pending files list.
///
Future<void> getGameFilesForProcessing(
    final String currentDir, final MainData mainData) async {
  mainData.sendPort.send("Starting processing in directory: $currentDir");
  List<String> pendingFiles = mainData.argument['pendingFiles'];
  Set<String> processedFiles = mainData.argument['processedFiles'];

  final directory = Directory(currentDir);
  final stream = mainData.options.recursiveMode
      ? directory.list(recursive: true)
      : directory.list();

  await for (final entity in stream) {
    if (entity is File && !processedFiles.contains(entity.path)) {
      pendingFiles.add(entity.path);
    }
  }
}

/// Processes the files from the pending list.
///
/// This function processes each file in the pending list and adds it to the
/// processed files list upon successful processing.
///
/// ALWAYS recursively extracts the child files after extracting the parent.
/// It uses the [extract_dat_files.dll]
Future<List<String>> extractGameFiles(
    final List<String> pendingFiles,
    final Set<String> processedFiles,
    final CliOptions options,
    final List<String> enemyList,
    final List<String> activeOptions,
    final SendPort sendPort,
    {required final bool? isManagerFile}) async {
  // Instantiate IsolateService without auto-initialization.
  final isolateService = IsolateService();
  final List<String> errorFiles = [];

  // Distribute the pending files across the available cores for parallel processing.
  final fileBatches = await isolateService.distributeFilesAsync(pendingFiles);

  // Initialize isolates explicitly for parallel processing.
  await isolateService.initialize();

  // Create tasks to process each batch of files in parallel using isolates.
  final tasks = fileBatches.values.map((final batch) {
    return (final dynamic _) async {
      final batchErrors = await _processFileBatch(
        batch,
        processedFiles,
        options,
        ListQueue<String>.from(batch),
        enemyList,
        activeOptions,
        isManagerFile,
        sendPort,
      );
      // Collect any errors encountered during processing.
      errorFiles.addAll(batchErrors);
    };
  }).toList();

  // Run all tasks in parallel using the isolates.
  await isolateService.runTasks(tasks);

  // Clean up the isolates after processing.
  await isolateService.cleanup();

  // Return the list of files that encountered errors during processing.
  return errorFiles;
}

Future<List<String>> _processFileBatch(
  final List<String> batch,
  final Set<String> processedFiles,
  final CliOptions options,
  final ListQueue<String> pendingFiles,
  final List<String> enemyList,
  final List<String> activeOptions,
  final bool? ismanagerFile,
  final SendPort sendPort,
) async {
  final List<String> errorFiles = [];

  while (pendingFiles.isNotEmpty) {
    final input = pendingFiles.removeFirst();
    if (processedFiles.contains(input)) continue;
    final fileType = path.extension(input).toLowerCase();

    try {
      await handleInput(input, null, options, pendingFiles, processedFiles,
          enemyList, activeOptions, sendPort,
          isManagerFile: ismanagerFile);
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
