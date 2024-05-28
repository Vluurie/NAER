import 'package:NAER/naer_services/level_utils/handle_alias_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/modify_enemy_objid.dart';
import 'package:xml/xml.dart' as xml;

/// This function handles special cases for enemies within an XML element. It processes
/// 'objId' elements and modifies them based as whether the
/// enemy is a boss or has an alias ancestor. Depending on the enemy category, it also
/// handles leveled enemies with aliases.
///
/// Parameters:
/// - `element`: The XML element to be processed.
/// - `sortedEnemyData`: A map containing sorted enemy data.
/// - `filePath`: The file path where enemy data is located.
/// - `enemyLevel`: The level of the enemy being processed.
/// - `enemyCategory`: The category of the enemy (e.g., all enemies, only level).
///
/// Returns: A Future that completes when the processing is done.
Future<void> handleSpecialCaseEnemies(
    xml.XmlElement element,
    Map<String, List<String>> sortedEnemyData,
    String filePath,
    String enemyLevel,
    String enemyCategory) async {
  // Check if the current element's name is 'objId'
  if (element.name.local == 'objId') {
    if (isBoss(element.innerText)) {
      // Modify the objId for bosses
      modifyEnemyObjId(
          element, sortedEnemyData, filePath, enemyLevel, enemyCategory);
    } else if (hasAliasAncestor(element)) {
      // Check if the enemy has an alias ancestor and belongs to specific categories
      if (enemyCategory == 'allenemies' || enemyCategory == 'onlylevel') {
        // Handle leveled enemies with aliases
        await handleLeveledForAlias(element, enemyLevel, sortedEnemyData);
        return;
      }
    } else {
      // Modify the objId for other cases
      modifyEnemyObjId(
          element, sortedEnemyData, filePath, enemyLevel, enemyCategory);
    }
  } else {
    // Recursively process descendant elements that are of type 'objId'
    element.descendants.whereType<xml.XmlElement>().forEach((desc) async {
      if (desc.name.local == 'objId') {
        if (isBoss(desc.innerText)) {
          // Modify the objId for boss descendants
          modifyEnemyObjId(
              desc, sortedEnemyData, filePath, enemyLevel, enemyCategory);
        } else if (hasAliasAncestor(desc)) {
          // Check if the descendant has an alias ancestor and belongs to specific categories
          if (enemyCategory == 'allenemies' || enemyCategory == 'onlylevel') {
            // Handle leveled enemies with aliases for descendants
            await handleLeveledForAlias(desc, enemyLevel, sortedEnemyData);
            return;
          }
        } else {
          // Modify the objId for other descendant cases
          modifyEnemyObjId(
              desc, sortedEnemyData, filePath, enemyLevel, enemyCategory);
        }
      }
    });
  }
}
