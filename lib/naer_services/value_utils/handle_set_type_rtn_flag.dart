import 'dart:math';
import 'package:xml/xml.dart' as xml;
import 'package:NAER/naer_services/XmlElementHandler/handle_xml_elements.dart';
import 'package:NAER/nier_enemy_data/values_data/nier_enemy_setType_map.dart'
    as em_number_values_map;

void setSpecificValues(xml.XmlElement objIdElement, String newEmNumber) {
  var values = em_number_values_map.emNumberValues[newEmNumber];
  if (values == null) {
    removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  var setTypeValues = values['setType'];
  List<int?>? setFlagValues = values['setFlag'];

  const int setTypeBias =
      65; // Bias towards setType (65% setType favor, 35% setFlag favor)
  bool chooseSetType = setTypeValues != null &&
      setTypeValues.isNotEmpty &&
      (setFlagValues == null ||
          setFlagValues.isEmpty ||
          Random().nextInt(100) < setTypeBias);

  String? selectedElementName;
  String? valueToWrite;

  if (chooseSetType) {
    int setTypeValue = setTypeValues![Random().nextInt(setTypeValues.length)]!;
    if (setTypeValue == 0) {
      removeSetTypeAndSetRtnAndSetFlag(objIdElement);
      return;
    }
    selectedElementName = 'setType';
    valueToWrite = setTypeValue.toString();
  } else if (setFlagValues != null && setFlagValues.isNotEmpty) {
    int setFlagValue = setFlagValues[Random().nextInt(setFlagValues.length)]!;
    selectedElementName = 'setFlag';
    valueToWrite = "0x${setFlagValue.toRadixString(16)}";
  }

  var parentValueElement = findParentValueElement(objIdElement);
  if (parentValueElement != null &&
      selectedElementName != null &&
      valueToWrite != null) {
    var paramElementIndex = findInsertionPosition(parentValueElement);

    // Remove setRtn along with the unselected setType or setFlag
    XmlElementHandler.removeSpecifiedChildElements(parentValueElement,
        ['setRtn', selectedElementName == 'setType' ? 'setFlag' : 'setType']);

    // Update or create the selected element with the new value
    XmlElementHandler.updateOrCreateElement(parentValueElement,
        selectedElementName, null, paramElementIndex, valueToWrite);
  }
}

xml.XmlElement? findParentValueElement(xml.XmlElement startingElement) {
  var currentElement = startingElement.parent;
  while (currentElement != null && currentElement is xml.XmlElement) {
    if (currentElement.name.local == 'value') {
      return currentElement;
    }
    currentElement = currentElement.parent;
  }
  return null;
}

int findInsertionPosition(xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere(
      (element) => element is xml.XmlElement && element.name.local == 'param');
}

void removeSetTypeAndSetRtnAndSetFlag(xml.XmlElement objIdElement) {
  // Elements to remove
  List<String> elementsToRemove = ['setType', 'setRtn', 'setFlag'];

  XmlElementHandler.removeSpecifiedChildElements(objIdElement, elementsToRemove,
      'value' // This specifies that removal should occur within the 'value' parent element
      );
}
