import 'dart:io';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/modify_enemy_objid.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_special_enemies.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:xml/xml.dart' as xml;

Future<void> handleObjIdProcessing(
    Iterable<xml.XmlElement> codeElements,
    bool isActionImportant,
    Map<String, List<String>> sortedEnemyData,
    File file,
    bool isSpawnActionTooSmall,
    MainData mainData) async {
  for (var codeElement in codeElements) {
    // Check if the parent of the code element is an XML element
    if (codeElement.parent is xml.XmlElement) {
      var parentElement = codeElement.parent as xml.XmlElement;

      if (isActionImportant) {
        // If the action is important, process descendant 'objId' elements
        parentElement.descendants
            .whereType<xml.XmlElement>()
            .where((element) => element.name.local == 'objId')
            .forEach((objIdElement) async {
          await modifyEnemyObjId(
              objIdElement,
              sortedEnemyData,
              file.path,
              mainData,
              isImportantId: true,
              isSpawnActionTooSmall);
        });
        break; // Exit loop after processing important action
      } else {
        // If the action is not important, handle special cases for enemies
        var relevantElements =
            parentElement.children.whereType<xml.XmlElement>();
        for (var element in relevantElements) {
          await handleSpecialCaseEnemies(element, sortedEnemyData, file.path,
              mainData, isSpawnActionTooSmall);
        }
      }
    }
  }
}
