import 'package:xml/xml.dart' as xml;

String? findGroupForEmNumber(
    String emNumber, Map<String, List<String>> enemyData) {
  for (var group in enemyData.keys) {
    if (enemyData[group]!.contains(emNumber)) {
      return group;
    }
  }
  return null;
}

bool isDeletedEnemy(String emNumber, Map<String, List<String>> enemyData) {
  return findGroupForEmNumber(emNumber, enemyData) == "Delete";
}

Future<void> handleLevel(xml.XmlElement objIdElement, String enemyLevel,
    Map<String, List<String>> enemyData) async {
  var objIdValue = objIdElement.text;

  // Check if the enemy is in the "Delete" group
  if (isDeletedEnemy(objIdValue, enemyData)) {
    // Skip updating the level for deleted enemies
    print('Skipping level update for deleted enemy: $objIdValue');
    return;
  }

  xml.XmlElement? parentValueElement = findParentValueElement(objIdElement);

  if (parentValueElement != null) {
    var paramElement = parentValueElement.findElements('param').firstOrNull;

    if (paramElement == null) {
      paramElement = createParamElement();
      parentValueElement.children.add(paramElement);
    }

    // Update or create 'Lv'
    updateOrCreateLevelValue(paramElement, 'Lv', enemyLevel);

    // Update 'Lv_B' and 'Lv_C' if they exist
    updateLevelValueIfExists(paramElement, 'Lv_B', enemyLevel);
    updateLevelValueIfExists(paramElement, 'Lv_C', enemyLevel);

    updateOrCreateCountElement(paramElement);
  }
}

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

void updateCountForParam(xml.XmlElement paramElement) {
  var countElement = paramElement.findElements('count').firstOrNull;

  if (countElement != null && countElement.text == '0x0') {
    // Clear existing children (text nodes) and add a new text node
    countElement.children.clear();
    countElement.children.add(xml.XmlText('0x1'));
  }
}

xml.XmlElement createParamElement() {
  return xml.XmlElement(xml.XmlName('param'), [], []);
}

void updateLevelValueIfExists(
    xml.XmlElement paramElement, String levelName, String enemyLevel) {
  var levelValueElement =
      findLevelValueElementWithName(paramElement, levelName);

  if (levelValueElement != null) {
    updateLevelValueElement(levelValueElement, enemyLevel);
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

void moveLevelValueToParam(
    xml.XmlElement levelValueElement, xml.XmlElement paramElement) {
  var parentOfLevel = levelValueElement.parent;
  if (parentOfLevel != null) {
    parentOfLevel.children.remove(levelValueElement);
  }
  paramElement.children.add(levelValueElement);
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

bool isDirectChildOfParam(
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
}

xml.XmlElement createLevelValueElement(String levelName, String enemyLevel) {
  return xml.XmlElement(xml.XmlName('value'), [], [
    xml.XmlElement(xml.XmlName('name'), [], [xml.XmlText('Lv')]),
    xml.XmlElement(
        xml.XmlName('code'),
        [xml.XmlAttribute(xml.XmlName('str'), 'int')],
        [xml.XmlText('0x1451dab1')]),
    xml.XmlElement(xml.XmlName('body'), [], [xml.XmlText(enemyLevel)])
  ]);
}

void updateLevelValueElement(
    xml.XmlElement levelValueElement, String enemyLevel) {
  var bodyElement = levelValueElement.findElements('body').firstOrNull;
  if (bodyElement != null) {
    bodyElement.children.clear();
    bodyElement.children.add(xml.XmlText(enemyLevel));
  }
}