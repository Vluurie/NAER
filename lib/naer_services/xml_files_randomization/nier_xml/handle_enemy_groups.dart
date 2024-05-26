import 'dart:io';
import 'dart:math';
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
/// This method is needed to prevent randomness for alias tagged enemies that could have hardcoded behavior.
///
/// Parameters:
/// - [objIdElement]: The XML element to check.
///
/// Returns true if the element has an ancestor with an alias, otherwise false.
bool hasAliasAncestor(xml.XmlElement objIdElement) {
  return objIdElement.ancestors
      .any((element) => element.findElements('alias').isNotEmpty);
}
