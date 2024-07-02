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

  // add the value unterneath the objid element or enemies do not load
  int objIdIndex = _findObjIdIndex(parentValueElement);

  int insertIndex = objIdIndex + 1;

  XmlElementHandler.removeSpecifiedChildElements(parentValueElement,
      ['setRtn', selection.key == 'setType' ? 'setFlag' : 'setType']);

  XmlElementHandler.updateOrCreateElement(
      parentValueElement, selection.key, null, insertIndex, selection.value);
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
