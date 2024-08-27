import 'dart:io';

import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_objid_processing.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/xml/xml_extension.dart';
import 'package:xml/xml.dart' as xml;

Future<void> processCollectedXmlFileForRandomization(
    File file,
    Map<String, List<String>> sortedEnemyData,
    ImportantIDs importantIds,
    MainData mainData) async {
  String content = await file.readAsString();
  var document = xml.XmlDocument.parse(content);

  var actions = document.findAllElements('action');
  for (var action in actions) {
    var actionId = action.findElements('id').isNotEmpty
        ? action.findElements('id').first.innerText
        : null;

    Iterable<xml.XmlElement> codeElements = await getEnemyCodeElements(action);
    bool isSpawnActionTooSmall = false;
    bool isActionImportant = false;

    isSpawnActionTooSmall = await checkTooSmallSpawnAction(
        actionId, SpecialEntities.bigSpawnEnemySkipIds, isSpawnActionTooSmall);
    isActionImportant =
        await checkImportantIds(actionId, importantIds, isActionImportant);
    await handleObjIdProcessing(codeElements, isActionImportant,
        sortedEnemyData, file, isSpawnActionTooSmall, mainData);
  }

  await file.writeAsString(document.toPrettyString());
}
