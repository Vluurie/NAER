import 'dart:async';
import 'dart:io';

import 'package:NAER/naer_services/XmlElementHandler/handle_xml_elements.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_values.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/process_collected_xml_files.dart';
import 'package:NAER/naer_utils/isolate_service.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:xml/xml.dart';

int processedFileCount = 0;

/// Randomizes and sets a new enemy number for the given action XML element.
///
/// Selects a new random enemy number from the user-selected data map and
/// replaces the text in the XML element with this new number. It also ensures that
/// an infinite loop is avoided by limiting the number of iterations.
/// After it modifies also the set values of the specific em element if present in the em value map.
Future<void> randomizeEnemyNumber(
    final EnemyEntityObjectAction action, final String group) async {
  if (action.randomizeAndSetValues) {
    final List<String> enemyNumbers = action.userSelectedEnemyData[group]!;
    String newEmNumber;

    // Set to avoid duplicate checks and speed up lookups
    // i check for em3004 because if he get's used for rando, they got no fall down animation and stay in the air
    final Set<String> invalidNumbers = {'em3004'};
    if (action.isSpawnActionTooSmall) {
      invalidNumbers.addAll(enemyNumbers.where(isBigEnemy));
    }

    // Filter valid enemy numbers beforehand
    final List<String> validEnemyNumbers = enemyNumbers
        .where((final enemyNum) => !invalidNumbers.contains(enemyNum))
        .toList();

    // Check if there are any valid enemy numbers available
    if (validEnemyNumbers.isEmpty) {
      newEmNumber = action.objIdElement.innerText;
    } else {
      // Get a random valid enemy number
      newEmNumber = validEnemyNumbers[random.nextInt(validEnemyNumbers.length)];
    }

    // Replace the text in the XML element with the new enemy number
    XmlElementHandler.replaceTextInXmlElement(action.objIdElement, newEmNumber);
    // Set specific values for the new enemy number
    await setSpecificValues(action.objIdElement, newEmNumber);
  }
}

/// main enemy modify method
Future<void> processEnemies(
    final MainData mainData,
    final Map<String, List<String>> collectedFiles,
    final String currentDir) async {
  Map<String, List<String>> sortedEnemyData =
      await getSortedEnemyData(mainData);
  await findEnemiesAndModify(
      collectedFiles, currentDir, sortedEnemyData, mainData);
}

/// Retrieves the sorted enemy data either from the provided path or the entire enemy data.
///
/// If the [sortedEnemyGroupsIdentifierMap] is 'ALL', it returns the entire enemy data map.
/// Otherwise, it reads the sorted enemy data groups from the provider.
///
/// Returns a map where the keys are enemy IDs and the values are lists of enemy attributes.
Future<Map<String, List<String>>> getSortedEnemyData(
    final MainData mainData) async {
  if (mainData.sortedEnemyGroupsIdentifierMap == 'ALL') {
    // If "ALL", return the entire enemy data map, possibly filtered by DLC
    return SortedEnemyGroup.getDLCFilteredEnemyData(hasDLC: mainData.hasDLC);
  } else if (mainData.sortedEnemyGroupsIdentifierMap == 'CUSTOM_SELECTED') {
    final sortedEnemyData = mainData.argument['customSelectedEnemies'];
    if (sortedEnemyData.isEmpty) {
      throw ArgumentError(
          "Sorted enemy data is empty. Ensure that it has been updated correctly.");
    }
    return sortedEnemyData;
  } else {
    throw ArgumentError(
        "Invalid Sorted Enemy Data Identifier Value: ${mainData.sortedEnemyGroupsIdentifierMap}");
  }
}

/// Searches the given directory for enemy files, loads important IDs,
/// and modifies the enemies based on the sorted enemy data, level, and category.
Future<void> findEnemiesAndModify(
    final Map<String, List<String>> collectedFiles,
    final String directoryPath,
    final Map<String, List<String>> sortedEnemyData,
    final MainData mainData) async {
  // Start the timer
  final stopwatch = Stopwatch()..start();

  // Load ImportantIDs with the metadata added IDs
  var ids = await ImportantIDs.loadIdsFromMetadata(await getMetaDataPath());

  final Directory directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    return;
  }

  processedFileCount = await traverseDirectory(
      collectedFiles, directory, sortedEnemyData, ids, mainData);

  // Stop the timer
  stopwatch.stop();
  mainData.sendPort
      .send('Traversal complete. NAER processed $processedFileCount files.');
  mainData.sendPort.send(
      'Time taken to find and modify enemies: ${stopwatch.elapsedMilliseconds} ms');
}

/// Recursively traverses the directory, processes each XML file it finds in parallel (with [IsolateService])
/// according to the provided sorted enemy data, level, and category, and counts the processed files.

Future<int> traverseDirectory(
  final Map<String, List<String>> collectedFiles,
  final Directory directory,
  final Map<String, List<String>> sortedEnemyData,
  final ImportantIDs ids,
  final MainData mainData,
) async {
  // Instantiate IsolateService without auto-initialization.
  final isolateService = IsolateService();

  final List<String> xmlFiles = collectedFiles['xmlFiles']
          ?.where((final file) => file.endsWith('.xml'))
          .toList() ??
      [];

  // Distribute the XML files across the available cores for parallel processing
  final distributedFiles = await isolateService.distributeFilesAsync(xmlFiles);

  mainData.sendPort.send('Creating Isolates for parallel computing...');

  // Initialize isolates explicitly for parallel processing
  await isolateService.initialize();

  // Create tasks to process XML files in parallel using isolates
  final tasks = distributedFiles.entries.map((final entry) {
    return (final dynamic _) async {
      for (var file in entry.value) {
        await processCollectedXmlFileForRandomization(
            File(file), sortedEnemyData, ids, mainData);
      }
    };
  }).toList();

  // Run all tasks in parallel using the isolates
  await isolateService.runTasks(tasks);

  // Clean up the isolates after processing
  await isolateService.cleanup();

  return xmlFiles.length;
}
