import 'dart:io';

import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_objid_processing.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/xml/xml_extension.dart';
import 'package:xml/xml.dart' as xml;

Future<void> processCollectedXmlFileForRandomization(
    File file,
    Map<String, List<String>> sortedEnemyData,
    String enemyLevel,
    String enemyCategory,
    ImportantIDs importantIds) async {
  String content = file.readAsStringSync();
  var document = xml.XmlDocument.parse(content);

  var actions = document.findAllElements('action');
  for (var action in actions) {
    var actionId = action.findElements('id').isNotEmpty
        ? action.findElements('id').first.innerText
        : null;

    Iterable<xml.XmlElement> codeElements = getEnemyCodeElements(action);
    bool isActionImportant = false;
    isActionImportant =
        checkImportantIds(actionId, importantIds, isActionImportant);
    handleObjIdProcessing(codeElements, isActionImportant, sortedEnemyData,
        file, enemyLevel, enemyCategory);
  }

  file.writeAsStringSync(document.toPrettyString());
}
