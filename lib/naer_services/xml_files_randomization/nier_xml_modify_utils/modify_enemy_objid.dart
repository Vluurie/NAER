import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_modification.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:xml/xml.dart' as xml;

/// Processes the object ID element and handles different cases such as if the object ID is a boss, levels, and enemy categories.
///
/// The function performs the following steps:
/// 1. Retrieves the inner text of the object ID element.
/// 2. If the object ID is empty, the function returns early.
/// 3. Checks if the object ID corresponds to a boss object.
/// 4. If the object ID is important and the enemy category is all enemies, it handles the level and returns early.
/// 5. If the action is too small for an big enemy the isSpawnActionTooSmall bool handles this.
/// 6. Based on the enemy category, it processes the object ID element:
///    - For all enemies, it either handles the boss level or the selected object ID enemies.
///    - For only level, it either handles the boss level or only the object ID level.
///    - For other categories, if the object ID is not important and the category is not only level, it handles the default object ID.
///
/// Parameters:
/// - [objIdElement]: The XML element containing the object ID.
/// - [userSelectedEnemyData]: A map of user-selected enemy data grouped by categories.
/// - [filePath]: The path to the file containing enemy data.
/// - [enemyLevel]: The level of the enemy.
/// - [enemyCategory]: The category of the enemy.
/// - [isImportantId]: A boolean flag indicating if the object ID is important. Defaults to false.
/// - [isSpawnActionTooSmall]: A boolean flag indicating if the action is too small for later big enemy randomization.
///
Future<void> modifyEnemyObjId(
  xml.XmlElement objIdElement,
  Map<String, List<String>> userSelectedEnemyData,
  String filePath,
  MainData mainData,
  bool isSpawnActionTooSmall, {
  bool isImportantId = false,
}) async {
  final objIdValue = objIdElement.innerText;
  if (objIdValue.isEmpty) return;

  bool isBossObj = isBoss(objIdValue);
  String level = mainData.argument['enemyLevel'];
  String category = mainData.argument['enemyCategory'];
  try {
    if (isImportantId && category == 'allenemies') {
      await handleLevel(objIdElement, level, SortedEnemyGroup.enemyData, false);
      return;
    }
    switch (category) {
      case 'allenemies':
        await (isBossObj
            ? handleLevel(objIdElement, level, userSelectedEnemyData, true)
            : handleSelectedObjectIdEnemies(objIdElement, userSelectedEnemyData,
                level, isSpawnActionTooSmall));
        break;
      case 'onlylevel':
        await (isBossObj
            ? handleLevel(objIdElement, level, userSelectedEnemyData, true)
            : handleOnlyObjectIdLevel(
                objIdElement, userSelectedEnemyData, level));
        break;
      default:
        if (isImportantId) return;
        if (category != 'onlylevel') {
          await handleDefaultObjectId(
              objIdElement, userSelectedEnemyData, isSpawnActionTooSmall);
        }
    }
  } catch (e, stackTrace) {
    logAndPrint('Error processing $objIdValue: $e');
    logAndPrint('Stack trace: ${Trace.from(stackTrace)}');
  }
}
