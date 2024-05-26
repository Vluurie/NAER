import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/level_utils/handle_level.dart';
import 'package:NAER/naer_services/value_utils/handle_set_type_rtn_flag.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml/handle_update_xml.dart';
import 'package:xml/xml.dart' as xml;

/// Handles the processing of an enemy entity object in the XML element.
///
/// This function performs different tasks based on the given parameters:
/// - Finds the mapped group from the [userSelectedEnemyData] associated with the enemy number [em0030] like [Fly] or [em0010] like [Ground] in the XML element.
/// - Replaces the enemy number with a new random one from the user-selected data map and sets the [setTypes, setFlags or setRtn for the newEmNumber]
/// - Handles enemy levels if [handleLevels] is true.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories like Ground or Fly.
/// - [enemyLevel]: The level of the enemy.
/// - [handleLevels]: A boolean flag indicating if enemy levels should be handled. Defaults to false.
/// - [randomizeAndSetValues]: A boolean flag indicating if the enemy number should be randomized.
Future<void> handleEnemyEntityObject(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel, {
  bool handleLevels = false,
  bool randomizeAndSetValues = false,
}) async {
  String? group = findGroupForEmNumber(objIdElement.text, enemyData);

  if (group != null &&
      !isExcludedGroup(group) &&
      userSelectedEnemyData[group]?.isNotEmpty == true) {
    if (randomizeAndSetValues) {
      String newEmNumber = userSelectedEnemyData[group]![
          random.nextInt(userSelectedEnemyData[group]!.length)];
      replaceTextInXmlElement(objIdElement, newEmNumber);
      setSpecificValues(objIdElement, newEmNumber);
    }

    if (handleLevels) {
      await handleLevel(objIdElement, enemyLevel, enemyData);
    }
  }
}

/// Handles other enemies by randomizing their IDs and setting specific values.
///
/// This function calls [handleEnemyEntityObject] with the [randomizeAndSetValues] parameter set to true.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
/// - [enemyLevel]: The level of the enemy.
Future<void> handleOtherEnemies(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  await handleEnemyEntityObject(objIdElement, userSelectedEnemyData, enemyLevel,
      randomizeAndSetValues: true);
}

/// Handles selected object ID enemies by randomizing their IDs, setting specific values, and handling levels.
///
/// This function calls [handleEnemyEntityObject] with the [handleLevels] and [randomizeAndSetValues] parameters set to true.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
/// - [enemyLevel]: The level of the enemy.
Future<void> handleSelectedObjectIdEnemies(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  await handleEnemyEntityObject(objIdElement, userSelectedEnemyData, enemyLevel,
      handleLevels: true, randomizeAndSetValues: true);
}

/// Handles only the enemy level without randomizing IDs or setting specific values.
///
/// This function calls [handleEnemyEntityObject] with the [handleLevels] parameter set to true.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
/// - [enemyLevel]: The level of the enemy.
Future<void> handleOnlyObjectIdLevel(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  await handleEnemyEntityObject(objIdElement, userSelectedEnemyData, enemyLevel,
      handleLevels: true);
}

/// Handles default object ID enemies by randomizing their IDs and setting specific values.
///
/// This function calls [handleEnemyEntityObject] with the [randomizeAndSetValues] parameter set to true, and an empty [enemyLevel].
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
Future<void> handleDefaultObjectId(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
) async {
  await handleEnemyEntityObject(objIdElement, userSelectedEnemyData, '',
      randomizeAndSetValues: true);
}
