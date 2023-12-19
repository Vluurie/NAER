import 'package:xml/xml.dart' as xml;

handleBossLevel(xml.XmlElement objIdElement, String enemyLevel) {
  xml.XmlElement? parentValueElement = findParentValueElement(objIdElement);

  // Only proceed if a 'param' element is found
  if (parentValueElement != null) {
    var paramElement = parentValueElement.findElements('param').firstOrNull;

    if (paramElement != null) {
      // Update existing 'Lv', 'Lv_B', 'Lv_C' if they exist
      updateLevelValueIfExists(paramElement, 'Lv', enemyLevel);
      updateLevelValueIfExists(paramElement, 'Lv_B', enemyLevel);
      updateLevelValueIfExists(paramElement, 'Lv_C', enemyLevel);
    }
  }
}

void updateLevelValueIfExists(
    xml.XmlElement paramElement, String levelName, String enemyLevel) {
  var levelValueElement =
      findLevelValueElementWithName(paramElement, levelName);

  if (levelValueElement != null) {
    updateLevelValueElement(levelValueElement, enemyLevel);
  }
}

void updateLevelValueElement(
    xml.XmlElement levelValueElement, String enemyLevel) {
  var bodyElement = levelValueElement.findElements('body').firstOrNull;
  if (bodyElement != null) {
    bodyElement.children.clear();
    bodyElement.children.add(xml.XmlText(enemyLevel));
  }
}

xml.XmlElement? findLevelValueElementWithName(
    xml.XmlElement paramElement, String levelName) {
  try {
    return paramElement.findElements('value').firstWhere((element) =>
        element.findElements('name').firstOrNull?.text == levelName);
  } catch (e) {
    // If no element is found, return null
    return null;
  }
}

xml.XmlElement? findParentValueElement(xml.XmlNode node) {
  while (node.parent != null) {
    if (node is xml.XmlElement && node.name.local == 'value') {
      return node;
    }
    node = node.parent!;
  }
  return null;
}


/* void updateOrCreateLevelValue(
    xml.XmlElement paramElement, String levelName, String enemyLevel) {
  var levelValueElement =
      findLevelValueElementWithName(paramElement, levelName);

  if (levelValueElement == null) {
    levelValueElement = createLevelValueElement(levelName, enemyLevel);
    paramElement.children.add(levelValueElement);
  } else {
    updateLevelValueElement(levelValueElement, enemyLevel);
  }
} */

/* void updateCountForParam(xml.XmlElement paramElement) {
  var countElement = paramElement.findElements('count').firstOrNull;

  if (countElement != null && countElement.text == '0x0') {
    // Clear existing children (text nodes) and add a new text node
    countElement.children.clear();
    countElement.children.add(xml.XmlText('0x1'));
  }
} */

/* xml.XmlElement createParamElement() {
  return xml.XmlElement(xml.XmlName('param'), [], []);
} */



/* void updateOrCreateCountElement(xml.XmlElement paramElement) {
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
} */

/* void moveLevelValueToParam(
    xml.XmlElement levelValueElement, xml.XmlElement paramElement) {
  var parentOfLevel = levelValueElement.parent;
  if (parentOfLevel != null) {
    parentOfLevel.children.remove(levelValueElement);
  }
  paramElement.children.add(levelValueElement);
} */


/* bool isDirectChildOfParam(
    xml.XmlElement valueElement, xml.XmlElement paramElement) {
  return valueElement.parent == paramElement;
}

xml.XmlElement? findLevelValueElement(xml.XmlElement paramElement) {
  // Checks for the level element at any depth within the param element
  var valueElements = paramElement.descendants
      .whereType<xml.XmlElement>()
      .where((element) => element.name.local == 'value');
  for (var valueElement in valueElements) {
    var nameElement = valueElement.findElements('name').firstOrNull;
    if (nameElement != null && nameElement.text == 'Lv') {
      return valueElement;
    }
  }
  return null;
} */

/* xml.XmlElement createLevelValueElement(String levelName, String enemyLevel) {
  return xml.XmlElement(xml.XmlName('value'), [], [
    xml.XmlElement(xml.XmlName('name'), [], [xml.XmlText(levelName)]),
    xml.XmlElement(
        xml.XmlName('code'),
        [xml.XmlAttribute(xml.XmlName('str'), 'int')],
        [xml.XmlText('0x1451dab1')]),
    xml.XmlElement(xml.XmlName('body'), [], [xml.XmlText(enemyLevel)])
  ]);
}


 */