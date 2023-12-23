import 'dart:io';
import 'dart:math';
import 'package:NAER/enemyData/bossList.dart';
import 'package:NAER/enemyData/importantIds.dart';
import 'package:NAER/enemyData/setType.dart';
import 'package:NAER/fileTypeUtils/xml/xmlExtension.dart';
import 'package:NAER/naerServices/handleAliasLevel.dart';

import 'package:NAER/naerServices/handleBossLevel.dart';
import 'package:NAER/naerServices/level_handler.dart';
import 'package:xml/xml.dart' as xml;
import '../enemyData/sorted_enemy.dart';

int fileCount = 0;
int enemyCount = 0;

Random random = Random();

void logMessage(String message) {
  final logFile = File('log.txt');
  logFile.writeAsStringSync('$message\n', mode: FileMode.append);
}

void printAndLog(String message) {
  print(message);
  logMessage(message);
}

Future<void> findEnemiesInDirectory(String directoryPath,
    String sortedEnemiesPath, String enemyLevel, String enemyCategory) async {
  Map<String, List<String>> sortedEnemyData;

  print("Settings: $enemyCategory and $enemyLevel");

  if (sortedEnemiesPath == "ALL") {
    // If "ALL", use the entire enemyData map
    sortedEnemyData = enemyData;
  } else {
    // Otherwise, read the sorted enemy data from the file
    sortedEnemyData = await readSortedEnemyData(sortedEnemiesPath);
  }

  await find(directoryPath, sortedEnemyData, enemyLevel, enemyCategory);
}

Map<String, List<String>> readSortedEnemyData(String filePath) {
  var file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('Sorted enemy data file does not exist: $filePath');
  }

  try {
    var content = file.readAsStringSync();
    var sortedEnemyData = <String, List<String>>{};
    var matches =
        RegExp(r'"(\w+)": \[(.*?)\]', multiLine: true).allMatches(content);
    for (var match in matches) {
      var group = match.group(1)!;
      var enemiesStr = match.group(2)!.replaceAll(RegExp(r'[\[\]"]'), '');
      var enemies = enemiesStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      sortedEnemyData[group] = enemies;
    }
    print("Sorted Enemy Data: $sortedEnemyData");

    return sortedEnemyData;
  } catch (e) {
    throw Exception('Error reading sorted enemy data: $e');
  }
}

Future<void> find(
    String directoryPath,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory) async {
  print('Found enemy randomizer... starting');

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
      directory, findings, sortedEnemyData, enemyLevel, enemyCategory);

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
    String enemyCategory) {
  int localFileCount = 0;
  try {
    for (var entity in directory.listSync()) {
      print('Processing entity: ${entity.path}');
      if (entity is File && entity.path.endsWith('.xml')) {
        processXmlFile(entity, sortedEnemyData, enemyLevel, enemyCategory,
            important_ids); // Use sortedEnemyData here
        localFileCount++;
      } else if (entity is Directory) {
        localFileCount += traverseDirectory(
            entity, findings, sortedEnemyData, enemyLevel, enemyCategory);
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
    Map<String, List<String>> importantIds) async {
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
          enemyCategory == 'onlyselectedenemies') {
        await handleLeveledForAlias(element, enemyLevel, sortedEnemyData);
        return; // Return after handling alias level
      } else if (enemyCategory == 'onlybosses') {
        return; // Return for onlybosses category
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
              enemyCategory == 'onlyselectedenemies') {
            await handleLeveledForAlias(desc, enemyLevel, sortedEnemyData);
            return; // Return after handling alias level
          } else if (enemyCategory == 'onlybosses') {
            return; // Return for onlybosses category
          }
        } else {
          processObjId(
              desc, sortedEnemyData, filePath, enemyLevel, enemyCategory);
        }
      }
    });
  }
}

// Helper function to find 'value' element with a specific 'name'
xml.XmlElement? findValueElementWithName(xml.XmlElement element, String name) {
  var nameElements = element.findElements('name');
  if (nameElements.isNotEmpty) {
    var nameText = nameElements.first.text;
    if (nameText == name) {
      return element;
    }
  }

  // Search within nested 'value' elements
  for (var nestedValue in element.findElements('value')) {
    var result = findValueElementWithName(nestedValue, name);
    if (result != null) {
      return result;
    }
  }

  return null;
}

Future<void> processObjId(
    xml.XmlElement objIdElement,
    Map<String, List<String>> userSelectedEnemyData,
    String filePath,
    String enemyLevel,
    String enemyCategory,
    {bool isImportantId = false}) async {
  final objIdValue = objIdElement.text;

  if (objIdValue.isEmpty) {
    printAndLog(
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
      return; // Skip further processing for this important ID
    }

    // Standard processing for other cases
    switch (enemyCategory) {
      case 'onlybosses':
        if (isImportantId) {
          return;
        } else if (isBossObj) {
          await handleBossLevel(objIdElement, enemyLevel);
        } else {
          await handleOtherEnemies(
              objIdElement, userSelectedEnemyData, enemyLevel);
        }
        break;
      case 'onlyselectedenemies':
        await handleSelectedEnemies(
            objIdElement, userSelectedEnemyData, enemyLevel);
        break;
      case 'allenemies':
        if (isBossObj) {
          await handleBossLevel(objIdElement, enemyLevel);
        } else {
          await handleSelectedEnemies(
              objIdElement, userSelectedEnemyData, enemyLevel);
        }
        break;
      default:
        if (isImportantId) {
          return;
        } else {
          await handleDefault(objIdElement, userSelectedEnemyData);
        }
        break;
    }
  } catch (e) {
    printAndLog('Error processing $objIdValue: $e');
  }
}

Future<void> handleOtherEnemies(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  String? group = findGroupForEmNumber(objIdElement.text, enemyData);

  if (group != null &&
      !isExcludedGroup(group) &&
      userSelectedEnemyData[group]?.isNotEmpty == true) {
    String newEmNumber = userSelectedEnemyData[group]![
        random.nextInt(userSelectedEnemyData[group]!.length)];
    replaceTextInXmlElement(objIdElement, newEmNumber);
    enemyCount++;
    setSpecificValues(objIdElement, newEmNumber);
  }
}

Future<void> handleSelectedEnemies(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  String? group = findGroupForEmNumber(objIdElement.text, enemyData);

  if (group != null &&
      !isExcludedGroup(group) &&
      userSelectedEnemyData[group]?.isNotEmpty == true) {
    String newEmNumber = userSelectedEnemyData[group]![
        random.nextInt(userSelectedEnemyData[group]!.length)];
    replaceTextInXmlElement(objIdElement, newEmNumber);
    enemyCount++;
    setSpecificValues(objIdElement, newEmNumber);
    await handleLevel(objIdElement, enemyLevel, enemyData);
  }
}

Future<void> handleDefault(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
) async {
  String? group = findGroupForEmNumber(objIdElement.text, enemyData);

  if (group != null &&
      !isExcludedGroup(group) &&
      userSelectedEnemyData[group]?.isNotEmpty == true) {
    String newEmNumber = userSelectedEnemyData[group]![
        random.nextInt(userSelectedEnemyData[group]!.length)];
    replaceTextInXmlElement(objIdElement, newEmNumber);
    enemyCount++;
    setSpecificValues(objIdElement, newEmNumber);
  }
}

bool isExcludedGroup(String group) {
  const excludedGroups = {'Delete'};
  return excludedGroups.contains(group);
}

bool hasAliasOrAncestorAlias(xml.XmlElement objIdElement) {
  if (objIdElement.getAttribute('alias') != null) {
    return true;
  }

  for (var ancestor in objIdElement.ancestors) {
    if (ancestor is xml.XmlElement && ancestor.getAttribute('alias') != null) {
      return true;
    }
  }

  return false;
}

bool hasAliasAncestor(xml.XmlElement objIdElement) {
  return objIdElement.ancestors
      .any((element) => element.findElements('alias').isNotEmpty);
}

void updateElement(
    xml.XmlElement objIdElement, String elementName, String value) {
  var parentValueElement = objIdElement.parent;
  if (parentValueElement != null && parentValueElement is xml.XmlElement) {
    var elements = parentValueElement.findElements(elementName);
    if (elements.isNotEmpty) {
      elements.first.children.clear();
      elements.first.children.add(xml.XmlText(value));
    }
  }
}

dynamic xmlToJson(xml.XmlNode node) {
  if (node is xml.XmlElement) {
    final Map<String, dynamic> jsonMap = {};

    // Handle attributes
    if (node.attributes.isNotEmpty) {
      jsonMap['@attributes'] = {
        for (var a in node.attributes) a.name.local: a.value
      };
    }

    // Handle child nodes
    for (var child in node.children) {
      if (child is xml.XmlElement) {
        var childJson = xmlToJson(child);
        if (jsonMap.containsKey(child.name.local)) {
          // If the same element is repeated, create a list
          if (jsonMap[child.name.local] is! List) {
            jsonMap[child.name.local] = [jsonMap[child.name.local]];
          }
          jsonMap[child.name.local].add(childJson);
        } else {
          jsonMap[child.name.local] = childJson;
        }
      } else if (child is xml.XmlText && child.text.trim().isNotEmpty) {
        return child.text.trim();
      }
    }

    return jsonMap;
  } else if (node is xml.XmlText && node.text.trim().isNotEmpty) {
    return node.text.trim();
  }

  return {};
}

int compareFilePaths(String a, String b) {
  var aParts = a.split('/');
  var bParts = b.split('/');

  // Compare folder names
  int folderCompare = aParts[0].compareTo(bParts[0]);
  if (folderCompare != 0) {
    return folderCompare;
  }

  // If folder names are the same, compare file names
  return aParts[1].compareTo(bParts[1]);
}

String? findGroupForEmNumber(
    String emNumber, Map<String, List<String>> enemyData) {
  for (var group in enemyData.keys) {
    if (enemyData[group]!.contains(emNumber)) {
      return group;
    }
  }
  return null;
}

String getRandomEmNumberFromGroup(
    String group, Map<String, List<String>> sortedEnemyData) {
  var groupList = List.from(sortedEnemyData[group]!);
  groupList.shuffle(); // Shuffle the list for better randomness
  var selected = groupList[random.nextInt(groupList.length)];
  return selected;
}

void replaceTextInXmlElement(xml.XmlElement element, String newText) {
  element.children.clear();
  element.children.add(xml.XmlText(newText));
}
