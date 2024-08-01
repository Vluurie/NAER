import 'package:xml/xml.dart' as xml;

/// A utility class for handling XML element manipulations.
///
/// This class provides static methods to update, create, remove, and apply actions to XML elements.
class XmlElementHandler {
  /// Updates an existing XML element or creates a new one if it doesn't exist.
  ///
  /// If the element specified by [targetElementName] exists within [parentElement], its value is updated.
  /// If it doesn't exist, a new element is created and inserted at the specified [insertionPosition].
  /// The value of the element can be specified by either [numericalValue] or [textualValue].
  ///
  /// - Parameters:
  ///   - parentElement: The parent XML element where the target element resides or will be created.
  ///   - targetElementName: The name of the target element to update or create.
  ///   - numericalValue: An optional numerical value to set as the element's value.
  ///   - insertionPosition: The position to insert the new element if it doesn't exist.
  ///   - textualValue: An optional textual value to set as the element's value.
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
  ///
  /// This method clears the current children of [targetElement] and sets its text content to [newText].
  ///
  /// - Parameters:
  ///   - targetElement: The XML element to update.
  ///   - newText: The new text value to set.
  static void updateElementText(xml.XmlElement targetElement, String newText) {
    targetElement.children.clear();
    targetElement.children.add(xml.XmlText(newText));
  }

  /// Applies an action to all elements with the specified name within the parent element.
  ///
  /// This method finds all elements with the name [targetElementName] within [parentElement] and
  /// applies the provided [action] to each of them.
  ///
  /// - Parameters:
  ///   - parentElement: The parent XML element containing the target elements.
  ///   - targetElementName: The name of the target elements to which the action will be applied.
  ///   - action: A function to apply to each target element.
  static void applyActionToElements(xml.XmlElement parentElement,
      String targetElementName, void Function(xml.XmlElement) action) {
    var elements = parentElement.findElements(targetElementName);
    for (var element in elements) {
      action(element);
    }
  }

  /// Conditionally replaces or skips the value of elements based on an attribute match.
  ///
  /// This method finds all elements with the name [elementName] within [parentElement] and checks
  /// if they have an attribute [attributeName] with the value [attributeValueToMatch]. If a match is found,
  /// the element's inner text is set to [newValue].
  ///
  /// - Parameters:
  ///   - parentElement: The parent XML element containing the target elements.
  ///   - elementName: The name of the target elements.
  ///   - attributeName: The name of the attribute to match.
  ///   - attributeValueToMatch: The value of the attribute to match.
  ///   - newValue: The new value to set for matching elements.
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

  /// Removes specified child elements from the XML element.
  ///
  /// This method removes all elements with names specified in [elementNamesToRemove] from [startingElement].
  /// If [climbToParentWithName] is provided, it first climbs up the XML tree to the specified parent element
  /// before removing the child elements.
  ///
  /// - Parameters:
  ///   - startingElement: The XML element to start removing child elements from.
  ///   - elementNamesToRemove: A list of element names to remove.
  ///   - climbToParentWithName: An optional parent element name to climb to before removing child elements.
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

  /// Replaces the text content of the specified XML element with the given new text.
  ///
  /// This function clears the existing children of the XML element and adds
  /// a new text node with the specified [newText].
  ///
  /// Parameters:
  /// - [element]: The XML element whose text content is to be replaced.
  /// - [newText]: The new text to set for the XML element.
  static void replaceTextInXmlElement(xml.XmlElement element, String newText) {
    element.children.clear();
    element.children.add(xml.XmlText(newText));
  }
}
