import 'package:xml/xml.dart' as xml;

class XmlElementHandler {
  /// Updates an existing XML element or creates a new one if it doesn't exist.
  ///
  /// If the element specified by [targetElementName] exists within [parentElement], its value is updated.
  /// If it doesn't exist, a new element is created and inserted at the specified [insertionPosition].
  /// The value of the element can be specified by either [numericalValue] or [textualValue].
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

  /// Updates the text value of the specified XML element.
  static void updateElementText(xml.XmlElement targetElement, String newText) {
    targetElement.children.clear();
    targetElement.children.add(xml.XmlText(newText));
  }

  /// Applies an action to all elements with the specified name within the parent element.
  static void applyActionToElements(xml.XmlElement parentElement,
      String targetElementName, void Function(xml.XmlElement) action) {
    var elements = parentElement.findElements(targetElementName);
    for (var element in elements) {
      action(element);
    }
  }

  /// Conditionally replaces or skips the value of elements based on an attribute match.
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

  /// Removes all elements with names specified in [elementNamesToRemove] from [startingElement].
  /// If [climbToParentWithName] is provided, it first climbs up the XML tree to the specified parent element
  /// before removing the child elements.

  static Future<void> removeSpecifiedChildElements(
      xml.XmlElement startingElement, List<String> elementNamesToRemove,
      [String? climbToParentWithName]) async {
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

  /// "text" -> "" -> "newText"
  static void replaceTextInXmlElement(xml.XmlElement element, String newText) {
    element.children.clear();
    element.children.add(xml.XmlText(newText));
  }
}
