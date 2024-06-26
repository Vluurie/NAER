import 'dart:io';

import 'package:NAER/naer_services/file_utils/nier_category_manager.dart';
import 'package:NAER/naer_services/value_utils/handle_boss_stats.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/fileTypeHandler.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

/// Processes the collected files based on the given parameters.
///
/// This function performs processing on XML and DAT files collected in the
/// `collectedFiles` map. It uses various options and file lists to determine
/// how the files should be processed.
///
/// - Parameters:
///   - currentDir: The current directory where the processing starts.
///   - collectedFiles: A map of collected files and folders with specific keys.
///   - options: CLI options that influence the processing behavior.
///   - pendingFiles: A list of files that are pending to be processed.
///   - processedFiles: A set of files that have already been processed.
///   - bossList: A list of boss criteria to be considered during processing.
///   - activeOptions: A list of active options for file processing.
///   - ismanagerFile: A flag indicating if a mod manager file is involved.
///   - ignoreList: A list of files or folders to be ignored during processing.
///   - output: The output directory where processed files should be saved.
///   - args: Command-line arguments passed to the program.
Future<void> processCollectedFiles(
    String currentDir,
    Map<String, List<String>> collectedFiles,
    CliOptions options,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> bossList,
    List<String> activeOptions,
    bool? ismanagerFile,
    List<String> ignoreList,
    String? output,
    ArgResults args) async {
  // Prepare XML files by replacing .yax extension with .xml
  var xmlFiles =
      collectedFiles['yaxFiles']?.map((e) => e.replaceAll('.yax', '.xml'));

  // Combine XML files and folders to process
  var entitiesToProcess = xmlFiles?.followedBy(collectedFiles['pakFolders']!);

  if (entitiesToProcess != null) {
    await processEntities(entitiesToProcess, options, pendingFiles,
        processedFiles, bossList, activeOptions, ismanagerFile);

    var fileManager = FileCategoryManager(args);

    // Process DAT folders if they exist
    await processDatFolders(
        collectedFiles['datFolders'],
        fileManager,
        bossList,
        ignoreList,
        output,
        options,
        processedFiles,
        activeOptions,
        ismanagerFile);
  }
}

/// Processes a list of entities such as files or folders.
///
/// This function iterates over the given entities and processes each entity
/// using the provided files to process
///
Future<void> processEntities(
    Iterable<String> entities,
    CliOptions options,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> bossList,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  for (var file in entities) {
    try {
      await handleInput(file, null, options, pendingFiles, processedFiles,
          bossList, activeOptions, ismanagerFile);
      processedFiles.add(file);
    } catch (e) {
      logAndPrint("input error");
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
Future<void> processDatFolders(
    List<String>? datFolders,
    FileCategoryManager fileManager,
    List<String> bossList,
    List<String> ignoreList,
    String? output,
    CliOptions options,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  if (datFolders != null) {
    for (var datFolder in datFolders) {
      var baseNameWithExtension = path.basename(datFolder);

      // Check if the DAT folder should be processed
      if (shouldProcessDatFolder(
          baseNameWithExtension, bossList, fileManager, ignoreList)) {
        try {
          var datSubFolder = getDatFolder(baseNameWithExtension);
          if (output != null) {
            var datOutput =
                path.join(output, datSubFolder, baseNameWithExtension);
            await handleInput(datFolder, datOutput, options, [], processedFiles,
                bossList, activeOptions, ismanagerFile);
            FileChange change = FileChange(datOutput, 'create');
            FileChange.changes.add(change);
            logState.addLog("Folder created: $datOutput");
          }
        } catch (e) {
          logAndPrint("Failed to process DAT folder");
          logAndPrint(e.toString());
        }
      }
    }
  }
}

/// Determines whether a .dat folder should be processed.
///
/// This function checks the folder against the boss list and ignore list
/// to decide if it should be processed.
///
/// - Parameters:
///   - baseNameWithExtension: The base name of the folder with its extension.
///   - bossList: The boss list
///   - fileManager: A manager with lists for the categories map, quest, logic files.
///   - ignoreList: The list of files to be ignored during processing.
/// - Returns: `true` if the folder should be processed, `false` otherwise.
bool shouldProcessDatFolder(String baseNameWithExtension, List<String> bossList,
    FileCategoryManager fileManager, List<String> ignoreList) {
  // Check if the file should be ignored
  if (ignoreList.contains(baseNameWithExtension) ||
      baseNameWithExtension.startsWith('r5a5')) {
    return false;
  }

  // If the file is a boss file, check if it should be processed
  if (baseNameWithExtension.startsWith('em')) {
    if (bossList.isNotEmpty && !bossList.contains('None')) {
      var cleanedBossList = bossList
          .map((criteria) =>
              criteria.replaceAll('[', '').replaceAll(']', '').trim())
          .toList();
      for (var criteria in cleanedBossList) {
        if (baseNameWithExtension.contains(criteria)) {
          return true;
        }
      }
      // If none of the criteria match, do not process
      return false;
    } else {
      logAndPrint("Skipping processing due to Boss List conditions.");
      return false;
    }
  }

  // General file check
  var baseNameWithoutExtension =
      path.basenameWithoutExtension(baseNameWithExtension);

  return fileManager.shouldProcessFile(baseNameWithoutExtension);
}

/// Processes boss stats based on the given boss list.
///
/// This function modifies boss stats if the boss list is not empty and
/// contains bosses.
///
/// - Parameters:
///   - currentDir: The current directory where the processing starts.
///   - bossList: A list of bosses to be considered during processing.
///   - bossStats: The stats to be applied to the bosses.
Future<void> processBossStats(
    String currentDir, List<String> bossList, double bossStats) async {
  if (bossList.isNotEmpty && !bossList.contains('None')) {
    logAndPrint("Started changing boss stats...");
    await findBossStatFiles(currentDir, bossList, bossStats);
  } else {
    logAndPrint("No Boss Stats modified as argument is 'None'");
  }
}

/// Processes the directory for pending files.
///
/// This function scans the current directory (recursively if specified)
/// and adds files to the pending files list.
///
Future<void> processDirectory(String currentDir, CliOptions options,
    List<String> pendingFiles, Set<String> processedFiles) async {
  logAndPrint(
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
Future<List<String>> processFiles(
    List<String> pendingFiles,
    Set<String> processedFiles,
    CliOptions options,
    List<String> bossList,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  List<String> errorFiles = [];

  while (pendingFiles.isNotEmpty) {
    String input = pendingFiles.removeAt(0);
    if (processedFiles.contains(input)) continue;
    String fileType = path.extension(input).toLowerCase();

    //  logAndPrint("Processing file: $input, File type: $fileType");

    try {
      await handleInput(input, null, options, pendingFiles, processedFiles,
          bossList, activeOptions, ismanagerFile);
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
