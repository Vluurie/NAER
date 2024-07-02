import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/XmlElementHandler/handle_xml_elements.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_values.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:xml/xml.dart' as xml;

/// Handles the processing of an enemy entity object in the XML element.
///
/// This function performs different tasks based on the given parameters:
/// - Finds the mapped group from the [userSelectedEnemyData] associated with the enemy number
///   (e.g., [em0030] like [Fly] or [em0010] like [Ground]) in the XML element.
/// - Replaces the enemy number with a new random one from the user-selected data map and sets the
///   specific values for the new enemy number if [randomizeAndSetValues] is true.
/// - Handles enemy levels if [handleLevels] is true.
///
/// The function includes logic to avoid infinite loops when selecting a new enemy number:
/// - If after 10 iterations a big enemy is still selected and [isSpawnActionTooSmall] is true,
///   it will default to the original enemy number object, randomizes there values and stop the loop.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the enemy object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories like Ground or Fly.
/// - [enemyLevel]: The level of the enemy.
/// - [isSpawnActionTooSmall]: A boolean flag indicating if the spawn action is too small.
/// - [handleLevels]: A boolean flag indicating if enemy levels should be handled. Defaults to false.
/// - [randomizeAndSetValues]: A boolean flag indicating if the enemy number should be randomized.
///
/// Returns:
/// A Future that completes when the processing is done.
Future<void> handleEnemyEntityObject(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
  bool isSpawnActionTooSmall, {
  bool handleLevels = false,
  bool randomizeAndSetValues = false,
}) async {
  // Find the group corresponding to the enemy number in the XML element
  String? group =
      findGroupForEmNumber(objIdElement.innerText, SortedEnemyGroup.enemyData);

  // Proceed if a valid group is found, it is not excluded, and there are user-selected data
  if (group != null &&
      !isExcludedGroup(group) &&
      userSelectedEnemyData[group]?.isNotEmpty == true) {
    // Handle randomization and setting of new enemy number if requested
    if (randomizeAndSetValues) {
      String newEmNumber;
      int iterationCount = 0;
      do {
        // Select a random new enemy number from the user-selected data group
        newEmNumber = userSelectedEnemyData[group]![
            random.nextInt(userSelectedEnemyData[group]!.length)];
        iterationCount++;
        // Break the loop if it iterates more than 10 times to avoid infinite loops
        if (iterationCount > 10) {
          newEmNumber = objIdElement.innerText;
          break;
        }
      } while (isBigEnemy(newEmNumber) && isSpawnActionTooSmall);

      // Replace the text in the XML element with the new enemy number
      XmlElementHandler.replaceTextInXmlElement(objIdElement, newEmNumber);
      // Set specific values for the new enemy number
      setSpecificValues(objIdElement, newEmNumber);
    }

    // Handle enemy levels if requested
    if (handleLevels) {
      await handleLevel(
          objIdElement, enemyLevel, SortedEnemyGroup.enemyData, false);
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
    bool isSpawnActionTooSmall) async {
  await handleEnemyEntityObject(
      objIdElement, userSelectedEnemyData, enemyLevel, isSpawnActionTooSmall,
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
    bool isSpawnActionTooSmall) async {
  await handleEnemyEntityObject(
    objIdElement,
    userSelectedEnemyData,
    enemyLevel,
    handleLevels: true,
    randomizeAndSetValues: true,
    isSpawnActionTooSmall,
  );
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
  await handleEnemyEntityObject(
      objIdElement, userSelectedEnemyData, enemyLevel, false,
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
  bool isSpawnActionTooSmall,
) async {
  await handleEnemyEntityObject(
      objIdElement,
      userSelectedEnemyData,
      '',
      randomizeAndSetValues: true,
      isSpawnActionTooSmall);
}
