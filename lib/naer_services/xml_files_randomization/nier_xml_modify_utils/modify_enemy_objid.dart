import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_modification.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:xml/xml.dart' as xml;

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
      await handleLevel(objIdElement, level, SortedEnemyGroup.enemyData,
          isBoss: false);
      return;
    }
    switch (category) {
      case 'allenemies':
        await (isBossObj
            ? handleLevel(objIdElement, level, SortedEnemyGroup.enemyData,
                isBoss: true)
            : handleSelectedObjectIdEnemies(objIdElement, userSelectedEnemyData,
                level, isSpawnActionTooSmall));
        break;
      case 'onlylevel':
        await (isBossObj
            ? handleLevel(objIdElement, level, SortedEnemyGroup.enemyData,
                isBoss: true)
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
