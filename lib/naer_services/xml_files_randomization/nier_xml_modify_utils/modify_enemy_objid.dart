import 'package:NAER/data/sorted_data/nier_sorted_enemies.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_level.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_modification.dart';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:NAER/nier_cli/main_data_container.dart';

import 'package:xml/xml.dart' as xml;

Future<void> modifyEnemyObjId(
  final xml.XmlElement objIdElement,
  final Map<String, List<String>> userSelectedEnemyData,
  final String filePath,
  final MainData mainData,
  // ignore: avoid_positional_boolean_parameters
  final bool isSpawnActionTooSmall, {
  final bool isImportantId = false,
}) async {
  final objIdValue = objIdElement.innerText;
  if (objIdValue.isEmpty) return;

  bool isBossObj = isBoss(objIdValue);
  String level = mainData.argument['enemyLevel'];
  String category = mainData.argument['enemyCategory'];
  try {
    if (isImportantId && category == 'allenemies') {
      await handleLevel(objIdElement, level, SortedEnemyGroup.enemyData);
      return;
    }
    switch (category) {
      case 'allenemies':
        await (isBossObj
            ? handleLevel(objIdElement, level, SortedEnemyGroup.enemyData,
                isBoss: true)
            : handleSelectedObjectIdEnemies(
                objIdElement, userSelectedEnemyData, level,
                isSpawnActionTooSmall: isSpawnActionTooSmall));
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
          await handleDefaultObjectId(objIdElement, userSelectedEnemyData,
              isSpawnActionTooSmall: isSpawnActionTooSmall);
        }
    }
  } catch (e, stackTrace) {
    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage:
          "Caught while modify enemy objID of xml element: ${objIdElement.toString()} in file: $filePath with mainData arguments: ${mainData.toString()} Check log.json for details.",
      onHandled: () => {LogState().clearLogs()},
    );
  }
}
