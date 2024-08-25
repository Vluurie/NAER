import 'dart:convert';
import 'dart:math';
import 'package:NAER/data/enemy_lists_data/nier_boss_level_list.dart';
import 'package:NAER/data/sorted_data/nier_shooting_enemy_curve_action_ids.dart';
import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:xml/xml.dart' as xml;

Random random = Random();

/// Finds the group like Fly or Ground that contains the given enemy number.
String? findGroupForEmNumber(
    String emNumber, Map<String, List<String>> enemyData) {
  for (var group in enemyData.keys) {
    if (enemyData[group]!.contains(emNumber)) {
      return group;
    }
  }
  return null;
}

/// - [group]: The group name to check.
bool isExcludedGroup(String group) {
  const excludedGroups = {'Delete'};
  return excludedGroups.contains(group);
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
Future<bool> checkImportantIds(
    String? actionId, ImportantIDs importantIds, bool isActionImportant) async {
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
Future<bool> checkTooSmallSpawnAction(
    String? actionId,
    Map<String, Set<String>> bigSpawnEnemySkipIds,
    bool isSpawnActionTooSmall) async {
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
/// Filters the descendants of the given `action` XML element to
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
Future<Iterable<xml.XmlElement>> getEnemyCodeElements(
    xml.XmlElement action) async {
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
bool isShootingEnemyCurveAction(xml.XmlElement element) {
  for (var idElement in element.findAllElements('id')) {
    var idText = idElement.innerText;
    if (ShootingEnemyCurveAction.identifierSet.contains(idText)) {
      return true;
    }
  }
  return false;
}

String generateDeleteGroupArgument() {
  List<String> deleteValues = [
    "emf000",
    "em9002",
    "em1090",
    "em4120",
    "em2004",
    "em4010",
    "em0115",
    "em004b",
    "em5200",
    "em7001",
    "em8001",
    "em2000",
    "em0074",
    "emb090",
    "em2008",
    "em0092",
    "em9011",
    "em010d",
    "em1080",
    "em1073",
    "em9001",
    "emb043",
    "em1075",
    "em5401",
    "em0070",
    "em9010",
    "em4110",
    "em5002",
    "em011c",
    "ema021",
    "em0116",
    "em2003",
    "em0047",
    "em6011",
    "em6010",
    "em9003",
    "em3002",
    "em1031",
    "emb057",
    "em5302",
    "emf001",
    "em011e",
    "em005e",
    "emb030",
    "em1072",
    "em0072",
    "em5301",
    "em1081",
    "em560d",
    "em0075",
    "em8040",
    "em0071",
    "em0073",
    "em1071",
    "em007b",
    "em6012",
    "emb115",
    "emb017",
    "em3100",
    "em3014",
    "em5300",
    "em6200",
    "em0019",
    "em3003",
    "em011a",
    "em5400",
    "emb070",
    "em3001",
    "em3012",
    "em4130",
    "em3011",
    "em011b",
    "em8802",
    "em4100",
    "em6300",
    "emb07a",
    "emb116",
    "em012e",
    "emb075",
    "em3013",
    "eme000",
    "em5500",
    "em007a",
    "em0044",
    "emb11b",
    "em0117",
    "em2101",
    "emb007",
    "em001d"
  ];

  String deleteArgument = '--Delete=${jsonEncode(deleteValues)}';
  return deleteArgument;
}

String getArgForAllEnemiesForStatsChange() {
  return "[em1030],[em1040],[em1074],[em1100, em1101],[em1000],[em3000],[em7000, em7001],[em4000, em4010],[em0120],[em8000, em8001, em8801],[em8010],[em8020],[em8002],[em2100, em2101],[em6000, em5100, em6200, em5300],[em5400, em5000, em5002, em5200, em5401, em5500],[em0110, em0111, emb0110, emb111],[em1010, em8802, em8800],[emb054],[emb002],[emb051],[emb010],[emb061],[emb041],[em4100, em4110],[em3010],[em8030],[em6400],[em5600],[em0112],[em560d],[em004d],[em002d],[em9000, em9001, em9002, em9003],[em9010, em9011],[emb004],[emb012],[emb052],[emb056],[emb110],[em200d],[em1050],[em1060],[em1070],[em1061],[em0065],[em1074],[em1020],[emb080],[emb060],[em0006],[em0106],[em0056],[em0016],[em0066],[em0069],[em0026],[em0046],[em0096],[em0086],[em2006],[em005a],[em2007],[em0005],[em000e],[em000d],[em0055],[em0015],[em0068],[em0004],[em0054],[em0014],[em0064],[em0067],[em0094],[em0003],[em0053],[em0013],[emb05a],[emb015],[em0002],[em0052],[em0012],[em0042],[em0000],[em0100],[em0050],[em0010],[emb016],[em0060],[em0061],[em0020],[em0040],[em0090],[em0080],[em005c],[em001c],[em2001],[em2002],[em0007],[em0057],[em0017],[em9000],[ema001],[ema002],[ema010],[ema011],[emb014],[em0030],[em0032],[em0033],[em0034],[em0035],[em0036],[emb031],[em3004]";
}

String generateGroundGroupArgument(
    List<String> groundList, bool isChecked, String enemyId) {
  if (isChecked && !groundList.contains(enemyId)) {
    groundList.add(enemyId);
  } else if (!isChecked) {
    groundList.remove(enemyId);
  }

  return '--Ground=[${groundList.map((e) => '"$e"').join(',')}]';
}
