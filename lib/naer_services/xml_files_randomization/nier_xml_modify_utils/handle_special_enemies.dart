import 'package:NAER/data/values_data/nier_randomizable_aliases.dart';
import 'package:NAER/naer_services/level_utils/handle_alias_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/modify_enemy_objid.dart';
import 'package:xml/xml.dart' as xml;

/// This function handles special cases for enemies within an XML element. It processes
/// 'objId' elements and modifies them based as whether the
/// enemy is a boss or has an alias ancestor. Depending on the enemy category, it also
/// handles leveled enemies with aliases.

Future<void> handleSpecialCaseEnemies(
  xml.XmlElement element,
  Map<String, List<String>> sortedEnemyData,
  String filePath,
  String enemyLevel,
  String enemyCategory,
  bool isSpawnActionTooSmall,
) async {
  // Get all objId elements in the current element and its descendants
  final objIdElements = element.findAllElements('objId').toList();

  // Process each objId element
  for (var objIdElement in objIdElements) {
    if (isBoss(objIdElement.innerText)) {
      // Modify the objId for bosses
      modifyEnemyObjId(
        objIdElement,
        sortedEnemyData,
        filePath,
        enemyLevel,
        enemyCategory,
        isSpawnActionTooSmall,
      );
    } else if (hasAliasAncestor(objIdElement, RandomizableAliases.aliases)) {
      // Check if the enemy has an alias ancestor and belongs to specific categories
      if (enemyCategory == 'allenemies' || enemyCategory == 'onlylevel') {
        // Handle leveled enemies with aliases
        await handleLeveledForAlias(objIdElement, enemyLevel, sortedEnemyData);
      }
    } else {
      // Modify the objId for other cases
      modifyEnemyObjId(
        objIdElement,
        sortedEnemyData,
        filePath,
        enemyLevel,
        enemyCategory,
        isSpawnActionTooSmall,
      );
    }
  }
}
