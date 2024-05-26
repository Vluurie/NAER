// ignore_for_file: avoid_print

import 'dart:io';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml/handle_enemy_modification.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path/path.dart' as path;
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/xml/xmlExtension.dart';
import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/data/boss_data/nier_boss_level_list.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:NAER/naer_services/level_utils/handle_alias_level.dart';
import 'package:NAER/naer_services/level_utils/handle_boss_level.dart';
import 'package:NAER/naer_services/level_utils/handle_level.dart';

int fileCount = 0;
int enemyCount = 0;

Future<void> findEnemiesInDirectory(String directoryPath,
    String sortedEnemiesPath, String enemyLevel, String enemyCategory) async {
  Map<String, List<String>> sortedEnemyData;

  print("Settings: $enemyCategory and $enemyLevel");

  if (sortedEnemiesPath == "ALL") {
    // If "ALL", use the entire enemyData map
    sortedEnemyData = enemyData;
  } else {
    // Otherwise, read the sorted enemy data from the file
    sortedEnemyData = readSortedEnemyDataGroups(sortedEnemiesPath);
  }

  await find(directoryPath, sortedEnemyData, enemyLevel, enemyCategory);
}

Future<void> find(
    String directoryPath,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory) async {
  print('Found enemy randomizer... starting');

  Future<String> getMetaDataPath() async {
    final String settingsDirectoryPath =
        await FileChange.ensureSettingsDirectory();
    final String metadataPath =
        path.join(settingsDirectoryPath, 'ModPackage', 'mod_metadata.json');
    print("Found metadata at $metadataPath");
    return metadataPath;
  }

  // Load ImportantIDs with the metadata added IDs
  var ids = await ImportantIDs.loadFromMetadata(await getMetaDataPath());

  print(ids.entries);

  final Directory directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    print('Directory does not exist: $directoryPath');
    return;
  } else {
    print('Directory exists. Starting to process...');
  }

  List<Map<String, dynamic>> findings = [];
  int fileCount = 0;
  final stopwatch = Stopwatch()..start();

  print('Starting directory traversal...');
  fileCount = traverseDirectory(
      directory, findings, sortedEnemyData, enemyLevel, enemyCategory, ids);

  stopwatch.stop();
  print('Traversal complete. Processed $fileCount files.');
  print('Time taken: ${stopwatch.elapsed}');
  print('Total number of enemies found: $enemyCount');
}

int traverseDirectory(
    Directory directory,
    List<Map<String, dynamic>> findings,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory,
    ImportantIDs ids) {
  int localFileCount = 0;
  try {
    for (var entity in directory.listSync()) {
      // print('Processing entity: ${entity.path}');
      if (entity is File && entity.path.endsWith('.xml')) {
        processXmlFile(entity, sortedEnemyData, enemyLevel, enemyCategory, ids);
        localFileCount++;
      } else if (entity is Directory) {
        localFileCount += traverseDirectory(
            entity, findings, sortedEnemyData, enemyLevel, enemyCategory, ids);
      }
    }
  } catch (e) {}
  return localFileCount;
}

Future<void> processXmlFile(
    File file,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory,
    ImportantIDs importantIds) async {
  String content = file.readAsStringSync();
  var document = xml.XmlDocument.parse(content);

  var actions = document.findAllElements('action');
  for (var action in actions) {
    var actionId = action.findElements('id').isNotEmpty
        ? action.findElements('id').first.text
        : null;

    var codeElements = action.descendants.whereType<xml.XmlElement>().where(
        (element) =>
            element.name.local == 'code' &&
            ((element.getAttribute('str')?.startsWith('EnemyGenerator') ??
                    false) ||
                (element.getAttribute('str')?.startsWith('EnemySetAction') ??
                    false) ||
                (element.getAttribute('str')?.startsWith('EnemyLayoutAction') ??
                    false) ||
                (element.getAttribute('str')?.startsWith('EnemyLayoutArea') ??
                    false) ||
                (element.getAttribute('str')?.startsWith('EnemySetArea') ??
                    false) ||
                (element
                        .getAttribute('str')
                        ?.startsWith('EntityLayoutAction') ??
                    false)));

    bool isActionImportant = false;
    if (actionId != null) {
      for (var entry in importantIds.entries) {
        if (entry.value.contains(actionId)) {
          isActionImportant = true;
          break;
        }
      }
    }

    for (var codeElement in codeElements) {
      if (codeElement.parent is xml.XmlElement) {
        var parentElement = codeElement.parent as xml.XmlElement;
        if (isActionImportant) {
          parentElement.descendants
              .whereType<xml.XmlElement>()
              .where((element) => element.name.local == 'objId')
              .forEach((objIdElement) {
            processObjId(objIdElement, sortedEnemyData, file.path, enemyLevel,
                enemyCategory,
                isImportantId: true);
          });
          break;
        } else {
          processParentElement(parentElement, sortedEnemyData, file.path,
              enemyLevel, enemyCategory);
        }
      }
    }
  }

  file.writeAsStringSync(document.toPrettyString());
}

Future<void> processParentElement(
    xml.XmlElement parentElement,
    Map<String, List<String>> sortedEnemyData,
    String filePath,
    String enemyLevel,
    String enemyCategory) async {
  var relevantElements = parentElement.children.whereType<xml.XmlElement>();
  for (var element in relevantElements) {
    processElement(
        element, sortedEnemyData, filePath, enemyLevel, enemyCategory);
  }
}

bool isBoss(objId) {
  return bossData["Boss"]?.contains(objId) ?? false;
}

Future<void> processElement(
    xml.XmlElement element,
    Map<String, List<String>> sortedEnemyData,
    String filePath,
    String enemyLevel,
    String enemyCategory) async {
  if (element.name.local == 'objId') {
    if (isBoss(element.text)) {
      processObjId(
          element, sortedEnemyData, filePath, enemyLevel, enemyCategory);
    } else if (hasAliasAncestor(element)) {
      if (enemyCategory == 'allenemies' ||
          enemyCategory == 'onlyselectedenemies' ||
          enemyCategory == 'onlylevel') {
        await handleLeveledForAlias(element, enemyLevel, sortedEnemyData);
        return;
      } else if (enemyCategory == 'onlybosses') {
        return;
      }
    } else {
      processObjId(
          element, sortedEnemyData, filePath, enemyLevel, enemyCategory);
    }
  } else {
    element.descendants.whereType<xml.XmlElement>().forEach((desc) async {
      if (desc.name.local == 'objId') {
        if (isBoss(desc.text)) {
          processObjId(
              desc, sortedEnemyData, filePath, enemyLevel, enemyCategory);
        } else if (hasAliasAncestor(desc)) {
          if (enemyCategory == 'allenemies' ||
              enemyCategory == 'onlyselectedenemies' ||
              enemyCategory == 'onlylevel') {
            await handleLeveledForAlias(desc, enemyLevel, sortedEnemyData);
            return;
          } else if (enemyCategory == 'onlybosses') {
            return;
          }
        } else {
          processObjId(
              desc, sortedEnemyData, filePath, enemyLevel, enemyCategory);
        }
      }
    });
  }
}

/// This function handles various argument categories and processes the object ID
/// element accordingly. It checks if the object ID is a boss, handles levels,
/// and manages different enemy categories.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
/// - [filePath]: The path to the file containing enemy data.
/// - [enemyLevel]: The level of the enemy.
/// - [enemyCategory]: The category of the enemy.
/// - [isImportantId]: A boolean flag indicating if the object ID is important. Defaults to false.
Future<void> processObjId(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String filePath,
  String enemyLevel,
  String enemyCategory, {
  bool isImportantId = false,
}) async {
  final objIdValue = objIdElement.text;

  if (objIdValue.isEmpty) {
    print(
      'Error: objId value is null or empty in element: ${objIdElement.toXmlString()}',
    );
    return;
  }

  bool isBossObj = isBoss(objIdValue);

  try {
    if (isImportantId &&
        (enemyCategory == 'allenemies' ||
            enemyCategory == 'onlyselectedenemies')) {
      await handleLevel(objIdElement, enemyLevel, enemyData);
      return;
    }

    switch (enemyCategory) {
      case 'onlybosses':
        if (isImportantId) return;
        if (isBossObj) {
          await handleBossLevel(objIdElement, enemyLevel);
        } else {
          await handleOtherEnemies(
              objIdElement, userSelectedEnemyData, enemyLevel);
        }
        break;

      case 'onlyselectedenemies':
        await handleSelectedObjectIdEnemies(
            objIdElement, userSelectedEnemyData, enemyLevel);
        break;

      case 'allenemies':
        if (isBossObj) {
          await handleBossLevel(objIdElement, enemyLevel);
        } else {
          await handleSelectedObjectIdEnemies(
              objIdElement, userSelectedEnemyData, enemyLevel);
        }
        break;

      case 'onlylevel':
        if (isBossObj) {
          await handleBossLevel(objIdElement, enemyLevel);
        } else {
          await handleOnlyObjectIdLevel(
              objIdElement, userSelectedEnemyData, enemyLevel);
        }
        break;

      default:
        if (isImportantId) return;
        if (enemyCategory != 'onlylevel') {
          await handleDefaultObjectId(objIdElement, userSelectedEnemyData);
        }
        break;
    }
  } catch (e, stackTrace) {
    var trace = Trace.from(stackTrace);
    print('Error processing $objIdValue: $e');
    print('Stack trace: ${trace.toString()}');
  }
}
