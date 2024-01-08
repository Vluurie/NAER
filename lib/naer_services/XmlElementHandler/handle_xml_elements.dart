import 'package:xml/xml.dart' as xml;

class XmlElementHandler {
  static Future<void> updateOrCreateElement(
      xml.XmlElement parentElement,
      String targetElementName,
      int? numericalValue,
      int insertionPosition,
      String? textualValue) async {
    var existingElement =
        parentElement.findElements(targetElementName).firstOrNull;
    if (numericalValue != null) {
      var newElement = xml.XmlElement(xml.XmlName(targetElementName), [],
          [xml.XmlText(numericalValue.toString())]);
      if (existingElement == null) {
        if (insertionPosition != -1) {
          parentElement.children.insert(insertionPosition, newElement);
        } else {
          parentElement.children.add(newElement);
        }
      } else {
        updateElementText(existingElement, numericalValue.toString());
      }
    } else if (existingElement != null) {
      parentElement.children.remove(existingElement);
    }
  }

  static Future<void> updateElementText(
      xml.XmlElement targetElement, String newText) async {
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
