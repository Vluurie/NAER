import 'package:xml/xml.dart' as xml;

class XmlElementHandler {
  static void updateOrCreateElement(
      xml.XmlElement parentElement,
      String targetElementName,
      int? numericalValue,
      int insertionPosition,
      String? textualValue) {
    // Find the existing element if any
    var existingElement =
        parentElement.findElements(targetElementName).firstOrNull;

    // Determine the value to insert
    var valueToInsert = numericalValue?.toString() ?? textualValue;

    if (existingElement == null && valueToInsert != null) {
      // If the element doesn't exist, create it with the provided value
      var newElement = xml.XmlElement(
          xml.XmlName(targetElementName), [], [xml.XmlText(valueToInsert)]);
      if (insertionPosition != -1 &&
          insertionPosition < parentElement.children.length) {
        parentElement.children.insert(insertionPosition, newElement);
      } else {
        parentElement.children.add(newElement);
      }
    } else if (existingElement != null && valueToInsert != null) {
      // If the element exists, update its text value
      updateElementText(existingElement, valueToInsert);
    } else if (existingElement != null) {
      // If no value to insert is provided, remove the existing element
      parentElement.children.remove(existingElement);
    }
  }

  static void updateElementText(xml.XmlElement targetElement, String newText) {
    targetElement.children.clear();
    targetElement.children.add(xml.XmlText(newText));
  }

  static void applyActionToElements(xml.XmlElement parentElement,
      String targetElementName, void Function(xml.XmlElement) action) {
    var elements = parentElement.findElements(targetElementName);
    for (var element in elements) {
      action(element);
    }
  }

  static void conditionallyReplaceOrSkipElementValue(
      xml.XmlElement parentElement,
      String elementName,
      String attributeName,
      String attributeValueToMatch,
      String newValue) {
    var elements = parentElement.findElements(elementName);
    for (var element in elements) {
      if (element.getAttribute(attributeName) == attributeValueToMatch) {
        element.innerText = newValue;
      }
    }
  }

  static void removeSpecifiedChildElements(
      xml.XmlElement startingElement, List<String> elementNamesToRemove,
      [String? climbToParentWithName]) {
    xml.XmlNode? targetNode = startingElement;

    if (climbToParentWithName != null) {
      while (targetNode != null) {
        if (targetNode is xml.XmlElement &&
            targetNode.name.local == climbToParentWithName) {
          break;
        }
        targetNode = targetNode.parent;
      }
    }

    if (targetNode is xml.XmlElement) {
      List<xml.XmlElement> elementsToRemove = [];

      for (var name in elementNamesToRemove) {
        var elements = targetNode.findElements(name);
        elementsToRemove.addAll(elements);
      }
      for (var element in elementsToRemove) {
        targetNode.children.remove(element);
      }
    }
  }
}
