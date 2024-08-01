import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_values.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_file_randomizer.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:xml/xml.dart' as xml;

/// Handles the processing of an enemy entity object in the XML element.
///
/// - If the XML element represents a ShootingEnemyCurveAction, it handles the level using
///   the [handleLevel] method if [handleLevels] is true, sets specific values with [setSpecificValues],
///   and continues processing without randomizing the enemy ID.
/// - Otherwise, it finds the mapped group from the [userSelectedEnemyData] associated with the enemy number
///   (e.g., [em0030] like [Fly] or [em0010] like [Ground]) in the XML element.
/// - Replaces the enemy number with a new random one from the user-selected data map and sets the
///   specific values for the new enemy number if [randomizeAndSetValues] is true by calling [randomizeEnemyNumber].
/// - Handles enemy levels if [handleLevels] is true.
///
Future<void> handleEnemyEntityObject(EnemyEntityObjectAction action) async {
  // Check if part of ShootingEnemyCurveAction
  var actionElement = findRootActionElement(action.objIdElement);
  // Find the group corresponding to the enemy number in the XML element
  String? group = findGroupForEmNumber(
      action.objIdElement.innerText, SortedEnemyGroup.enemyData);
  if (actionElement != null && isShootingEnemyCurveAction(actionElement)) {
    await handleShootingEnemyCurveAction(action, group);
  }

  // Proceed if a valid group is found, it is not excluded, and there are user-selected data
  if (group != null &&
      !isExcludedGroup(group) &&
      action.userSelectedEnemyData[group]?.isNotEmpty == true) {
    // Handle randomization and setting of new enemy number if requested
    if (action.randomizeAndSetValues) {
      randomizeEnemyNumber(action, group);
    }
  }

  // Handle enemy levels if requested
  if (action.handleLevels) {
    await handleLevel(
        action.objIdElement, action.enemyLevel, SortedEnemyGroup.enemyData,
        isBoss: false);
  }
}

/// Handles the processing if the element is part of a ShootingEnemyCurveAction.
///
/// This function performs the following tasks:
/// - If [handleLevels] is true, it handles the level using [handleLevel] and randomizes the enemy number if [randomizeAndSetValues] is true.
/// - By default, it sets specific values with [setSpecificValues].
///
Future<void> handleShootingEnemyCurveAction(
    EnemyEntityObjectAction action, String? group) async {
  if (action.handleLevels) {
    if (group != null &&
        !isExcludedGroup(group) &&
        action.userSelectedEnemyData[group]?.isNotEmpty == true) {
      // Handle randomization and setting of new enemy number if requested
      await randomizeEnemyNumber(action, group);

      await handleLevel(
        action.objIdElement,
        action.enemyLevel,
        SortedEnemyGroup.enemyData,
        isBoss: false,
      );
    }
  }
  setSpecificValues(action.objIdElement, action.objIdElement.innerText);
}

/// Handles selected object ID enemies by randomizing their IDs, setting specific values, and handling levels.
///
/// This function calls [handleEnemyEntityObject] with the [handleLevels] and [randomizeAndSetValues] parameters set to true.
Future<void> handleSelectedObjectIdEnemies(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
  bool isSpawnActionTooSmall,
) async {
  await handleEnemyEntityObject(
    EnemyEntityObjectAction(
      objIdElement: objIdElement,
      userSelectedEnemyData: userSelectedEnemyData,
      enemyLevel: enemyLevel,
      isSpawnActionTooSmall: isSpawnActionTooSmall,
      handleLevels: true,
      randomizeAndSetValues: true,
    ),
  );
}

/// Handles only the enemy level without randomizing IDs or setting specific values.
///
/// This function calls [handleEnemyEntityObject] with the [handleLevels] parameter set to true.
Future<void> handleOnlyObjectIdLevel(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String enemyLevel,
) async {
  await handleEnemyEntityObject(
    EnemyEntityObjectAction(
      objIdElement: objIdElement,
      userSelectedEnemyData: userSelectedEnemyData,
      enemyLevel: enemyLevel,
      isSpawnActionTooSmall: false,
      handleLevels: true,
    ),
  );
}

/// Handles default object ID enemies by randomizing their IDs and setting specific values.
///
/// This function calls [handleEnemyEntityObject] with the [randomizeAndSetValues] parameter set to true, and an empty [enemyLevel].
Future<void> handleDefaultObjectId(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  bool isSpawnActionTooSmall,
) async {
  await handleEnemyEntityObject(
    EnemyEntityObjectAction(
      objIdElement: objIdElement,
      userSelectedEnemyData: userSelectedEnemyData,
      enemyLevel: '',
      isSpawnActionTooSmall: isSpawnActionTooSmall,
      randomizeAndSetValues: true,
    ),
  );
}
