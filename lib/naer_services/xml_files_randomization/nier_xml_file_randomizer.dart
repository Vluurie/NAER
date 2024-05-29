import 'dart:io';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/process_collected_xml_files.dart';
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
Future<void> processEnemies(String directoryPath, String sortedEnemiesPath,
    String enemyLevel, String enemyCategory) async {
  Map<String, List<String>> sortedEnemyData =
      await getSortedEnemyData(sortedEnemiesPath);
  await findEnemiesAndModify(
      directoryPath, sortedEnemyData, enemyLevel, enemyCategory);
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
    return enemyData; // If "ALL", use the entire enemyData map
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
    String directoryPath,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory) async {
  // Load ImportantIDs with the metadata added IDs
  var ids = await ImportantIDs.loadIdsFromMetadata(await getMetaDataPath());

  final Directory directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    return;
  }

  fileCount = await traverseDirectory(
      directory, sortedEnemyData, enemyLevel, enemyCategory, ids);

  print('Traversal complete. Randomizer processed $fileCount files.');
}

/// Traverses the directory to process files and directories.
///
/// This method recursively traverses the directory, processes each XML file it finds
/// according to the provided sorted enemy data, level, and category, and counts the processed files.
///
/// [directory] is the directory to traverse.
/// [sortedEnemyData] is the map of sorted enemy data.
/// [enemyLevel] specifies the level of enemies to be modified.
/// [enemyCategory] specifies the category of enemies to be modified.
/// [ids] is the ImportantIDs object containing metadata IDs.
///
/// Returns the count of processed files.
Future<int> traverseDirectory(
    Directory directory,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory,
    ImportantIDs ids) async {
  int localFileCount = 0;

  try {
    await for (var entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.xml')) {
        await processCollectedXmlFileForRandomization(
            entity, sortedEnemyData, enemyLevel, enemyCategory, ids);
        localFileCount++;
      } else if (entity is Directory) {
        localFileCount += await traverseDirectory(
            entity, sortedEnemyData, enemyLevel, enemyCategory, ids);
      }
    }
  } catch (e) {
    print(e);
  }

  return localFileCount;
}
