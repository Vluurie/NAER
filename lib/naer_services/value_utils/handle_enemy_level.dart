import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:xml/xml.dart' as xml;

/// Handles the level update for an enemy or boss based on the `isBoss` flag.
///
/// If the enemy is in the "Delete" group, the function skips the level update.
/// Otherwise, it updates or creates the necessary level values in the XML element.
///
/// If `isBoss` is `true`, the function does not update the `levelRange` for 'EnemyGenerator' actions.
Future<void> handleLevel(xml.XmlElement objIdElement, String enemyLevel,
    Map<String, List<String>> enemyData, bool isBoss) async {
  var objIdValue = objIdElement.innerText;

  // Check if the enemy is in the "Delete" group
  if (isDeletedEnemy(objIdValue, enemyData)) {
    return;
  }

  // Find or create the 'param' element and update/create 'Lv' values
  var parentValueElement = findParentValueElement(objIdElement);
  if (parentValueElement != null) {
    var paramElement = parentValueElement.findElements('param').firstOrNull;
    if (paramElement == null) {
      paramElement = createParamElement();
      // Ensure paramElement is the last child
      parentValueElement.children.add(paramElement);
    }

    // Flow:
    // param element for Level exist?
    //
    // No = [updateOrCreateLevelValue]
    updateOrCreateLevelValue(paramElement, 'Lv', enemyLevel);

    // Yes = [updateLevelValueIfExists]

    updateLevelValueIfExists(paramElement, 'LV', enemyLevel);
    updateLevelValueIfExists(paramElement, 'Lv_B', enemyLevel);
    updateLevelValueIfExists(paramElement, 'Lv_C', enemyLevel);
    updateLevelValueIfExists(paramElement, 'Lv_D', enemyLevel);

    // increases the count or creates it so the game knows that a new param/value was added
    updateOrCreateCountElement(paramElement);

    // Ensure paramElement is the last child (in case it was already present)
    parentValueElement.children.remove(paramElement);
    parentValueElement.children.add(paramElement);
  }

  // Only update levelRange for 'EnemyGenerator' actions if not a boss
  if (!isBoss) {
    var rootActionElement = findRootActionElement(objIdElement);
    if (rootActionElement != null && isEnemyGenerator(rootActionElement)) {
      updateGeneratorLevelRange(rootActionElement, enemyLevel);
    }
  }
}

/// Finds the root 'action' XML element starting from the given `element`.
///
/// Returns the found 'action' element or `null` if not found.
xml.XmlElement? findRootActionElement(xml.XmlElement element) {
  var current = element.parent;
  while (current != null) {
    if (current is xml.XmlElement && current.name.local == 'action') {
      return current;
    }
    current = current.parent;
  }
  return null;
}

/// Updates the `levelRange` for an 'EnemyGenerator' action in the given `actionElement` with the specified `enemyLevel`.
///
/// If 'min' and 'max' elements exist within `levelRange`, their text is replaced with `enemyLevel`.
void updateGeneratorLevelRange(
    xml.XmlElement actionElement, String enemyLevel) {
  var levelRangeElement = actionElement.findElements('levelRange').firstOrNull;
  if (levelRangeElement != null) {
    var minElement = levelRangeElement.findElements('min').firstOrNull;
    var maxElement = levelRangeElement.findElements('max').firstOrNull;

    if (minElement != null) {
      minElement.firstChild?.replace(xml.XmlText(enemyLevel));
    }
    if (maxElement != null) {
      maxElement.firstChild?.replace(xml.XmlText(enemyLevel));
    }
  }
}

/// Updates or creates a level value with the given `levelName` and `enemyLevel` in the `paramElement`.
///
/// If the level value does not exist, it is created and added to the `paramElement`.
void updateOrCreateLevelValue(
    xml.XmlElement paramElement, String levelName, String enemyLevel) {
  var levelValueElement =
      findLevelValueElementWithName(paramElement, levelName);

  if (levelValueElement == null) {
    levelValueElement = createLevelValueElement(levelName, enemyLevel);
    paramElement.children.add(levelValueElement);
  } else {
    updateLevelValueElement(levelValueElement, enemyLevel);
  }
}

/// Updates the count value in the `paramElement` to '0x1' if the existing count is '0x0'.
///
/// Clears the existing text nodes in the 'count' element and adds a new text node with the updated count value.
void updateCountForParam(xml.XmlElement paramElement) {
  var countElement = paramElement.findElements('count').firstOrNull;

  if (countElement != null && countElement.innerText == '0x0') {
    // Clear existing children (text nodes) and add a new text node
    countElement.children.clear();
    countElement.children.add(xml.XmlText('0x1'));
  }
}

/// Creates and returns a new 'param' XML element.
xml.XmlElement createParamElement() {
  return xml.XmlElement(xml.XmlName('param'), [], []);
}

/// Updates the level value with the given `levelName` and `enemyLevel` in the `paramElement` if it exists.
///
/// If the level value does not exist, this function does nothing.
void updateLevelValueIfExists(
    xml.XmlElement paramElement, String levelName, String enemyLevel) {
  var levelValueElement =
      findLevelValueElementWithName(paramElement, levelName);

  if (levelValueElement != null) {
    updateLevelValueElement(levelValueElement, enemyLevel);
  }
}

/// Finds the level value element with the specified `levelName` within the `paramElement`.
///
/// Returns the found 'value' element or `null` if not found.
xml.XmlElement? findLevelValueElementWithName(
    xml.XmlElement paramElement, String levelName) {
  try {
    return paramElement.findElements('value').firstWhere((element) =>
        element.findElements('name').firstOrNull?.innerText == levelName);
  } catch (e) {
    return null;
  }
}

/// Updates or creates the 'count' element in the `paramElement` to reflect the number of 'value' elements.
///
/// If the 'count' element does not exist, it is created and added to the `paramElement`.
void updateOrCreateCountElement(xml.XmlElement paramElement) {
  var countElement = paramElement.findElements('count').firstOrNull;

  // Calculate the number of value elements
  var valueCount = paramElement.findElements('value').length;

  if (countElement == null) {
    // Create count element if it doesn't exist
    countElement = xml.XmlElement(xml.XmlName('count'), [],
        [xml.XmlText('0x${valueCount.toRadixString(16)}')]);
    paramElement.children.insert(0, countElement);
  } else {
    // Update existing count element
    countElement.children.clear();
    countElement.children.add(xml.XmlText('0x${valueCount.toRadixString(16)}'));
  }
}

/// Finds the parent 'value' XML element starting from the given `node`.
///
/// Returns the found 'value' element or `null` if not found.
xml.XmlElement? findParentValueElement(xml.XmlNode node) {
  while (node.parent != null) {
    if (node is xml.XmlElement && node.name.local == 'value') {
      return node;
    }
    node = node.parent!;
  }
  return null;
}

/// Creates and returns a new 'value' XML element with the specified `levelName` and `enemyLevel`.
/// 0x1451dab1 is the param element hex identifier
xml.XmlElement createLevelValueElement(String levelName, String enemyLevel) {
  return xml.XmlElement(xml.XmlName('value'), [], [
    xml.XmlElement(xml.XmlName('name'), [], [xml.XmlText(levelName)]),
    xml.XmlElement(
        xml.XmlName('code'),
        [xml.XmlAttribute(xml.XmlName('str'), 'int')],
        [xml.XmlText('0x1451dab1')]),
    xml.XmlElement(xml.XmlName('body'), [], [xml.XmlText(enemyLevel)])
  ]);
}

/// Updates the text of the 'body' element within the given `levelValueElement` to the specified `enemyLevel`.
///
/// Clears the existing children of the 'body' element and adds a new text node with the updated level value.
void updateLevelValueElement(
    xml.XmlElement levelValueElement, String enemyLevel) {
  var bodyElement = levelValueElement.findElements('body').firstOrNull;
  if (bodyElement != null) {
    bodyElement.children.clear();
    bodyElement.children.add(xml.XmlText(enemyLevel));
  }
}
