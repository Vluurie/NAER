import 'dart:async';
import 'dart:io';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/process_collected_xml_files.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';

/// Counter for processed files
int fileCount = 0;

/// Modifies enemies in a given directory based on sorted enemies data.
///
/// This method uses the sorted enemies data and modifies the enemies found
/// in the specified directory according to the provided enemy level and category.
///
/// [directoryPath] is the path to the directory containing enemy files.
/// [sortedEnemiesPath] is the path to the sorted enemies data file.
/// [enemyLevel] specifies the level of enemies to be modified.
/// [enemyCategory] specifies the category of enemies to be modified.
Future<void> processEnemies(MainData mainData,
    Map<String, List<String>> collectedFiles, String currentDir) async {
  Map<String, List<String>> sortedEnemyData =
      await getSortedEnemyData(mainData.sortedEnemiesPath!);
  await findEnemiesAndModify(
      collectedFiles, currentDir, sortedEnemyData, mainData);
}

/// Retrieves the sorted enemy data either from the provided path or the entire enemy data.
///
/// If the [sortedEnemiesPath] is 'ALL', it returns the entire enemy data map.
/// Otherwise, it reads the sorted enemy data groups from the specified file.
///
/// [sortedEnemiesPath] is the path to the sorted enemies data file or 'ALL'.
///
/// Returns a map where the keys are enemy IDs and the values are lists of enemy attributes.
Future<Map<String, List<String>>> getSortedEnemyData(
    String sortedEnemiesPath) async {
  if (sortedEnemiesPath == 'ALL') {
    return SortedEnemyGroup.enemyData; // If "ALL", use the entire enemyData map
  } else {
    return readSortedEnemyDataGroups(
        sortedEnemiesPath); // Otherwise, read from the file
  }
}

/// Finds and modifies enemies in the specified directory.
///
/// This method searches the given directory for enemy files, loads important IDs,
/// and modifies the enemies based on the sorted enemy data, level, and category.
///
/// [directoryPath] is the path to the directory containing enemy files.
/// [sortedEnemyData] is the map of sorted enemy data.
/// [enemyLevel] specifies the level of enemies to be modified.
/// [enemyCategory] specifies the category of enemies to be modified.
Future<void> findEnemiesAndModify(
    Map<String, List<String>> collectedFiles,
    String directoryPath,
    Map<String, List<String>> sortedEnemyData,
    MainData mainData) async {
  // Start the timer
  final stopwatch = Stopwatch()..start();

  // Load ImportantIDs with the metadata added IDs
  var ids = await ImportantIDs.loadIdsFromMetadata(await getMetaDataPath());

  final Directory directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    return;
  }

  fileCount = await traverseDirectory(
      collectedFiles, directory, sortedEnemyData, ids, mainData);

  // Stop the timer
  stopwatch.stop();
  mainData.sendPort
      .send('Traversal complete. Randomizer processed $fileCount files.');
  mainData.sendPort.send(
      'Time taken to find and modify enemies: ${stopwatch.elapsedMilliseconds} ms');
}

/// Traverses the directory to process files and directories.
///
/// This method recursively traverses the directory, processes each XML file it finds in parallel (with [IsolateService])
/// according to the provided sorted enemy data, level, and category, and counts the processed files.
///
/// [directory] is the directory to traverse.
/// [sortedEnemyData] is the map of sorted enemy data.
/// [enemyLevel] specifies the level of enemies to be modified.
/// [enemyCategory] specifies the category of enemies to be modified.
/// [ids] is the ImportantIDs object containing metadata IDs.
///
/// Returns the count of processed files.
///
Future<int> traverseDirectory(
    Map<String, List<String>> collectedFiles,
    Directory directory,
    Map<String, List<String>> sortedEnemyData,
    ImportantIDs ids,
    MainData mainData) async {
  int localFileCount = 0;

  // Use IsolateService for processing XML files in parallel
  final isolateService = IsolateService();

  // Combine all XML files from the collectedFiles map into a single list
  final List<String> xmlFiles = [
    ...?collectedFiles['xmlFiles'],
  ].where((file) => file.endsWith('.xml')).toList();

  // Distribute files among cores
  final distributedFiles = isolateService.distributeFiles(xmlFiles);

  // Create batched tasks to process the files
  final tasks = <FutureOr<void> Function()>[];
  distributedFiles.forEach((coreIndex, files) {
    tasks.add(() async {
      for (var file in files) {
        await processCollectedXmlFileForRandomization(
            File(file), sortedEnemyData, ids, mainData);
      }
    });
  });

  // Run tasks in parallel
  await isolateService.runTasks(tasks);

  localFileCount = xmlFiles.length;
  return localFileCount;
}
