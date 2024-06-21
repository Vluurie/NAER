import 'dart:io';
import 'dart:math';
import 'package:NAER/data/enemy_lists_data/nier_boss_level_list.dart';
import 'package:NAER/data/sorted_data/big_enemies_ids.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:xml/xml.dart' as xml;

Random random = Random();

/// Finds the group like Fly or Ground that contains the given enemy number.
///
/// Parameters:
/// - [emNumber]: The enemy number to search for.
/// - [enemyData]: A map of enemy data grouped by categories.
///
/// Returns the group name if found, otherwise returns null.
String? findGroupForEmNumber(
    String emNumber, Map<String, List<String>> enemyData) {
  for (var group in enemyData.keys) {
    if (enemyData[group]!.contains(emNumber)) {
      return group;
    }
  }
  return null;
}

/// Checks if the given group is an excluded group.
///
/// Parameters:
/// - [group]: The group name to check.
///
/// Returns true if the group is excluded, otherwise false.
bool isExcludedGroup(String group) {
  const excludedGroups = {'Delete'};
  return excludedGroups.contains(group);
}

/// Main random select method for the randomization of enemies
///
/// Gets a random enemy number from the specified group like Fly or Ground enemies.
///
/// Parameters:
/// - [group]: The group name from which to select a random enemy number.
/// - [sortedEnemyData]: A map of sorted enemy data grouped by categories.
///
/// Returns a randomly selected enemy number from the group.
String getRandomEmNumberFromGroup(
    String group, Map<String, List<String>> sortedEnemyData) {
  var groupList = List.from(sortedEnemyData[group]!);
  groupList.shuffle(); // Shuffle for better randomness
  return groupList[random.nextInt(groupList.length)];
}

/// Reads sorted enemy data groups from the created temp_sorted_enemies.dart file.
///
/// Parameters:
/// - [filePath]: The path to the file containing the sorted enemy data.
///
/// Returns a map of sorted enemy data grouped by categories.
///
/// Throws an exception if the file does not exist or an error occurs while reading the file.
Map<String, List<String>> readSortedEnemyDataGroups(String filePath) {
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

    return sortedEnemyData;
  } catch (e) {
    throw Exception('Error reading sorted enemy data: $e');
  }
}

/// Checks if the given XML element has an ancestor with an alias.
///
/// This function traverses the ancestors of the provided XML element to determine
/// if any ancestor contains an 'alias' element. This is important to avoid
/// randomness in behavior for enemies that are tagged with an alias and may have
/// hardcoded behavior.
///
/// Parameters:
/// - `objIdElement`: The XML element to check for alias ancestors.
///
/// Returns:
/// A boolean value indicating whether the element has an ancestor with an alias (`true`) or not (`false`).
bool hasAliasAncestor(xml.XmlElement objIdElement) {
  // Check if any ancestor of objIdElement contains an 'alias' element
  return objIdElement.ancestors
      .any((element) => element.findElements('alias').isNotEmpty);
}

/// Checks if the given `objId` corresponds to a boss.
///
/// Takes an `objId` and checks if it exists within the "Boss" list
/// in the `bossData` map. If the `objId` is found in the list, it returns `true`,
/// indicating that the object is a boss. Otherwise, it returns `false`.
///
/// Parameters:
/// - `objId`: The object ID to be checked.
///
/// Returns:
/// A boolean value indicating whether the `objId` is a boss (`true`) or not (`false`).
bool isBoss(objId) {
  // Check if the bossData map contains a "Boss" key and if it includes the objId
  return bossData["Boss"]?.contains(objId) ?? false;
}

/// Checks if the given `objId` corresponds to a big enemy.
///
/// Takes an `objId` and checks if it exists within the "bigEnemies" list
/// in the `bossEnemies` list. If the `objId` is found in the list, it returns `true`,
/// indicating that the object is a big enemy. Otherwise, it returns `false`.
///
/// Parameters:
/// - `objId`: The object ID to be checked.
///
/// Returns:
/// A boolean value indicating whether the `objId` is a big enemy (`true`) or not (`false`).
bool isBigEnemy(String objId) {
  for (var enemy in bigEnemies) {
    if (objId == enemy) {
      return true;
    }
  }
  return false;
}

/// Checks if a given action ID is listed in a collection of important IDs and
/// updates the importance status of the action.
///
/// This function iterates through the entries of the `importantIds` map, and
/// checks if the `actionId` exists within the values of the map. If the `actionId`
/// is found, it sets the `isActionImportant` flag to `true`.
///
/// Parameters:
/// - `actionId`: A nullable string representing the current action ID to be checked.
/// - `importantIds`: An instance of the `ImportantIDs` class containing a map of
///   important IDs.
/// - `isActionImportant`: A boolean flag indicating if the action is important. This
///   flag will be updated if the `actionId` is found within the important IDs.
///
/// Returns:
/// A boolean value indicating whether the action is important (`true`) or not (`false`).
///
/// Note:
/// - The `isActionImportant` parameter is modified within the function. The initial
///   value of this parameter should be passed as `false` unless it's already known to
///   be important.
bool checkImportantIds(
    String? actionId, ImportantIDs importantIds, bool isActionImportant) {
  // Check if the actionId is not null
  if (actionId != null) {
    // Iterate through each entry in the importantIds map
    for (var entry in importantIds.entries) {
      // Check if the entry's value contains the actionId
      if (entry.value.contains(actionId)) {
        // Set isActionImportant to true if actionId is found
        isActionImportant = true;
        break;
      }
    }
  }
  // Return the updated importance status
  return isActionImportant;
}

/// Checks if a given action ID is listed in a collection of bigSpawnEnemySkipIds and
/// updates the status of the action.
///
/// This function iterates through the entries of the `bigSpawnEnemySkipIds` map, and
/// checks if the `actionId` exists within the values of the map. If the `actionId`
/// is found, it sets the `isSpawnActionTooSmall` flag to `true`.
///
/// Parameters:
/// - `actionId`: A nullable string representing the current action ID to be checked.
/// - `bigSpawnEnemySkipIds`: Containing a map of
///   spawn IDs that are too small for big enemies.
/// - `isSpawnActionTooSmall`: A boolean flag indicating if the action is too small for big enemies. This
///   flag will be updated if the `actionId` is found within the bigSpawnEnemySkip IDs.
///
/// Returns:
/// A boolean value indicating whether the action is important (`true`) or not (`false`).
///
/// Note:
/// - The `isSpawnActionTooSmall` parameter is modified within the function. The initial
///   value of this parameter should be passed as `false` unless it's already known to
///   be important.
bool checkTooSmallSpawnAction(
    String? actionId, bigSpawnEnemySkipIds, bool isSpawnActionTooSmall) {
  // Check if the actionId is not null
  if (actionId != null) {
    // Iterate through each entry in the big spawn enemies skip map
    for (var entry in bigSpawnEnemySkipIds.entries) {
      // Check if the entry's value contains the actionId
      if (entry.value.contains(actionId)) {
        // Set isSpawnActionTooSmall to true if actionId is found
        isSpawnActionTooSmall = true;
        break;
      }
    }
  }
  // Return the updated status
  return isSpawnActionTooSmall;
}

/// NOTE that this labels are translated from the [japToEng map] and normally are japanese
///
/// Retrieves a collection of XML elements that represent enemy code actions
/// containing enemy `objId`s used to spawn the enemies.
///
/// This function filters the descendants of the given `action` XML element to
/// find 'code' elements whose 'str' attribute starts with any of the specified
/// prefixes. These prefixes are associated with various enemy-related actions
/// that include enemy `objId`s and are used for spawning enemies or other entities.
///
/// Parameters:
/// - `action`: The XML element whose descendants are to be searched.
///
/// Returns:
/// An iterable collection of XML elements that match the criteria and are used
/// to spawn enemies or other object entities in the scripting engine.
Iterable<xml.XmlElement> getEnemyCodeElements(xml.XmlElement action) {
  const prefixes = [
    'EnemyGenerator',
    'EnemySetAction',
    'EnemyLayoutAction',
    'EnemyLayoutArea',
    'EnemySetArea',
    'EntityLayoutAction'
  ];

  // Filter descendants to find 'code' elements with 'str' attributes so it get's the translated str starting with any of the prefixes
  return action.descendants.whereType<xml.XmlElement>().where((e) =>
      e.name.local == 'code' &&
      prefixes.any((p) => e.getAttribute('str')?.startsWith(p) ?? false));
}
