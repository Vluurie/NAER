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
Future<void> setSpecificValues(
    final xml.XmlElement objIdElement, final String newEmNumber) async {
  var values = EnemyValues.emNumberValues[newEmNumber];
  if (values == null) {
    await _removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  final selection = _chooseElementToSet(values);
  if (selection == null) {
    await _removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  await _updateElement(objIdElement, selection);
  await _ensureRateIsCorrectlyPositioned(objIdElement);
  await _ensureLevelRangeIsCorrectlyPositioned(objIdElement);
}

/// Prioritizes 'setType' over 'setFlag' based on a 65% bias.
/// It evaluates the availability and validity of 'setType' and 'setFlag' values,
/// and returns a [MapEntry] containing the chosen element name and value.
MapEntry<String, String>? _chooseElementToSet(
    final Map<String, dynamic> values) {
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
bool _shouldChooseSetType(final List<int?>? setTypeValues,
    final List<int?>? setFlagValues, final int setTypeBias) {
  return setTypeValues != null &&
      setTypeValues.isNotEmpty &&
      (setFlagValues == null ||
          setFlagValues.isEmpty ||
          Random().nextInt(100) < setTypeBias);
}

/// Randomly selects a value from the provided 'setTypeValues'.
/// If the selected value is 0, it returns null.

MapEntry<String, String>? _selectSetType(final List<int?>? setTypeValues) {
  if (setTypeValues == null || setTypeValues.isEmpty) return null;
  int? setTypeValue = setTypeValues[Random().nextInt(setTypeValues.length)];
  if (setTypeValue == 0) return null;
  return MapEntry('setType', setTypeValue.toString());
}

/// Randomly selects a value from the provided 'setFlagValues'
/// and converts it to a hexadecimal string prefixed with '0x'.
MapEntry<String, String>? _selectSetFlag(final List<int?>? setFlagValues) {
  if (setFlagValues == null || setFlagValues.isEmpty) return null;
  int? setFlagValue = setFlagValues[Random().nextInt(setFlagValues.length)];
  if (setFlagValue == null) return null;
  return MapEntry('setFlag', "0x${setFlagValue.toRadixString(16)}");
}

/// Updates or creates the selected element within the XML structure.
Future<void> _updateElement(final xml.XmlElement objIdElement,
    final MapEntry<String, String> selection) async {
  var parentValueElement = _findParentValueElement(objIdElement);
  if (parentValueElement == null) return;

  int objIdIndex = _findObjIdIndex(parentValueElement);
  int rateIndex = _findRateIndex(parentValueElement);
  int levelRangeIndex = _findLevelRangeIndex(parentValueElement);
  int insertIndex = rateIndex != -1 ? rateIndex + 1 : objIdIndex + 1;

  await XmlElementHandler.removeSpecifiedChildElements(parentValueElement,
      ['setRtn', selection.key == 'setType' ? 'setFlag' : 'setType']);

  XmlElementHandler.updateOrCreateElement(
      parentValueElement, selection.key, null, insertIndex, selection.value);

  if (levelRangeIndex != -1 && levelRangeIndex != objIdIndex + 2) {
    await _ensureLevelRangeIsCorrectlyPositioned(objIdElement);
  }
}

/// Ensures the 'levelRange' element is correctly positioned after 'objId' and 'rate' (if it exists) and before 'setType' and 'setFlag' elements.
///
/// Finds the 'levelRange' element and repositions it if necessary.
Future<void> _ensureLevelRangeIsCorrectlyPositioned(
    final xml.XmlElement objIdElement) async {
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
/// Finds the 'rate' element and repositions it if necessary.
Future<void> _ensureRateIsCorrectlyPositioned(
    final xml.XmlElement objIdElement) async {
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
/// Traverses the XML tree upwards starting from the provided element
/// and returns the first parent element with the name 'value'.
xml.XmlElement? _findParentValueElement(final xml.XmlElement startingElement) {
  var currentElement = startingElement.parent;
  while (currentElement != null && currentElement is xml.XmlElement) {
    if (currentElement.name.local == 'value') {
      return currentElement;
    }
    currentElement = currentElement.parent;
  }
  return null;
}

///Searches for the 'objId' element and returns its index.
int _findObjIdIndex(final xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere((final element) =>
      element is xml.XmlElement && element.name.local == 'objId');
}

/// Searches for the 'rate' element and returns its index.
int _findRateIndex(final xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere((final element) =>
      element is xml.XmlElement && element.name.local == 'rate');
}

/// Sarches for the 'levelRange' element and returns its index.
int _findLevelRangeIndex(final xml.XmlElement parentValueElement) {
  return parentValueElement.children.indexWhere((final element) =>
      element is xml.XmlElement && element.name.local == 'levelRange');
}

/// Removes 'setType', 'setRtn', and 'setFlag' elements from the XML element.
///
/// Targets the elements for removal within the 'value' parent element.
Future<void> _removeSetTypeAndSetRtnAndSetFlag(
    final xml.XmlElement objIdElement) async {
  const elementsToRemove = ['setType', 'setRtn', 'setFlag'];
  await XmlElementHandler.removeSpecifiedChildElements(
      objIdElement, elementsToRemove, 'value');
}
