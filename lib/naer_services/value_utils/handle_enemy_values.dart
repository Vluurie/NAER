import 'dart:math';
import 'package:NAER/data/values_data/nier_enemy_set_value_map.dart';
import 'package:xml/xml.dart' as xml;
import 'package:NAER/naer_services/XmlElementHandler/handle_xml_elements.dart';

/// Sets specific values for an XML element based on the provided EM number.
///
/// This function checks the values associated with the given EM number.
/// If the values are null, it removes 'setType', 'setRtn', and 'setFlag' elements
/// from the XML. Otherwise, it randomly chooses between setting 'setType' or 'setFlag'
/// based on the [em_number_values_map] and updates the XML accordingly.
/// Additionally, it ensures the 'rate' and 'levelRange' elements are always positioned correctly.
///
/// - Parameters:
///   - objIdElement: The XML element to update.
///   - newEmNumber: The EM number used to retrieve specific values.
void setSpecificValues(xml.XmlElement objIdElement, String newEmNumber) {
  var values = EnemyValues.emNumberValues[newEmNumber];
  if (values == null) {
    _removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  final selection = _chooseElementToSet(values);
  if (selection == null) {
    _removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  _updateElement(objIdElement, selection);
  _ensureRateIsCorrectlyPositioned(objIdElement);
  _ensureLevelRangeIsCorrectlyPositioned(objIdElement);
}

/// Chooses which element to set based on the provided values.
///
/// This function prioritizes 'setType' over 'setFlag' based on a 65% bias.
/// It evaluates the availability and validity of 'setType' and 'setFlag' values,
/// and returns a [MapEntry] containing the chosen element name and value.
///
/// - Parameters:
///   - values: A map containing 'setType' and 'setFlag' values.
/// - Returns: A [MapEntry] with the selected element name and value, or null if no valid value is found.
MapEntry<String, String>? _chooseElementToSet(Map<String, dynamic> values) {
  const int setTypeBias = 65;
  var setTypeValues = values['setType'] as List<int?>?;
  var setFlagValues = values['setFlag'] as List<int?>?;

  if (_shouldChooseSetType(setTypeValues, setFlagValues, setTypeBias)) {
    return _selectSetType(setTypeValues);
  } else {
    return _selectSetFlag(setFlagValues);
  }
}

/// Determines whether 'setType' should be chosen based on the provided values and bias.
///
/// - Parameters:
///   - setTypeValues: A list of possible 'setType' values.
///   - setFlagValues: A list of possible 'setFlag' values.
///   - setTypeBias: The bias percentage favoring 'setType'.
/// - Returns: True if 'setType' should be chosen, false otherwise.
bool _shouldChooseSetType(
    List<int?>? setTypeValues, List<int?>? setFlagValues, int setTypeBias) {
  return setTypeValues != null &&
      setTypeValues.isNotEmpty &&
      (setFlagValues == null ||
          setFlagValues.isEmpty ||
          Random().nextInt(100) < setTypeBias);
}

/// Selects a value from 'setTypeValues'.
///
/// This function randomly selects a value from the provided 'setTypeValues'.
/// If the selected value is 0, it returns null.
///
/// - Parameters:
///   - setTypeValues: A list of possible 'setType' values.
/// - Returns: A [MapEntry] with 'setType' and the selected value, or null if the value is 0.
MapEntry<String, String>? _selectSetType(List<int?>? setTypeValues) {
  if (setTypeValues == null || setTypeValues.isEmpty) return null;
  int? setTypeValue = setTypeValues[Random().nextInt(setTypeValues.length)];
  if (setTypeValue == 0) return null;
  return MapEntry('setType', setTypeValue.toString());
}

/// Selects a value from 'setFlagValues'.
///
/// This function randomly selects a value from the provided 'setFlagValues'
/// and converts it to a hexadecimal string prefixed with '0x'.
///
/// - Parameters:
///   - setFlagValues: A list of possible 'setFlag' values.
/// - Returns: A [MapEntry] with 'setFlag' and the selected value.
MapEntry<String, String>? _selectSetFlag(List<int?>? setFlagValues) {
  if (setFlagValues == null || setFlagValues.isEmpty) return null;
  int? setFlagValue = setFlagValues[Random().nextInt(setFlagValues.length)];
  if (setFlagValue == null) return null;
  return MapEntry('setFlag', "0x${setFlagValue.toRadixString(16)}");
}

/// Updates or creates the selected element within the XML structure.
///
/// This function finds the parent 'value' element and the correct insertion position
/// for the new element. It then removes conflicting elements and updates or creates
/// the selected element with the provided value.
///
/// - Parameters:
///   - objIdElement: The XML element to update.
///   - selection: A [MapEntry] containing the name and value of the element to set.
void _updateElement(
    xml.XmlElement objIdElement, MapEntry<String, String> selection) {
  var parentValueElement = _findParentValueElement(objIdElement);
  if (parentValueElement == null) return;

  int objIdIndex = _findObjIdIndex(parentValueElement);
  int rateIndex = _findRateIndex(parentValueElement);
  int levelRangeIndex = _findLevelRangeIndex(parentValueElement);
  int insertIndex = rateIndex != -1 ? rateIndex + 1 : objIdIndex + 1;

  XmlElementHandler.removeSpecifiedChildElements(parentValueElement,
      ['setRtn', selection.key == 'setType' ? 'setFlag' : 'setType']);

  XmlElementHandler.updateOrCreateElement(
      parentValueElement, selection.key, null, insertIndex, selection.value);

  if (levelRangeIndex != -1 && levelRangeIndex != objIdIndex + 2) {
    _ensureLevelRangeIsCorrectlyPositioned(objIdElement);
  }
}

/// Ensures the 'levelRange' element is correctly positioned after 'objId' and 'rate' (if it exists) and before 'setType' and 'setFlag' elements.
///
/// This function finds the 'levelRange' element and repositions it if necessary.
///
/// - Parameters:
///   - objIdElement: The XML element to check and adjust.
void _ensureLevelRangeIsCorrectlyPositioned(xml.XmlElement objIdElement) {
  var parentValueElement = _findParentValueElement(objIdElement);
  if (parentValueElement == null) return;

  int objIdIndex = _findObjIdIndex(parentValueElement);
  int rateIndex = _findRateIndex(parentValueElement);
  int levelRangeIndex = _findLevelRangeIndex(parentValueElement);
  int insertIndex = rateIndex != -1 ? rateIndex + 1 : objIdIndex + 1;

  if (levelRangeIndex != -1 && levelRangeIndex != insertIndex) {
    var levelRangeElement =
        parentValueElement.children[levelRangeIndex] as xml.XmlElement;
    parentValueElement.children.removeAt(levelRangeIndex);
    parentValueElement.children.insert(insertIndex, levelRangeElement);
  }
}

/// Ensures the 'rate' element is correctly positioned immediately after the 'objId' element.
///
/// This function finds the 'rate' element and repositions it if necessary.
///
/// - Parameters:
///   - objIdElement: The XML element to check and adjust.
void _ensureRateIsCorrectlyPositioned(xml.XmlElement objIdElement) {
  var parentValueElement = _findParentValueElement(objIdElement);
  if (parentValueElement == null) return;

  int objIdIndex = _findObjIdIndex(parentValueElement);
  int rateIndex = _findRateIndex(parentValueElement);

  if (rateIndex > objIdIndex + 1) {
    var rateElement = parentValueElement.children[rateIndex] as xml.XmlElement;
    parentValueElement.children.removeAt(rateIndex);
    parentValueElement.children.insert(objIdIndex + 1, rateElement);
  }
}

/// Finds the parent 'value' element starting from the given XML element.
///
/// This function traverses the XML tree upwards starting from the provided element
/// and returns the first parent element with the name 'value'.
///
/// - Parameters:
///   - startingElement: The XML element to start the search from.
/// - Returns: The parent 'value' element if found, or null otherwise.
xml.XmlElement? _findParentValueElement(xml.XmlElement startingElement) {
  var currentElement = startingElement.parent;
  while (currentElement != null && currentElement is xml.XmlElement) {
    if (currentElement.name.local == 'value') {
      return currentElement;
    }
    currentElement = currentElement.parent;
  }
  return null;
}

/// Finds the index of the 'objId' element within the parent 'value' element.
///
/// This function searches for the 'objId' element and returns its index.
///
/// - Parameters:
///   - parentValueElement: The parent 'value' element to search within.
/// - Returns: The index of the 'objId' element.
int _findObjIdIndex(xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere(
      (element) => element is xml.XmlElement && element.name.local == 'objId');
}

/// Finds the index of the 'rate' element within the parent 'value' element.
///
/// This function searches for the 'rate' element and returns its index.
///
/// - Parameters:
///   - parentValueElement: The parent 'value' element to search within.
/// - Returns: The index of the 'rate' element.
int _findRateIndex(xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere(
      (element) => element is xml.XmlElement && element.name.local == 'rate');
}

/// Finds the index of the 'levelRange' element within the parent 'value' element.
///
/// This function searches for the 'levelRange' element and returns its index.
///
/// - Parameters:
///   - parentValueElement: The parent 'value' element to search within.
/// - Returns: The index of the 'levelRange' element.
int _findLevelRangeIndex(xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere((element) =>
      element is xml.XmlElement && element.name.local == 'levelRange');
}

/// Removes 'setType', 'setRtn', and 'setFlag' elements from the XML element.
///
/// This function targets the specified elements for removal within the 'value' parent element.
///
/// - Parameters:
///   - objIdElement: The XML element from which to remove specified child elements.
void _removeSetTypeAndSetRtnAndSetFlag(xml.XmlElement objIdElement) {
  const elementsToRemove = ['setType', 'setRtn', 'setFlag'];
  XmlElementHandler.removeSpecifiedChildElements(
      objIdElement, elementsToRemove, 'value');
}
