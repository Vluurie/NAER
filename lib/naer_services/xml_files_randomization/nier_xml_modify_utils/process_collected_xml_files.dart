import 'dart:io';

import 'package:NAER/data/sorted_data/big_enemies_ids.dart';
import 'package:NAER/data/values_data/nier_important_ids.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_objid_processing.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/xml/xml_extension.dart';
import 'package:xml/xml.dart' as xml;

/// Processes a collected XML file for randomization.
///
/// This method reads the XML file, parses its content, and processes each action element within the XML.
/// It checks if the action is important based on its ID, and then processes the enemy code elements accordingly.
/// Finally, it writes the modified XML content back to the file.
///
/// [file] is the XML file to be processed.
/// [sortedEnemyData] is the map of sorted enemy data.
/// [enemyLevel] specifies the level of enemies to be modified.
/// [enemyCategory] specifies the category of enemies to be modified.
/// [importantIds] is the ImportantIDs object containing metadata IDs.
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
    bool isSpawnActionTooSmall = false;
    bool isActionImportant = false;

    isSpawnActionTooSmall = checkTooSmallSpawnAction(
        actionId, bigSpawnEnemySkipIds, isSpawnActionTooSmall);
    isActionImportant =
        checkImportantIds(actionId, importantIds, isActionImportant);
    handleObjIdProcessing(codeElements, isActionImportant, sortedEnemyData,
        file, enemyLevel, enemyCategory, isSpawnActionTooSmall);
  }

  file.writeAsStringSync(document.toPrettyString());
}
