import 'package:xml/xml.dart' as xml;
import 'package:NAER/XmlElementHandler/xmlElementHandler.dart';
import 'emNumberValuesMap.dart' as emNumberValuesMap;

void setSpecificValues(xml.XmlElement objIdElement, String newEmNumber) {
  // Retrieve the values from the map
  var values = emNumberValuesMap.emNumberValues[newEmNumber];

  // If no values are found, remove elements and exit
  if (values == null) {
    removeSetTypeAndSetRtnAndSetFlag(objIdElement);
    return;
  }

  int? setTypeValue = values['setType'];
  int? setRtnValue = values['setRtn'];
  int? setFlagValue = values['setFlag'];

  // Navigate up to the parent 'value' element
  var currentElement = objIdElement.parent;
  xml.XmlElement? parentValueElement;

  while (currentElement != null && currentElement is xml.XmlElement) {
    if (currentElement.name.local == 'value') {
      parentValueElement = currentElement;
      break;
    }
    currentElement = currentElement.parent;
  }

  if (parentValueElement != null) {
    // Find the position where setType, setRtn, and setFlag should be inserted
    var paramElementIndex = parentValueElement.children.indexWhere((element) =>
        element is xml.XmlElement && element.name.local == 'param');

    // Handle setType element
    XmlElementHandler.updateOrCreateElement(
        parentValueElement, 'setType', setTypeValue, paramElementIndex, null);

    // Handle setRtn element
    XmlElementHandler.updateOrCreateElement(
        parentValueElement, 'setRtn', setRtnValue, paramElementIndex, null);

    // Handle setFlag element
    XmlElementHandler.updateOrCreateElement(
        parentValueElement, 'setFlag', setFlagValue, paramElementIndex, null);
  }
}

void removeSetTypeAndSetRtnAndSetFlag(xml.XmlElement objIdElement) {
  // Elements to remove
  List<String> elementsToRemove = ['setType', 'setRtn', 'setFlag'];

  // Using the generalized function to remove specific child elements
  XmlElementHandler.removeSpecifiedChildElements(objIdElement, elementsToRemove,
      'value' // This specifies that removal should occur within the 'value' parent element
      );
}
