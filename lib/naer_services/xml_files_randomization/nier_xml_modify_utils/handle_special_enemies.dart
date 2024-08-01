import 'package:NAER/data/values_data/nier_randomizable_aliases.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/modify_enemy_objid.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:xml/xml.dart' as xml;

/// This function handles special cases for enemies within an XML element. It processes
/// 'objId' elements and modifies them based as whether the
/// enemy is a boss or has an alias ancestor. Depending on the enemy category, it also
/// handles leveled enemies with aliases.

Future<void> handleSpecialCaseEnemies(
  xml.XmlElement element,
  Map<String, List<String>> sortedEnemyData,
  String filePath,
  MainData mainData,
  bool isSpawnActionTooSmall,
) async {
  String category = mainData.argument['enemyCategory'];
  String level = mainData.argument['enemyLevel'];
  if (category != 'onlylevel') {
    // Remove randomizable aliases before processing objId elements for all enemies
    // skip if only level need to be changed since then the alias does not matter
    removeAliases(element, RandomizableAliases.aliases);
  }

  // Recursive function to find and process all objId elements in the current element and its descendants
  Future<void> processObjIdElements(xml.XmlElement elem) async {
    final objIdElements = elem.findAllElements('objId').toList();

    for (var objIdElement in objIdElements) {
      if (await isBoss(objIdElement.innerText)) {
        // Modify the objId for bosses
        await modifyEnemyObjId(
          objIdElement,
          sortedEnemyData,
          filePath,
          mainData,
          isSpawnActionTooSmall,
        );
      } else if (hasAliasAncestor(objIdElement)) {
        // Check if the enemy has an alias ancestor and belongs to specific categories
        if (category == 'allenemies' || category == 'onlylevel') {
          // Handle the level for enemies with alias
          await handleLevel(objIdElement, level, sortedEnemyData,
              isBoss: false);
        }
      } else {
        // Modify the objId for no boss or alias enemy
        await modifyEnemyObjId(
          objIdElement,
          sortedEnemyData,
          filePath,
          mainData,
          isSpawnActionTooSmall,
        );
      }
    }

    // Recursively process again child elements since all is sooo damn nested
    for (var child in elem.children.whereType<xml.XmlElement>()) {
      await processObjIdElements(child);
    }
  }

  // Start processing from the root element (love recursiv)
  await processObjIdElements(element);
}
