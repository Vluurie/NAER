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

  XmlElementHandler.removeSpecifiedChildElements(objIdElement, elementsToRemove,
      'value' // This specifies that removal should occur within the 'value' parent element
      );
}
