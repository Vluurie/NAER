import 'package:xml/xml.dart' as xml;

handleBossLevel(xml.XmlElement objIdElement, String enemyLevel) {
  xml.XmlElement? parentValueElement = findParentValueElement(objIdElement);

  // Only proceed if a 'param' element is found
  if (parentValueElement != null) {
    var paramElement = parentValueElement.findElements('param').firstOrNull;

    if (paramElement != null) {
      // Update existing 'Lv', 'Lv_B', 'Lv_C' if they exist
      updateLevelValueIfExists(paramElement, 'Lv', enemyLevel);
      updateLevelValueIfExists(paramElement, 'LV', enemyLevel);
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
