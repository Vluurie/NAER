import 'dart:io';
import 'dart:math';
import 'package:NAER/data/enemy_lists_data/nier_boss_level_list.dart';
import 'package:NAER/data/sorted_data/nier_shooting_enemy_curve_action_ids.dart';
import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
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

/// Reads sorted enemy data groups from the created [temp_sorted_enemies.dart} file.
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

// Check if any ancestor of objIdElement contains an 'alias' element
bool hasAliasAncestor(xml.XmlElement objIdElement) {
  return objIdElement.ancestors
      .any((element) => element.findElements('alias').isNotEmpty);
}

// Remove alias elements that are in the  RandomizableAliases.aliases
void removeAliases(xml.XmlElement element, List<String> aliasList) {
  // Find all alias elements in the current element and its descendants
  final aliasElements = element.findAllElements('alias').toList();

  // Process each alias element
  for (var alias in aliasElements) {
    final aliasText = alias.innerText.trim();

    // Check if the alias text matches any item in aliasList
    if (aliasList.contains(aliasText)) {
      // Remove the alias element
      alias.parent?.children.remove(alias);
    }
  }
}

/// Checks if the given `objId` corresponds to a boss.
bool isBoss(String objId) {
  return BossData.bossIds.contains(objId);
}

/// Checks if the given `objId` corresponds to a big enemy.
bool isBigEnemy(String objId) {
  return SpecialEntities.bigEnemies.contains(objId);
}

/// Checks if the given `objId` corresponds to a dlc enemy.
bool isDLCEnemy(String objId) {
  return SpecialEntities.dlcEnemies.contains(objId);
}

/// Checks if an enemy with a given `emNumber` is marked for deletion in the `enemyData`.
///
/// Returns `true` if the enemy is in the "Delete" group, `false` otherwise.
bool isDeletedEnemy(String emNumber, Map<String, List<String>> enemyData) {
  return findGroupForEmNumber(emNumber, enemyData) == "Delete";
}

/// Checks if a given action ID is listed in a collection of important IDs and
/// updates the importance status of the action.
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
bool checkTooSmallSpawnAction(String? actionId,
    Map<String, Set<String>> bigSpawnEnemySkipIds, bool isSpawnActionTooSmall) {
  // Check if the actionId is not null
  if (actionId != null) {
    // Iterate through each entry in the big spawn enemies skip map
    for (var entry in bigSpawnEnemySkipIds.entries) {
      // Check if the entry's value (Set) contains the actionId
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

/// Checks if the given `actionElement` represents an 'EnemyGenerator'.
///
/// Returns `true` if the 'code' element has the attribute `str` set to 'EnemyGenerator', `false` otherwise.
bool isEnemyGenerator(xml.XmlElement actionElement) {
  var codeElement = actionElement.findElements('code').firstOrNull;
  return codeElement != null &&
      codeElement.getAttribute('str') == 'EnemyGenerator';
}

/// Checks if the given XML element contains a ShootingEnemyCurveAction by traversing its child elements.
///
/// This function performs the following tasks:
/// - Iterates over all elements within the given [element].
/// - Collects the text of all 'id' elements.
/// - Compares these 'id' texts against a predefined set of identifiers in [ShootingEnemyCurveAction.identifierSet].
/// - Returns true if any 'id' matches an identifier in the set; otherwise, returns false.
///
/// Parameters:
/// - [element]: The XML element to check for ShootingEnemyCurveAction.
///
/// Returns:
/// - A boolean indicating whether the given element contains a ShootingEnemyCurveAction.
bool isShootingEnemyCurveAction(xml.XmlElement element) {
  for (var idElement in element.findAllElements('id')) {
    var idText = idElement.innerText;
    if (ShootingEnemyCurveAction.identifierSet.contains(idText)) {
      return true;
    }
  }
  return false;
}
