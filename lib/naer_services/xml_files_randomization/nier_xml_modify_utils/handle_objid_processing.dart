import 'dart:io';

import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/modify_enemy_objid.dart';
import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_special_enemies.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:xml/xml.dart' as xml;

/// Processes 'objId' elements within given code elements and handles them based
/// on whether the action is important.
///
/// This function iterates over the provided `codeElements` and processes their
/// parent elements to handle 'objId' elements. If the action is important, it
/// modifies the 'objId' elements directly. Otherwise, it handles special cases
/// for enemies within the parent element.
///
/// Parameters:
/// - `codeElements`: An iterable collection of XML elements that contain objID
///   code actions.
/// - `isActionImportant`: A boolean flag indicating if the action is important.
/// - `sortedEnemyData`: A map containing sorted enemy data.
/// - `file`: The file object where enemy data is located.
/// - `enemyLevel`: The level of the enemy being processed.
/// - `enemyCategory`: The category of the enemy (e.g., all enemies, only level).
/// - [isSpawnActionTooSmall]: A boolean flag indicating if the action is too small for later big enemy randomization.
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
