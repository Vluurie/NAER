import 'dart:convert';
import 'package:xml/xml.dart' as xml;

enum ModifyXmlCriteria {
  /// Adds a new element to the XML document.
  /// User needs to provide:
  ///   - elementName: The name of the new element to be added.

  /// Example:
  ///   <root>
  ///     <existingElement>Some content</existingElement>
  ///   </root>
  /// After ADD_ELEMENT:
  ///   <root>
  ///     <existingElement>Some content</existingElement>
  ///     <newElement>New content</newElement>
  ///   </root>
  ADD_ELEMENT,

  /// Removes an existing element from the XML document.
  /// User needs to provide:
  ///   - elementName: The name of the element to be removed.

  /// Example:
  ///   <root>
  ///     <elementToRemove>Content to remove</elementToRemove>
  ///   </root>
  /// After REMOVE_ELEMENT:
  ///   <root></root>
  REMOVE_ELEMENT,

  /// Changes the value of an attribute in an element.
  /// User needs to provide:
  ///   - elementName: The name of the element containing the attribute.
  ///   - attributeName: The name of the attribute to be modified.
  ///   - attributeValue: The new value for the attribute.

  /// Example:
  ///   <root>
  ///     <element attribute="oldValue">Content</element>
  ///   </root>
  /// After MODIFY_ATTRIBUTE:
  ///   <root>
  ///     <element attribute="newValue">Content</element>
  ///   </root>
  MODIFY_ATTRIBUTE,

  /// Adds a new attribute to an existing element.
  /// User needs to provide:
  ///   - elementName: The name of the element to which the attribute will be added.
  ///   - attributeName: The name of the new attribute to be added.
  ///   - attributeValue: The value for the new attribute.

  /// Example:
  ///   <root>
  ///     <element>Content</element>
  ///   </root>
  /// After ADD_ATTRIBUTE:
  ///   <root>
  ///     <element newAttribute="value">Content</element>
  ///   </root>
  ADD_ATTRIBUTE,

  /// Deletes an attribute from an element.
  /// User needs to provide:
  ///   - elementName: The name of the element containing the attribute.
  ///   - attributeName: The name of the attribute to be removed.

  /// Example:
  ///   <root>
  ///     <element attribute="value">Content</element>
  ///   </root>
  /// After REMOVE_ATTRIBUTE:
  ///   <root>
  ///     <element>Content</element>
  ///   </root>
  REMOVE_ATTRIBUTE,

  /// Substitutes one element with another.
  /// User needs to provide:
  ///   - elementName: The name of the element to be replaced.
  ///   - modifyTo: The name of the new element.

  /// Example:
  ///   <root>
  ///     <elementToReplace>Content</elementToReplace>
  ///   </root>
  /// After REPLACE_ELEMENT:
  ///   <root>
  ///     <newElement>Content</newElement>
  ///   </root>
  REPLACE_ELEMENT,

  /// Changes the tag name of an element.
  /// User needs to provide:
  ///   - elementName: The name of the element to be renamed.
  ///   - modifyTo: The new name for the element.

  /// Example:
  ///   <root>
  ///     <oldElement>Content</oldElement>
  ///   </root>
  /// After RENAME_ELEMENT:
  ///   <root>
  ///     <newElement>Content</newElement>
  ///   </root>
  RENAME_ELEMENT,

  /// Adds a new element only if an element with the same tag does not already exist.
  /// User needs to provide:
  ///   - elementName: The name of the new element.
  ///   - modifyTo: The name of the new element to be added if it does not exist.

  /// Example:
  ///   <root>
  ///     <existingElement>Content</existingElement>
  ///   </root>
  /// After ADD_ELEMENT_IF_NOT_EXISTS:
  ///   <root>
  ///     <existingElement>Content</existingElement>
  ///     <newElement>If not exists</newElement>
  ///   </root>
  ADD_ELEMENT_IF_NOT_EXISTS,

  /// Adds a custom element with specified text content.
  /// User needs to provide:
  ///   - elementName: The name of the parent element.
  ///   - modifyTo: The name of the new element to be added.
  ///
  /// Example:
  ///   <root>
  ///     <parentElement>Content</parentElement>
  ///   </root>
  /// After ADD_CUSTOM_ELEMENT_WITH_TEXT:
  ///   <root>
  ///     <parentElement>
  ///       <newElement>Custom Text</newElement>
  ///     </parentElement>
  ///   </root>
  ADD_CUSTOM_ELEMENT_WITH_TEXT,

  /// Removes an element and all its child elements.
  /// User needs to provide:
  ///   - elementName: The name of the element to be removed.

  /// Example:
  ///   <root>
  ///     <parentElement>
  ///       <childElement>Content</childElement>
  ///     </parentElement>
  ///   </root>
  /// After REMOVE_ELEMENT_AND_ALL_CHILDREN:
  ///   <root></root>
  REMOVE_ELEMENT_AND_ALL_CHILDREN,

  /// Removes elements that meet a certain condition, such as having a specific attribute value.
  /// User needs to provide:
  ///   - elementName: The name of the element to search for.
  ///   - modifyTo: The condition for removal.

  /// Example:
  ///   <root>
  ///     <element attribute="value1">Content</element>
  ///     <element attribute="value2">Content</element>
  ///   </root>
  /// After REMOVE_ELEMENT_WITH_CONDITION:
  ///   <root>
  ///     <element attribute="value1">Content</element>
  ///   </root>
  REMOVE_ELEMENT_WITH_CONDITION,

  /// Adds an element and simultaneously inserts specified child elements.
  /// User needs to provide:
  ///   - elementName: The name of the parent element.
  ///   - modifyTo: The XML content to be inserted as children.

  /// Example:
  ///   <root>
  ///     <parentElement>Existing Content</parentElement>
  ///   </root>
  /// After ADD_ELEMENT_WITH_CHILDREN:
  ///   <root>
  ///     <parentElement>
  ///       <child1>Content1</child1>
  ///       <child2>Content2</child2>
  ///     </parentElement>
  ///   </root>
  ADD_ELEMENT_WITH_CHILDREN,

  /// Adds an element if a specified element and child exist.
  /// User needs to provide:
  ///   - elementName: The name of the parent element.
  ///   - modifyTo: The name of the new element to be added if the specified child exists.

  /// Example:
  ///   <root>
  ///     <parentElement>
  ///       <existingChild>Content</existingChild>
  ///     </parentElement>
  ///   </root>
  /// After ADD_ELEMENT_CONDITIONAL_ON_CHILD:
  ///   <root>
  ///     <parentElement>
  ///       <existingChild>Content</existingChild>
  ///       <newElement>If child exists</newElement>
  ///     </parentElement>
  ///   </root>
  ADD_ELEMENT_CONDITIONAL_ON_CHILD,

  /// Adds a comment node adjacent to a specified element.
  /// User needs to provide:
  ///   - elementName: The name of the element next to which the comment will be added.
  ///   - modifyTo: The text content of the comment.

  /// Example:
  ///   <root>
  ///     <element>Content</element>
  ///   </root>
  /// After ADD_COMMENT_NEXT_TO_ELEMENT:
  ///   <root>
  ///     <element>Content</element>
  ///     <!-- Comment added here -->
  ///   </root>
  ADD_COMMENT_NEXT_TO_ELEMENT,

  /// Removes all comment nodes from the document.

  /// Example:
  ///   <root>
  ///     <!-- Comment 1 -->
  ///     <element>Content</element>
  ///     <!-- Comment 2 -->
  ///   </root>
  /// After REMOVE_ALL_COMMENTS:
  ///   <root>
  ///     <element>Content</element>
  ///   </root>
  REMOVE_ALL_COMMENTS,

  /// Adds an element with children based on conditions.
  /// User needs to provide:
  ///   - elementName: The name of the parent element.
  ///   - modifyTo: The XML content for the child elements to be added based on conditions.

  /// Example:
  ///   <root>
  ///     <parentElement>Existing Content</parentElement>
  ///   </root>
  /// After ADD_ELEMENT_WITH_CONDITIONAL_CHILDREN:
  ///   <root>
  ///     <parentElement>
  ///       <child1>Content1</child1>
  ///       <!-- Child2 is added conditionally based on content -->
  ///     </parentElement>
  ///   </root>
  ADD_ELEMENT_WITH_CONDITIONAL_CHILDREN,

  /// Inserts a list of elements or objects and randomly modifies their content.
  /// User needs to provide:
  ///   - elementName: The name of the element where content will be inserted.
  ///   - modifyTo: The content to be inserted and randomized.

  /// Example:
  ///   <root>
  ///     <parentElement>Existing Content</parentElement>
  ///   </root>
  /// After INSERT_AND_RANDOMIZE_CONTENT:
  ///   <root>
  ///     <parentElement>
  ///       <child1>Randomized Content 1</child1>
  ///       <child2>Randomized Content 2</child2>
  ///     </parentElement>
  ///   </root>
  INSERT_AND_RANDOMIZE_CONTENT,

  /// Conditionally adds or modifies an element based on text name matches.
  /// User needs to provide:
  ///   - elementName: The name of the element to be added or modified.
  ///   - modifyTo: The text content or modification to be applied.

  /// Example:
  ///   <root>
  ///     <elementToModify>Old Content</elementToModify>
  ///   </root>
  /// After CONDITIONAL_ADD_OR_MODIFY_ELEMENT:
  ///   <root>
  ///     <elementToModify>New Content</elementToModify>
  ///   </root>
  CONDITIONAL_ADD_OR_MODIFY_ELEMENT,

  /// Finds specific text and replaces it.
  /// User needs to provide:
  ///   - elementName: The name of the element to search for text replacement.
  ///   - modifyTo: The text to find and the replacement text.

  /// Example:
  ///   <root>
  ///     <element>Original Text</element>
  ///   </root>
  /// After FIND_AND_REPLACE_TEXT:
  ///   <root>
  ///     <element>Modified Text</element>
  ///   </root>
  FIND_AND_REPLACE_TEXT,

  /// Creates a nested XML structure based on a list or array.
  /// User needs to provide:
  ///   - elementName: The name of the parent element.
  ///   - modifyTo: A serialized list or array representing nested elements.

  /// Example:
  ///   <root>
  ///     <parentElement>Existing Content</parentElement>
  ///   </root>
  /// After CREATE_STRUCTURE_FROM_LIST:
  ///   <root>
  ///     <parentElement>
  ///       <child1>Content1</child1>
  ///       <child2>Content2</child2>
  ///     </parentElement>
  ///   </root>
  CREATE_STRUCTURE_FROM_LIST,

  /// Removes elements that do not match a specific pattern.
  /// User needs to provide:
  ///   - elementName: The name of the element to search for matching patterns.
  ///   - modifyTo: The pattern to match for element removal.

  /// Example:
  ///   <root>
  ///     <element>Matched Text</element>
  ///     <element>Unmatched Text</element>
  ///   </root>
  /// After REMOVE_IF_NOT_MATCHING_PATTERN:
  ///   <root>
  ///     <element>Matched Text</element>
  ///   </root>
  REMOVE_IF_NOT_MATCHING_PATTERN,
}

dynamic modifyXml(
  xml.XmlDocument doc,
  ModifyXmlCriteria criteria, {
  String? elementName,
  String? modifyTo,
  String? attributeName,
  String? attributeValue,
  String? filePath,
}) {
  try {
    switch (criteria) {
      case ModifyXmlCriteria.ADD_ELEMENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError("Element name and content must be provided.");
        }
        // Loop through all elements and add the new element if it doesn't exist
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var newElement = xml.XmlElement(xml.XmlName(modifyTo));
          element.children.add(newElement);
        }
        break;

      case ModifyXmlCriteria.REMOVE_ELEMENT:
        if (elementName == null) {
          throw ArgumentError("Element name must be provided.");
        }
        // Recursively remove all elements with the specified name
        void removeElement(xml.XmlNode node) {
          var toRemove = <xml.XmlNode>[];
          for (var child in node.children) {
            if (child is xml.XmlElement &&
                child.name.toString() == elementName) {
              toRemove.add(child);
            } else {
              removeElement(child);
            }
          }
          toRemove.forEach(node.children.remove);
        }
        removeElement(doc);
        break;

      case ModifyXmlCriteria.MODIFY_ATTRIBUTE:
        if (elementName == null ||
            attributeName == null ||
            attributeValue == null) {
          throw ArgumentError(
              "Element name, attribute name, and new attribute value must be provided.");
        }
        // Loop through all elements and modify the attribute
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var attribute = element.attributes.firstWhere(
              (attr) => attr.name.toString() == attributeName,
              orElse: () =>
                  xml.XmlAttribute(xml.XmlName(attributeName), attributeValue));
          // Update or add the attribute
          if (element.attributes.contains(attribute)) {
            attribute.value = attributeValue;
          } else {
            element.attributes.add(attribute);
          }
        }
        break;

      case ModifyXmlCriteria.ADD_ATTRIBUTE:
        if (elementName == null ||
            attributeName == null ||
            attributeValue == null) {
          throw ArgumentError(
              "Element name, attribute name, and attribute value must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var attribute =
              xml.XmlAttribute(xml.XmlName(attributeName), attributeValue);
          if (!element.attributes
              .any((attr) => attr.name.local == attributeName)) {
            element.attributes.add(attribute);
          }
        }
        break;

// Case for REMOVE_ATTRIBUTE
      case ModifyXmlCriteria.REMOVE_ATTRIBUTE:
        if (elementName == null || attributeName == null) {
          throw ArgumentError(
              "Element name and attribute name must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          element.attributes
              .removeWhere((attr) => attr.name.local == attributeName);
        }
        break;

// Case for REPLACE_ELEMENT
      case ModifyXmlCriteria.REPLACE_ELEMENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Element name to be replaced and new element name must be provided.");
        }
        var elements = doc.findAllElements(elementName).toList();
        for (var element in elements) {
          var newElement = xml.XmlElement(xml.XmlName(modifyTo));
          newElement.children.addAll(element.children);
          element.parent!.children
            ..remove(element)
            ..add(newElement);
        }
        break;

      // Case for RENAME_ELEMENT
      case ModifyXmlCriteria.RENAME_ELEMENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Element name to be renamed and new element name must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var newElement = xml.XmlElement(
              xml.XmlName(modifyTo), element.attributes, element.children);
          element.parent!.children
            ..remove(element)
            ..add(newElement);
        }
        break;

// Case for ADD_ELEMENT_IF_NOT_EXISTS
      case ModifyXmlCriteria.ADD_ELEMENT_IF_NOT_EXISTS:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Parent element name and new element name must be provided.");
        }
        var parentElements = doc.findAllElements(elementName);
        for (var parent in parentElements) {
          if (!parent.findElements(modifyTo).isNotEmpty) {
            var newElement = xml.XmlElement(xml.XmlName(modifyTo));
            parent.children.add(newElement);
          }
        }
        break;

// Case for ADD_CUSTOM_ELEMENT_WITH_TEXT
      case ModifyXmlCriteria.ADD_CUSTOM_ELEMENT_WITH_TEXT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Parent element name and text content for the new element must be provided.");
        }
        var parentElements = doc.findAllElements(elementName);
        for (var parent in parentElements) {
          var newElement = xml.XmlElement(xml.XmlName(modifyTo));
          var textNode = xml.XmlText(modifyTo);
          newElement.children.add(textNode);
          parent.children.add(newElement);
        }
        break;

      // Case for REMOVE_ELEMENT_AND_ALL_CHILDREN
      case ModifyXmlCriteria.REMOVE_ELEMENT_AND_ALL_CHILDREN:
        if (elementName == null) {
          throw ArgumentError("Element name to be removed must be provided.");
        }
        void removeElementAndChildren(xml.XmlNode node) {
          var toRemove = <xml.XmlNode>[];
          for (var child in node.children) {
            if (child is xml.XmlElement && child.name.local == elementName) {
              toRemove.add(child);
            } else if (child is xml.XmlElement) {
              removeElementAndChildren(child);
            }
          }
          toRemove.forEach(node.children.remove);
        }
        removeElementAndChildren(doc);
        break;

// Case for REMOVE_ELEMENT_WITH_CONDITION
      case ModifyXmlCriteria.REMOVE_ELEMENT_WITH_CONDITION:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError("Element name and condition must be provided.");
        }
        void removeElementConditionally(xml.XmlNode node) {
          var toRemove = <xml.XmlNode>[];
          for (var child in node.children) {
            if (child is xml.XmlElement &&
                child.name.local == elementName &&
                child.value == modifyTo) {
              toRemove.add(child);
            } else if (child is xml.XmlElement) {
              removeElementConditionally(child);
            }
          }
          toRemove.forEach(node.children.remove);
        }
        removeElementConditionally(doc);
        break;

// Case for ADD_ELEMENT_WITH_CHILDREN
      case ModifyXmlCriteria.ADD_ELEMENT_WITH_CHILDREN:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Parent element name and new element name must be provided.");
        }
        // Example: modifyTo could be a string representing child elements in XML format
        var parentElements = doc.findAllElements(elementName);
        for (var parent in parentElements) {
          var newElement = xml.XmlElement(xml.XmlName(modifyTo));
          // Parse modifyTo to create child elements
          var childDoc = xml.XmlDocument.parse('<root>$modifyTo</root>');
          newElement.children.addAll(childDoc.rootElement.children);
          parent.children.add(newElement);
        }
        break;

      case ModifyXmlCriteria.ADD_ELEMENT_CONDITIONAL_ON_CHILD:
        // Check for null values and throw an appropriate error if necessary
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Both 'elementName' and 'modifyTo' must be provided.");
        }

        // Find all parent elements matching 'elementName'
        var parentElements = doc.findAllElements(elementName);
        if (parentElements.isEmpty) {
          throw StateError(
              "No parent elements found with name '$elementName'.");
        }

        // Iterate over each parent element
        for (var parent in parentElements) {
          // Only add a new element if the specified child exists
          if (parent.findElements(modifyTo).isNotEmpty) {
            // Create a unique name for the new element
            var newElementName =
                '${modifyTo}_unique_${DateTime.now().millisecondsSinceEpoch}';
            var newElement = xml.XmlElement(xml.XmlName(newElementName));

            // Add the new element to the parent
            parent.children.add(newElement);
          }
        }

        // Optionally, return some information about the operation
        return "Elements modified successfully.";

// Case for ADD_COMMENT_NEXT_TO_ELEMENT
      case ModifyXmlCriteria.ADD_COMMENT_NEXT_TO_ELEMENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Element name and comment text must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var commentNode = xml.XmlComment(modifyTo);
          element.parent?.children.insert(
              element.parent!.children.indexOf(element) + 1, commentNode);
        }
        break;

// Case for REMOVE_ALL_COMMENTS
      case ModifyXmlCriteria.REMOVE_ALL_COMMENTS:
        void removeAllComments(xml.XmlNode node) {
          var toRemove = <xml.XmlNode>[];
          for (var child in node.children) {
            if (child is xml.XmlComment) {
              toRemove.add(child);
            } else if (child is xml.XmlElement) {
              removeAllComments(child);
            }
          }
          toRemove.forEach(node.children.remove);
        }
        removeAllComments(doc);
        break;

// Case for ADD_ELEMENT_WITH_CONDITIONAL_CHILDREN
      case ModifyXmlCriteria.ADD_ELEMENT_WITH_CONDITIONAL_CHILDREN:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Parent element name and child elements string must be provided.");
        }
        var parentElements = doc.findAllElements(elementName);
        for (var parent in parentElements) {
          var childDoc = xml.XmlDocument.parse('<root>$modifyTo</root>');
          var newElement = xml.XmlElement(xml.XmlName(elementName));
          for (var child in childDoc.rootElement.children) {
            // Insert condition check here, e.g., based on child attributes or name
            newElement.children.add(child);
          }
          parent.children.add(newElement);
        }
        break;

// Case for INSERT_AND_RANDOMIZE_CONTENT
      case ModifyXmlCriteria.INSERT_AND_RANDOMIZE_CONTENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Element name and content to insert must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          var newContent =
              xml.XmlText(modifyTo); // Replace with actual randomization logic
          element.children.add(newContent);
        }
        break;

// Case for CONDITIONAL_ADD_OR_MODIFY_ELEMENT
      case ModifyXmlCriteria.CONDITIONAL_ADD_OR_MODIFY_ELEMENT:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Element name and condition/modification string must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          element.children.clear();
          element.children.add(xml.XmlText(modifyTo));
        }
        break;

// Case for FIND_AND_REPLACE_TEXT
      case ModifyXmlCriteria.FIND_AND_REPLACE_TEXT:
        if (elementName == null || modifyTo == null || attributeValue == null) {
          throw ArgumentError(
              "Element name, text to find, and replacement text must be provided.");
        }
        var elements = doc.findAllElements(elementName);
        for (var element in elements) {
          for (var child in element.children) {
            if (child is xml.XmlText && child.value.contains(modifyTo)) {
              var replacedText =
                  child.innerText.replaceAll(modifyTo, attributeValue);
              child.replace(xml.XmlText(replacedText));
            }
          }
        }
        break;

// Case for CREATE_STRUCTURE_FROM_LIST
      case ModifyXmlCriteria.CREATE_STRUCTURE_FROM_LIST:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError(
              "Parent element name and structure data must be provided.");
        }
        var parentElement = doc.findAllElements(elementName).first;
        // Assuming 'modifyTo' is a serialized JSON representing a list of elements
        var structure = jsonDecode(modifyTo) as List;
        for (var item in structure) {
          var newElement = xml.XmlElement(xml.XmlName(item['name']));
          // Add attributes, children, etc. based on item details
          parentElement.children.add(newElement);
        }
        break;

// Case for REMOVE_IF_NOT_MATCHING_PATTERN
      case ModifyXmlCriteria.REMOVE_IF_NOT_MATCHING_PATTERN:
        if (elementName == null || modifyTo == null) {
          throw ArgumentError("Element name and pattern must be provided.");
        }
        var pattern = RegExp(modifyTo);
        void removeElementsNotMatching(xml.XmlNode node) {
          var toRemove = <xml.XmlNode>[];
          for (var child in node.children) {
            if (child is xml.XmlElement && !pattern.hasMatch(child.innerText)) {
              toRemove.add(child);
            } else if (child is xml.XmlElement) {
              removeElementsNotMatching(child);
            }
          }
          toRemove.forEach(node.children.remove);
        }
        removeElementsNotMatching(doc);
        break;
    }

    return doc;
  } catch (e) {
    return 'Error modifying XML: $e';
  }
}
