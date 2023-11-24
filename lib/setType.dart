import 'package:xml/xml.dart' as xml;

import 'enemyfinder.dart';

void setSpecificValues(xml.XmlElement objIdElement, String newEmNumber) {
  int? setTypeValue;
  int? setRtnValue;
  int? setFlagValue;

  // Define setType values based on newEmNumber
  switch (newEmNumber) {
    case 'em0010':
      setTypeValue = 1;
      break;
    case 'em0030':
      setTypeValue = 1;
      break;
    case 'em0000':
      setTypeValue = 1;
      break;
    case 'em0040':
      setTypeValue = 1;
      break;
    case 'em0050':
      setTypeValue = 1;
      break;
    case 'em0002':
      setTypeValue = 3;
      break;
    case 'em0052':
      setTypeValue = 3;
      break;
    case 'em0032':
      setTypeValue = 1;
      break;
    case 'em0012':
      setTypeValue = 3;
      break;
    case 'em0060':
      setTypeValue = 2;
      break;
    case 'em0020':
      setTypeValue = 1;
      break;
    case 'emb016':
      setTypeValue = 2;
    case 'em0015':
      setTypeValue = 2;
      break;
    case 'em0055':
      setTypeValue = 4;
      break;
    case 'em0005':
      setTypeValue = 3;
      break;
    case 'em0006':
      setTypeValue = 3;
      break;
    case 'em0026':
      setTypeValue = 1;
      break;
    case 'em0017':
      setTypeValue = 2;
      break;
    case 'em0057':
      setTypeValue = 2;
      break;
    case 'em0054':
      setTypeValue = 1;
      break;
    case 'em0004':
      setTypeValue = 3;
      break;
    case 'em0014':
      setTypeValue = 1;
      break;
    case 'em0064':
      setTypeValue = 1;
      break;
    case 'em1030':
      setTypeValue = 6;
      break;
    case 'em2001':
      setTypeValue = 1;
      break;
    case 'em1060':
      setTypeValue = 2;
      break;
    case 'em1050':
      setTypeValue = 4;
      break;
    case 'em0046':
      setTypeValue = 1;
      break;
    case 'em1040':
      setTypeValue = 6;
      break;
    case 'em0016':
      setTypeValue = 2;
      break;
    case 'em1090':
      setTypeValue = 1;
      break;
    case 'em0056':
      setTypeValue = 2;
      break;
    case 'em1070':
      setTypeValue = 5;
      break;
    case 'em2007':
      setTypeValue = 1;
      break;
    case 'em0033':
      setTypeValue = 2;
      break;
    case 'em0086':
      setTypeValue = -1;
      break;
    case 'em0066':
      setTypeValue = 1;
      break;
    case 'em1061':
      setTypeValue = 8;
      break;
    case 'em0100':
      setTypeValue = 10;
      break;
    case 'em0013':
      setTypeValue = 4;
      break;
    case 'em0112':
      setTypeValue = 6;
    case 'emb015':
      setTypeValue = 4;
      break;
    case 'em0106':
      setTypeValue = 17;
      break;
    case 'em2006':
      setTypeValue = 1;
      break;
    case 'em0061':
      setTypeValue = 4;
      break;
    case 'em0068':
      setTypeValue = 1;
      break;
    case 'em002d':
      setTypeValue = 1;
      break;
    case 'em3010':
      setTypeValue = 6;
      break;
    case 'em8030':
      setTypeValue = 9;
      break;
    case 'em200d':
      setTypeValue = 1;
      break;
    case 'em5600':
      setTypeValue = 17;
      setRtnValue = 2;
      break;
    case 'em6400':
      setTypeValue = 17;
      setRtnValue = 2;
      break;
    default:
      removeSetTypeAndSetRtnAndSetFlag(objIdElement);
      return; // Exit if newEmNumber doesn't match any special case
  }
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
    _handleElement(
        parentValueElement, 'setType', setTypeValue, paramElementIndex);

    // Handle setRtn element
    _handleElement(
        parentValueElement, 'setRtn', setRtnValue, paramElementIndex);

    // Handle setFlag element
    _handleElement(
        parentValueElement, 'setFlag', setFlagValue, paramElementIndex);
  }
}

void _handleElement(
    xml.XmlElement parent, String elementName, int? value, int insertPosition) {
  var existingElement = parent.findElements(elementName).firstOrNull;
  if (value != null) {
    var newElement = xml.XmlElement(
        xml.XmlName(elementName), [], [xml.XmlText(value.toString())]);
    if (existingElement == null) {
      if (insertPosition != -1) {
        parent.children.insert(insertPosition, newElement);
      } else {
        parent.children.add(newElement);
      }
    } else {
      replaceTextInXmlElement(existingElement, value.toString());
    }
  } else if (existingElement != null) {
    parent.children.remove(existingElement);
  }
}

void removeSetTypeAndSetRtnAndSetFlag(xml.XmlElement objIdElement) {
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
    // Remove setType element if it exists
    var setTypeElement = parentValueElement.findElements('setType').firstOrNull;
    if (setTypeElement != null) {
      parentValueElement.children.remove(setTypeElement);
    }

    // Remove setRtn element if it exists
    var setRtnElement = parentValueElement.findElements('setRtn').firstOrNull;
    if (setRtnElement != null) {
      parentValueElement.children.remove(setRtnElement);
    }

    var setFlagElement = parentValueElement.findElements('setFlag').firstOrNull;
    if (setFlagElement != null) {
      parentValueElement.children.remove(setFlagElement);
    }
  }
}
