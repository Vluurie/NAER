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
Future<void> handleEnemyEntityObject(
    final EnemyEntityObjectAction action) async {
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
      await randomizeEnemyNumber(action, group);
    }
  }

  // Handle enemy levels if requested
  if (action.handleLevels) {
    await handleLevel(
        action.objIdElement, action.enemyLevel, SortedEnemyGroup.enemyData);
  }
}

/// Handles the processing if the element is part of a ShootingEnemyCurveAction.
/// - If [handleLevels] is true, it handles the level using [handleLevel] and randomizes the enemy number if [randomizeAndSetValues] is true.
/// - By default, it sets [setSpecificValues].
///
Future<void> handleShootingEnemyCurveAction(
    final EnemyEntityObjectAction action, final String? group) async {
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
      );
    }
  }
  await setSpecificValues(action.objIdElement, action.objIdElement.innerText);
}

/// Calls [handleEnemyEntityObject] with the [handleLevels] and [randomizeAndSetValues] parameters set to true.
Future<void> handleSelectedObjectIdEnemies(
    final xml.XmlElement objIdElement,
    final Map<String, List<String>> userSelectedEnemyData,
    final String enemyLevel,
    {required final bool isSpawnActionTooSmall}) async {
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

/// Calls [handleEnemyEntityObject] with the [handleLevels] parameter set to true.
Future<void> handleOnlyObjectIdLevel(
  final xml.XmlElement objIdElement,
  final Map<String, List<String>> userSelectedEnemyData,
  final String enemyLevel,
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

/// Calls [handleEnemyEntityObject] with the [randomizeAndSetValues] parameter set to true, and an empty [enemyLevel].
Future<void> handleDefaultObjectId(final xml.XmlElement objIdElement,
    final Map<String, List<String>> userSelectedEnemyData,
    {required final bool isSpawnActionTooSmall}) async {
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
