import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart' as xml;

enum OutputFormat { list, json, map, text, xml, print, dart }

/// Created by `Vluurie` with the use of the xml dart library.
///
/// The `XmlElementHandler` class offers a comprehensive suite of static methods
/// for sophisticated XML manipulation. This class is a powerful tool for developers
/// working with XML, providing an extensive range of functionalities including
/// element creation, updating, traversal, transformation, querying, and more. It is
/// designed to handle complex XML data structures efficiently, making it an
/// indispensable part of any XML processing toolkit.
///
/// Usage Examples:
///
/// - Updating or creating an element:
///   ```dart
///   var xmlDocument = xml.parse('<root><child>Initial</child></root>');
///   XmlElementHandler.updateOrCreateElement(xmlDocument.rootElement, 'child', 123, -1, null);
///   // This updates the text of <child> to '123' or creates it if it doesn't exist.
///   ```
///
/// XML Tree Representation:
/// ```
/// <root>
///   <child>123</child>
/// </root>
/// ```
///
/// - Applying a specific action to elements with a particular name:
///   ```dart
///   XmlElementHandler.applyActionToElements(xmlDocument.rootElement, 'child', (element) {
///     // Custom action on each 'child' element
///     print('Found child with text: ${element.innerText}');
///   });
///   // This prints the text of each <child> element.
///   ```
///
/// - Transforming elements into a list of other objects:
///   ```dart
///   var names = XmlElementHandler.transformElements<List<String>>(xmlDocument.rootElement, 'child', (element) => element.innerText);
///   // 'names' contains a list of texts from each <child> element.
///   ```
///
/// - Filtering elements based on a condition:
///   ```dart
///   var specificElements = XmlElementHandler.filterElementsByCondition(xmlDocument.rootElement, 'child', (element) => element.innerText.contains('some text'));
///   // 'specificElements' will contain a list of <child> elements that contain 'some text'.
///   ```
///
/// - Aggregating values from elements:
///   ```dart
///   var sum = XmlElementHandler.aggregateElementValues<int>(xmlDocument.rootElement, 'num', (prev, element) => prev + int.parse(element.innerText), 0);
///   // 'sum' calculates the total of the numerical values of <num> elements.
///   ```
///
/// The class is structured to be user-friendly, with method names and parameters
/// that are self-explanatory, making it easy to integrate into various XML handling
/// scenarios. Whether you are building complex data processing applications or
/// simply need to manipulate XML files, `XmlElementHandler` provides a robust and
/// flexible solution.
class XmlElementHandler {
  /// Updates an existing XML element with the given name within a parent element
  /// or creates a new one if it doesn't exist. This function allows for setting
  /// numerical or textual values and supports insertion at a specific position.
  ///
  /// This function is particularly useful for modifying XML documents by either
  /// updating existing elements or creating new ones when needed.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The XML element in which you want to
  ///   update or create the target element.
  /// - `targetElementName` (String): The name of the target element you want to
  ///   update or create.
  /// - `numericalValue` (int?): If provided, sets the numerical value of the target
  ///   element. If `numericalValue` is not provided or is `null`, the target element
  ///   will not have a numerical value.
  /// - `insertionPosition` (int): Determines the position at which the new element
  ///   should be inserted if it needs to be created. If `insertionPosition` is set to -1,
  ///   the new element is appended to the end of the parent element's children.
  /// - `textualValue` (String?): If provided, sets the textual value of the target
  ///   element. If `textualValue` is not provided or is `null`, the target element will
  ///   not have a textual value.
  ///
  /// Note: You can provide either `numericalValue`, `textualValue`, or both.
  ///
  /// Example:
  ///```dart
  ///
  /// void main() async {
  ///   final xmlString = '<root><a>Value A</a><b>Value B</b></root>';
  ///   final xmlDoc = xml.parse(xmlString);
  ///
  ///   final parentElement = xmlDoc.rootElement;
  ///   final targetElementName = 'c';
  ///   final numericalValue = 42;
  ///   final insertionPosition = -1; // Append to the end
  ///   final textualValue = 'New Text';
  ///
  ///   await XmlElementHandler.updateOrCreateElement(
  ///     parentElement,
  ///     targetElementName,
  ///     numericalValue,
  ///     insertionPosition,
  ///     textualValue,
  ///   );
  ///
  ///   print(xmlDoc.toXmlString(pretty: true));
  /// }
  /// ```
  /// In this example, the `updateOrCreateElement` function updates or creates a new
  /// element named 'c' within the `<root>` element with numerical and textual values.
  ///
  /// Output:
  /// ```xml
  /// <root>
  ///   <a>Value A</a>
  ///   <b>Value B</b>
  ///   <c>42</c>
  /// </root>
  /// ```
  /// The output XML shows the updated or newly created 'c' element with the specified
  /// numerical and textual values within the `<root>` element.
  ///
  /// Note that this function supports asynchronous execution as it may involve disk I/O
  /// when working with files or network resources.
  ///
  /// Throws an exception if [parentElement] is null or if [targetElementName] is not a
  /// valid XML element name.
  ///
  /// Returns: A `Future` that completes when the element update is finished.
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

  /// Updates the text content of the specified XML element.
  ///
  /// The [targetElement] is the XML element whose text content you want to update.
  ///
  /// The [newText] parameter specifies the new text content to set for the
  /// [targetElement].
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a>Old Text</a></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final targetElement = xmlDoc.findElements('a').single;
  /// final newText = 'Updated Text';
  ///
  /// await XmlElementHandler.updateElementText(targetElement, newText);
  ///
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  ///
  /// XML Tree Representation (Before Update):
  /// ```
  /// <root>
  ///   <a>Old Text</a>
  /// </root>
  /// ```
  ///
  /// XML Tree Representation (After Update):
  /// ```
  /// <root>
  ///   <a>Updated Text</a>
  /// </root>
  /// ```
  ///
  /// In the above example, the function updates the text content of the 'a'
  /// element to 'Updated Text'.
  ///
  /// Note that this function supports asynchronous execution as it may involve
  /// disk I/O when working with files or network resources.
  static Future<void> updateElementText(
      xml.XmlElement targetElement, String newText) async {
    targetElement.children.clear();
    targetElement.children.add(xml.XmlText(newText));
  }

  /// Applies a specified action to each child element of a given name within
  /// the parent element. This method is useful for batch processing of similar
  /// elements.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The XML element that contains the child elements
  ///   you want to process.
  /// - `targetElementName` (String): The name of the child elements you want to target
  ///   for the specified action.
  /// - `action` (void Function(xml.XmlElement)): The action function that you want to apply
  ///   to each matching child element. It takes an XML element as its argument and performs
  ///   a specific operation on it.
  ///
  /// Example:
  /// ```
  ///   final xmlString = '''
  ///     <root>
  ///       <item>Item A</item>
  ///       <item>Item B</item>
  ///       <item>Item C</item>
  ///     </root>
  ///   ''';
  ///   final xmlDoc = xml.parse(xmlString);
  ///
  ///   final parentElement = xmlDoc.rootElement;
  ///   final targetElementName = 'item';
  ///
  ///   print('Before applying the action:');
  ///   print(xmlDoc.toXmlString(pretty: true)); // Print the original XML tree.
  ///
  ///   XmlElementHandler.applyActionToElements(
  ///     parentElement,
  ///     targetElementName,
  ///     (element) {
  ///       final newText = 'Modified ${element.text}';
  ///       XmlElementHandler.updateElementText(element, newText);
  ///     },
  ///   );
  ///
  ///   print('\nAfter applying the action:');
  ///   print(xmlDoc.toXmlString(pretty: true)); // Print the modified XML tree.
  /// ```
  ///
  /// Expected Output:
  /// ```
  /// Before applying the action:
  /// <root>
  ///   <item>Item A</item>
  ///   <item>Item B</item>
  ///   <item>Item C</item>
  /// </root>
  ///
  /// After applying the action:
  /// <root>
  ///   <item>Modified Item A</item>
  ///   <item>Modified Item B</item>
  ///   <item>Modified Item C</item>
  /// </root>
  /// ```
  ///
  /// In the above example, the `applyActionToElements` function processes each 'item'
  /// element within the `<root>` element and applies the specified action, which modifies
  /// the text of each element. The expected output demonstrates the original XML tree
  /// and the modified XML tree after applying the action.
  ///
  /// Note that the `action` function in this example updates the text content of each
  /// 'item' element with a prefix 'Modified'.
  static void applyActionToElements(xml.XmlElement parentElement,
      String targetElementName, void Function(xml.XmlElement) action) {
    var elements = parentElement.findElements(targetElementName);
    for (var element in elements) {
      action(element);
    }
  }

  /// Transforms elements with a specific name using a provided function.
  /// This is useful for mapping XML elements to a different format or data structure.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The XML element containing the elements
  ///   you want to transform.
  /// - `targetElementName` (String): The name of the elements you want to target for
  ///   transformation.
  /// - `transform` (T Function(xml.XmlElement)): The transformation function that you
  ///   want to apply to each matching element. It takes an XML element as its argument
  ///   and returns a transformed value of type `T`.
  ///
  /// Returns:
  /// - List<T>: A list containing the transformed values of the matching elements.
  ///
  /// Example:
  /// ```
  ///   final xmlString = '''
  ///     <root>
  ///       <value>1</value>
  ///       <value>2</value>
  ///       <value>3</value>
  ///     </root>
  ///   ''';
  ///   final xmlDoc = xml.parse(xmlString);
  ///
  ///   final parentElement = xmlDoc.rootElement;
  ///   final targetElementName = 'value';
  ///
  ///   final transformedValues = XmlElementHandler.transformElements<int>(
  ///     parentElement,
  ///     targetElementName,
  ///     (element) {
  ///       return int.parse(element.text);
  ///     },
  ///   );
  ///
  ///   print('Transformed Values: $transformedValues');
  /// ```
  ///
  /// Expected Output:
  /// ```
  /// Transformed Values: [1, 2, 3]
  /// ```
  ///
  /// In the above example, the `transformElements` function processes each 'value'
  /// element within the `<root>` element and applies the specified transformation
  /// function, which parses the text content of each element as an integer. The
  /// expected output is a list containing the transformed values.
  ///
  /// Note that the `transform` function can map XML elements to values of different
  /// types, and the resulting list contains the transformed values.
  static List<T> transformElements<T>(xml.XmlElement parentElement,
      String targetElementName, T Function(xml.XmlElement) transform) {
    var elements = parentElement.findElements(targetElementName);
    return elements.map(transform).toList();
  }

  /// Filters and transforms XML elements based on specified conditions and mappers.
  ///
  /// This function allows for flexible filtering and transformation of XML elements within a
  /// parent element. It is useful for XML data processing tasks where specific elements
  /// need to be extracted and transformed based on certain criteria.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The XML element containing the elements to be processed.
  /// - `targetElementName` (String): The name of the elements to target for filtering and transformation.
  /// - `conditions` (List<bool Function(xml.XmlElement)>): A list of conditions to determine which elements to include. Each condition is a function that takes an `xml.XmlElement` and returns a `bool`.
  /// - `mappers` (List<T Function(xml.XmlElement)>): A list of mapper functions to transform each XML element into a desired output of type `T`.
  ///
  /// Returns:
  /// - List<T>: A list containing transformed values of the filtered XML elements.
  ///
  /// Example:
  /// ```
  ///   final xmlString = '<root><value>1</value><value>2</value><value>3</value></root>';
  ///   final xmlDoc = xml.parse(xmlString);
  ///
  ///   final filteredAndTransformed = XmlElementHandler.filterAndTransformElements(
  ///     xmlDoc.rootElement,
  ///     'value',
  ///     conditions: [(element) => int.tryParse(element.text) % 2 == 0],
  ///     mappers: [(element) => 'Number: ${element.text}'],
  ///   );
  ///
  ///   filteredAndTransformed.forEach(print);
  /// ```
  /// This example demonstrates filtering 'value' elements that contain even numbers and then transforming them into strings prefixed with 'Number: '. The output will be:
  /// - 'Number: 2'
  ///
  static List<T> filterAndTransformElements<T>(
    xml.XmlElement parentElement,
    String targetElementName, {
    required List<bool Function(xml.XmlElement)> conditions,
    required List<T Function(xml.XmlElement)> mappers,
  }) {
    List<xml.XmlElement> elements =
        parentElement.findAllElements(targetElementName).toList();
    List<T> result = [];

    for (var element in elements) {
      if (conditions.every((condition) => condition(element))) {
        result.addAll(mappers.map((mapper) => mapper(element)));
      }
    }

    return result;
  }

  /// Applies a specified action to each attribute of a given XML element and returns the modified XML tree.
  ///
  /// This function iterates over all attributes of the target XML element and applies a user-defined action.
  /// It is useful for scenarios where you need to manipulate, inspect, or process each attribute of an element
  /// and see the resulting modified XML tree.
  ///
  /// Parameters:
  /// - `targetElement` (xml.XmlElement): The XML element whose attributes are to be processed.
  /// - `action` (Function(String, String)): A function that defines the action to be applied to each attribute.
  ///   This function takes two parameters: the attribute name and its value, and should return the modified value.
  ///
  /// Returns:
  /// - xml.XmlNode: The root of the modified XML tree with applied attribute changes.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<item id="123" name="example" />';
  /// final xmlDoc = xml.parse(xmlString);
  /// final targetElement = xmlDoc.rootElement;
  ///
  /// final modifiedXmlRoot = XmlElementHandler.applyActionToAttributesAndGetModifiedXml(
  ///   targetElement,
  ///   (name, value) {
  ///     // Modify attributes as needed
  ///     if (name == 'id') {
  ///       // Modify the 'id' attribute value
  ///       return 'newIdValue';
  ///     } else if (name == 'name') {
  ///       // Modify the 'name' attribute value
  ///       return 'newNameValue';
  ///     }
  ///     // Return the original value if no modification is needed
  ///     return value;
  ///   }
  /// );
  ///
  /// print(modifiedXmlRoot.toXmlString(pretty: true));
  /// ```
  /// XML Tree Representation (Before Applying Action):
  /// ```xml
  /// <item id="123" name="example" />
  /// ```
  ///
  /// Expected Output (Modified XML Tree Representation):
  /// ```xml
  /// <!-- Modify attributes as needed -->
  /// <item id="newIdValue" name="newNameValue" />
  /// ```
  ///
  /// This example demonstrates how the function can be used to modify attributes of the `item` element and see
  /// the resulting modified XML tree with dynamic modification logic.
  ///

  static xml.XmlNode applyActionToAttributesAndGetModifiedXml(
      xml.XmlElement targetElement,
      String Function(String attributeName, String attributeValue) action) {
    targetElement.attributes.forEach((attribute) {
      final name = attribute.name.local;
      final value = attribute.value;

      // Apply the dynamic modification logic
      final modifiedValue = action(name, value);

      // Update the attribute with the modified value
      attribute.value = modifiedValue;
    });

    return targetElement.root;
  }

  /// Recursively applies a specified action to each child element of a given XML element,
  /// potentially modifying the XML tree.
  ///
  /// This function is ideal for deep traversal and manipulation of XML structures, allowing
  /// modifications to be applied to each element in the hierarchy.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The starting element for recursive traversal and modification.
  /// - `action` (Function(xml.XmlElement)): A function that defines the action to be applied
  ///   to each child element encountered during the recursion. This action can modify the element.
  ///
  /// Example Usage:
  /// Consider the following XML structure:
  /// ```xml
  /// <root>
  ///   <child id="1">
  ///     <subchild id="2"/>
  ///   </child>
  /// </root>
  /// ```
  /// The function can be used to add a new attribute to each element:
  /// ```dart
  /// XmlElementHandler.applyActionRecursively(xmlDoc.rootElement, (element) {
  ///   element.setAttribute('newAttr', 'value');
  /// });
  /// ```
  /// After applying the function, the modified XML structure will be:
  /// ```xml
  /// <root newAttr="value">
  ///   <child id="1" newAttr="value">
  ///     <subchild id="2" newAttr="value"/>
  ///   </child>
  /// </root>
  /// ```
  ///
  static void applyActionRecursively(
      xml.XmlElement parentElement, void Function(xml.XmlElement) action) {
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement) {
        action(node);
        node.children.forEach(recurse);
      }
    }

    recurse(parentElement);
  }

  /// Counts the number of elements with a specific name within a parent XML element.
  ///
  /// This function is useful for quantifying elements of a certain type within an XML structure,
  /// particularly when dealing with large or complex XML data.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The parent XML element within which to count the target elements.
  /// - `targetElementName` (String): The name of the elements to be counted.
  ///
  /// Returns:
  /// - int: The number of elements with the specified name found within the parent element.
  ///
  /// Example Usage:
  /// Consider the following XML structure:
  /// ```xml
  /// <root>
  ///   <item type="book"/>
  ///   <item type="book"/>
  ///   <item type="pen"/>
  /// </root>
  /// ```
  /// To count the number of 'item' elements with a 'type' attribute of 'book', you can use:
  /// ```dart
  /// int itemCount = XmlElementHandler.countElements(xmlDoc.rootElement, 'item');
  /// ```
  /// For the above XML, the output of `itemCount` will be `3`, as there are three 'item' elements.
  ///
  static int countElements(
      xml.XmlElement parentElement, String targetElementName) {
    return parentElement.findElements(targetElementName).length;
  }

  /// Recursively collects text content and parent element names from all target elements within the parent element and its descendants.
  ///
  /// This function searches for all elements with the given name within the parent element
  /// and its descendants, and aggregates their inner text along with the name of the parent element
  /// that contained it. It returns the result in different formats based on the specified output format.
  /// Optionally, the result can be written to a file if an output path is provided.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The parent element within which to start the search for target elements.
  /// - `parentElementName` (String): The name of the parent elements to search for.
  /// - `targetElementName` (String): The name of the elements to collect text content from.
  /// - `textKeyName` (String): The key to use for the text content in the result.
  /// - `outputFormat` (OutputFormat): The desired output format. Supported formats are list, JSON, map, text, and xml.
  /// - `outputPath` (String, optional): The file path where the output will be saved. If provided, the output is written to this file.
  ///
  /// Returns:
  /// - dynamic: The collected data in the specified output format. This can be a list of maps, a JSON string, a map, a text string, or an XML string, depending on the output format.
  ///
  /// Example Usage:
  /// Consider the following XML structure:
  /// ```xml
  /// <books>
  ///   <book>
  ///     <title>Effective Dart</title>
  ///     <author>John Doe</author>
  ///   </book>
  ///   <book>
  ///     <title>Flutter in Action</title>
  ///     <author>Jane Smith</author>
  ///   </book>
  /// </books>
  /// ```
  /// To collect the text content of all 'title' elements within 'book' elements, including nested ones, along with the name of the parent 'book' element as XML, you can use:
  /// ```dart
  /// String titlesXml = XmlElementHandler.collectAllTextWithParent(
  ///   xmlDoc.rootElement,
  ///   'book',
  ///   'title',
  ///   'text', // User-provided text key
  ///   OutputFormat.xml
  /// );
  /// ```
  /// If you want to save the output to a file, provide the optional `outputPath` parameter:
  /// ```dart
  /// XmlElementHandler.collectAllTextWithParent(
  ///   xmlDoc.rootElement,
  ///   'book',
  ///   'title',
  ///   'text', // User-provided text key
  ///   OutputFormat.xml,
  ///   'path/to/output.xml'
  /// );
  /// ```
  ///
  /// The function will return the result as well as save it to 'output.xml' if the file path is provided.

  static dynamic collectAllTextWithParent(
      xml.XmlElement parentElement,
      String parentElementName,
      String targetElementName,
      String textKeyName,
      OutputFormat outputFormat,
      [String? outputPath]) {
    final parentElements = parentElement.findElements(parentElementName);
    final result = <Map<String, String>>[];

    void collectTextWithParent(xml.XmlElement element, String parentName) {
      for (var child in element.children) {
        if (child is xml.XmlElement && child.name.local == targetElementName) {
          result.add({textKeyName: child.innerText, 'parent': parentName});
        }
        if (child is xml.XmlElement) {
          collectTextWithParent(child, child.name.local);
        }
      }
    }

    for (var parent in parentElements) {
      collectTextWithParent(parent, parent.name.local);
    }

    String formattedOutput =
        formatOutput(outputFormat, result, textKeyName, 'parent');

    // Write to file if outputPath is provided
    if (outputPath != null) {
      File(outputPath).writeAsStringSync(formattedOutput);
    }

    return formattedOutput;
  }

  /// Formats a list of maps into a string according to the specified output format.
  ///
  /// This function is designed to take a list of maps, where each map represents a data entity,
  /// and format this list into a string based on the chosen output format. The function
  /// is flexible and can handle various structures of data as specified by the key names.
  ///
  /// Parameters:
  /// - `outputFormat` (OutputFormat): The format in which the output should be generated.
  ///   Supported formats are list, JSON, map, text, and xml.
  /// - `result` (List<Map<String, String>>): The list of maps containing the data to be formatted.
  ///   Each map in the list represents a single entity with key-value pairs.
  /// - `textKeyName` (String): The key in the map that refers to the main text content to be formatted.
  /// - `parentKeyName` (String): The key in the map that refers to the parent element's name.
  ///   This is used in formats that organize data hierarchically.
  ///
  /// Returns:
  /// - String: The formatted string output based on the specified format.
  ///
  /// Formats:
  /// - `list`: Outputs the list as a newline-separated string, where each line represents one map.
  /// - `json`: Converts the list into a JSON string with proper indentation for readability.
  /// - `map`: Organizes data into a map-like structure in text, grouping child elements under their parents.
  /// - `text`: Creates a human-readable text representation, organizing data hierarchically.
  /// - `xml`: Constructs an XML string, grouping child elements under parent elements.
  ///
  /// Example Usage:
  /// ```dart
  /// List<Map<String, String>> data = [
  ///   {'text': 'Hello', 'parent': 'Greeting'},
  ///   {'text': 'World', 'parent': 'Greeting'}
  /// ];
  /// String formatted = formatOutput(OutputFormat.text, data, 'text', 'parent');
  /// print(formatted);
  /// ```
  /// This will output:
  /// ```
  /// Greeting:
  ///   - Hello
  ///   - World
  /// ```
  ///
  /// Note: This function assumes that the provided list and the keys in the maps are correctly
  /// structured and contain the necessary data. It does not perform validation on the input data.
  static String formatOutput(
      OutputFormat outputFormat,
      List<Map<String, String>> result,
      String textKeyName,
      String parentKeyName) {
    Map<String, List<Map<String, String>>> groupBy(
        List<Map<String, String>> list,
        String Function(Map<String, String>) getKey) {
      var map = <String, List<Map<String, String>>>{};
      for (var item in list) {
        String key = getKey(item);
        map.putIfAbsent(key, () => []).add(item);
      }
      return map;
    }

    switch (outputFormat) {
      case OutputFormat.list:
        return result.map((item) => item.toString()).join('\n');

      case OutputFormat.json:
        return const JsonEncoder.withIndent('  ').convert(result);

      case OutputFormat.map:
        final resultMap = <String, List<String>>{};
        for (var item in result) {
          final parent = item[parentKeyName]!;
          final text = item[textKeyName]!;
          if (resultMap.containsKey(parent)) {
            resultMap[parent]!.add(text);
          } else {
            resultMap[parent] = [text];
          }
        }

        final StringBuffer formattedOutput = StringBuffer();
        resultMap.forEach((parent, texts) {
          formattedOutput.writeln('$parent:');
          for (var text in texts) {
            formattedOutput.writeln('  - $text');
          }
        });
        return formattedOutput.toString();

      case OutputFormat.text:
        var groupedByParent = groupBy(result, (item) => item[parentKeyName]!);
        final formattedResult = groupedByParent.entries.map((entry) {
          String parent = entry.key;
          String childrenTexts =
              entry.value.map((item) => '- ${item[textKeyName]}').join('\n  ');
          return "$parent:\n  $childrenTexts";
        }).join('\n\n');
        return formattedResult;

      case OutputFormat.xml:
        final xmlBuilder = xml.XmlBuilder();
        xmlBuilder.processing('xml', 'version="1.0"');
        xmlBuilder.element('root', nest: () {
          var groupedByParent = groupBy(result, (item) => item['parent']!);
          groupedByParent.forEach((parent, items) {
            xmlBuilder.element(parent, nest: () {
              for (var item in items) {
                xmlBuilder.element(textKeyName, nest: () {
                  xmlBuilder.text(item[textKeyName]!);
                });
              }
            });
          });
        });

        final xmlDoc = xmlBuilder.buildDocument();
        return xmlDoc.toXmlString(pretty: true, indent: '  ');

      default:
        return result.map((item) => item.toString()).join('\n');
    }
  }

  /// Automatically adds or updates a specified attribute for every element in an XML structure.
  ///
  /// This function streamlines the process of uniformly modifying an entire XML document.
  /// It sets or updates a given attribute with a specific value for each element, starting
  /// from the parent element and recursively traversing all descendant elements.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The parent element from which to start the modifications.
  /// - `attributeName` (String): The name of the attribute to be added or updated.
  /// - `attributeValue` (String): The value to be set for the attribute.
  ///
  /// Example Usage:
  /// Given the following XML structure:
  /// ```xml
  /// <library>
  ///   <book>
  ///     <title>Effective Dart</title>
  ///   </book>
  ///   <magazine>
  ///     <title>Nature</title>
  ///   </magazine>
  /// </library>
  /// ```
  /// To add or update the 'processed' attribute with the value 'true' for each element, use:
  /// ```dart
  /// XmlElementHandler.applyAttributeToAllElements(xmlDoc.rootElement, 'processed', 'true');
  /// ```
  /// After applying the function, the modified XML structure will be:
  /// ```xml
  /// <library processed="true">
  ///   <book processed="true">
  ///     <title processed="true">Effective Dart</title>
  ///   </book>
  ///   <magazine processed="true">
  ///     <title processed="true">Nature</title>
  ///   </magazine>
  /// </library>
  /// ```
  ///
  static void applyAttributeToAllElements(xml.XmlElement parentElement,
      String attributeName, String attributeValue) {
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement) {
        node.setAttribute(attributeName, attributeValue);
        node.children.forEach(recurse);
      }
    }

    recurse(parentElement);
  }

  /// Finds the first XML element within a parent element that matches specified criteria.
  ///
  /// This function simplifies the process of locating a specific element based on its name
  /// and, optionally, its text content. It recursively searches through the children of the
  /// parent element to find the first element that meets these criteria.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The parent XML element within which to search.
  /// - `elementName` (String): The name of the element to search for.
  /// - `textContent` (String, optional): Optional text content to further filter the elements.
  ///
  /// Returns:
  /// - xml.XmlElement?: The first XML element that matches the specified criteria, or `null`
  ///   if no such element is found.
  ///
  /// Example Usage:
  /// Given the following XML structure:
  /// ```xml
  /// <root>
  ///   <a>Value A</a>
  ///   <b>Value B</b>
  ///   <c>Value C</c>
  /// </root>
  /// ```
  /// To find the first element named 'c' with the text 'Value C', use:
  /// ```dart
  /// final foundElement = XmlElementHandler.findFirstElement(
  ///   parentElement, 'c', 'Value C'
  /// );
  /// ```
  /// If such an element is found, the function will return the element. Otherwise, it returns `null`.
  ///
  static xml.XmlElement? findFirstElement(
      xml.XmlElement parentElement, String elementName,
      [String? textContent]) {
    xml.XmlElement? foundElement;
    void recurse(xml.XmlNode node) {
      if (foundElement != null) return;
      if (node is xml.XmlElement) {
        if (node.name.local == elementName &&
            (textContent == null || node.innerText == textContent)) {
          foundElement = node;
          return;
        } else {
          node.children.forEach(recurse);
        }
      }
    }

    recurse(parentElement);
    return foundElement;
  }

  /// Collects a list of attribute values for a specific attribute name across all
  /// XML elements with a specific name. This function is useful for aggregating
  /// data from similar elements.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements with the specified name and collect attribute values.
  ///
  /// The [targetElementName] parameter specifies the name of the target elements
  /// you want to search for.
  ///
  /// The [attributeName] parameter specifies the name of the attribute from which
  /// you want to collect values.
  ///
  /// Returns a list of attribute values for the specified attribute name from all
  /// matching elements. If no matching elements are found or if the specified
  /// attribute is missing in any element, an empty list is returned.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><item id="1">Item A</item><item id="2">Item B</item></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  /// final targetElementName = 'item';
  /// final attributeName = 'id';
  ///
  /// final attributeValues = XmlElementHandler.collectAttributes(
  ///   parentElement,
  ///   targetElementName,
  ///   attributeName,
  /// );
  ///
  /// print('Attribute values: $attributeValues');
  /// ```
  ///
  /// In the above example, the function collects the 'id' attribute values from
  /// all 'item' elements within the `<root>` element.
  static List<String> collectAttributes(xml.XmlElement parentElement,
      String targetElementName, String attributeName) {
    return parentElement
        .findElements(targetElementName)
        .map((element) => element.getAttribute(attributeName))
        .whereType<String>()
        .toList();
  }

  /// Iterates over each XML element within a parent element that has a specified
  /// attribute and applies a given action to each matching element. This function
  /// is useful for performing operations on elements that share a common attribute.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements with the specified attribute and apply the action.
  ///
  /// The [attributeName] parameter specifies the name of the attribute that the
  /// elements should possess to be considered for the action.
  ///
  /// The [action] parameter is a function that takes an XML element as its
  /// argument and performs an operation on that element.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><item id="1">Item A</item><item id="2">Item B</item></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  /// final attributeName = 'id';
  ///
  /// XmlElementHandler.eachElementWithAttribute(
  ///   parentElement,
  ///   attributeName,
  ///   (element) {
  ///     final id = element.getAttribute(attributeName);
  ///     print('Element with $attributeName=$id: ${element.text}');
  ///   },
  /// );
  /// ```
  ///
  /// In the above example, the function iterates over 'item' elements within the
  /// `<root>` element that have the 'id' attribute and prints their text content.
  static void eachElementWithAttribute(xml.XmlElement parentElement,
      String attributeName, void Function(xml.XmlElement) action) {
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement && node.getAttribute(attributeName) != null) {
        action(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
  }

  /// Searches for XML elements that match a given condition
  /// and outputs them in a specified format. The output can be printed to the console
  /// or saved to a file.
  ///
  /// Parameters:
  /// - [parentElement]: The root XML element to search within.
  /// - [predicate]: A function that defines the condition to match elements.
  /// - [format]: The output format for the matching elements.
  /// - [saveToFile]: (Optional) File path to save the output. If omitted, the output is printed to the console.
  ///
  /// Example Usage:
  /// ```
  /// final xmlString = '<root><item>Item A</item><item>Item B</item></root>';
  /// final xmlDoc = xml.XmlDocument.parse(xmlString);
  /// final parentElement = xmlDoc.rootElement;
  ///
  /// XmlElementHandler.outputMatchingElements(
  ///   parentElement,
  ///   (element) => element.text.contains('Item'),
  ///   OutputFormat.json,
  ///   'output.json'
  /// );
  /// ```
  /// In the above example, the method searches for elements containing 'Item' in their text
  /// within the `<root>` element and outputs the results in JSON format, saving it to 'output.json'.
  ///
  /// Example for `OutputFormat.list`:
  /// ```
  /// XmlElementHandler.outputMatchingElements(
  ///   parentElement,
  ///   (element) => element.name.toString() == 'item',
  ///   OutputFormat.list
  /// );
  /// ```
  /// In this example, the method searches for elements with the tag name 'item' and outputs the results
  /// as a formatted list. Each matching element is listed with its tag name and text content, neatly formatted for readability.
  ///
  /// Supported Output Formats:
  /// - `OutputFormat.json`: Outputs elements in a structured JSON format. Nested elements are
  ///   represented as arrays within their parent elements.
  /// - `OutputFormat.xml`: Outputs elements as an XML tree, maintaining the structure of the
  ///   original XML document. Each element is separated by newlines for readability.
  /// - `OutputFormat.print`: Provides a simplified text representation of each element,
  ///   showing the tag name, attributes, and text content.
  /// - `OutputFormat.list`: Outputs matching elements in a readable list format. Each element is
  ///   presented with its tag name and text content. The output is formatted with line breaks and
  ///   indentations for clarity.
  /// - `OutputFormat.map`: Outputs elements in a Dart map with indices as keys. Each value
  ///   is a Map representation of an XML element.
  /// - `OutputFormat.text`: Outputs only the text content of each element, normalized to remove
  ///   excess whitespace.
  /// - `OutputFormat.dart`: Outputs matching elements as a structured Dart map. This format is useful for
  ///   generating Dart code representations of XML data, especially when you need to map XML content to Dart objects.
  ///
  /// Example for `OutputFormat.dart`:
  /// ```
  /// XmlElementHandler.outputMatchingElements(
  ///   parentElement,
  ///   (element) => element.innerText.contains('em'),
  ///   OutputFormat.dart,
  ///   'output.dart'
  /// );
  /// ```
  /// In this example, the method searches for elements whose inner text contains 'em' and outputs the results
  /// as a Dart map in a file named 'output.dart'. Each matching element's inner text becomes a key in the map,
  /// and its child elements are mapped as key-value pairs. The resulting map is of the form:
  /// `Map<String, Map<String, dynamic>> data`.
  ///
  /// Throws:
  /// - `FileSystemException`: If there's an error in writing to the file specified by [saveToFile].
  ///
  ///
  static void outputMatchingElements(xml.XmlElement parentElement,
      bool Function(xml.XmlElement) predicate, OutputFormat format,
      [String? saveToFile]) {
    try {
      List<xml.XmlElement> matchingElements =
          _findAllMatchingElements(parentElement, predicate);

      // Check if there are any matching elements
      if (matchingElements.isEmpty) {
        print("No matching elements found.");
        return;
      }

      String output = _formatOutput(matchingElements, format, predicate);
      print("Formatting in format: $format");
      if (saveToFile != null) {
        _saveToFile(output, saveToFile);
      } else {
        print(output);
      }
    } catch (e) {
      // Handle or log the error appropriately
      print('An error occurred: $e');
    }
  }

  static String _formatOutput(List<xml.XmlElement> elements,
      OutputFormat format, bool Function(xml.XmlElement) predicate) {
    switch (format) {
      case OutputFormat.json:
        return JsonEncoder.withIndent('  ')
            .convert(elements.map(_elementToJson).toList());
      case OutputFormat.xml:
        return elements
            .map((e) => '\n' + e.toXmlString(pretty: true) + '\n')
            .join('\n');
      case OutputFormat.print:
        return elements.map(_formatElementForPrint).join('\n\n');
      case OutputFormat.list:
        StringBuffer formattedOutput = StringBuffer();

        for (var element in elements) {
          // Check if the element matches the user-defined predicate
          if (predicate(element)) {
            // Format the element and its text content
            formattedOutput.writeln('Element: "${element.name}"');
            formattedOutput
                .writeln('  Text: "${_normalizeText(element.text)}"');
            formattedOutput
                .writeln(); // Add an extra line for spacing between elements
          }
        }

        return formattedOutput.toString();

      case OutputFormat.dart:
        Map<String, String> dartMap = {};

        for (var element in elements) {
          if (predicate(element)) {
            // Check if the parent is an XmlElement and get its name
            String key = element.parent is xml.XmlElement
                ? (element.parent as xml.XmlElement).name.toString()
                : 'root';
            String value = _normalizeText(element.text).trim();

            dartMap[key] = value;
          }
        }

        // Formatting the map for Dart code output
        String mapEntries = dartMap.entries
            .map((entry) => '\'${entry.key}\': \'${entry.value}\'')
            .join(',\n');

        return 'Map<String, String> emNumberValues = {\n$mapEntries\n};';

      default:
        return '';
    }
  }

  static String _formatElementForPrint(xml.XmlElement element) {
    // Custom format for print
    var buffer = StringBuffer('Element "${element.name}":\n');
    if (element.attributes.isNotEmpty) {
      buffer.write('Attributes:\n');
      element.attributes.forEach((attr) {
        buffer.write('  ${attr.name}: ${attr.value}\n');
      });
    }
    buffer.write('Text: ${_normalizeText(element.innerText)}');
    return buffer.toString();
  }

  static String _formatElementForText(xml.XmlElement element) {
    // Custom format for text
    return _normalizeText(element.innerText);
  }

  static void _saveToFile(String content, String filePath) {
    try {
      File file = File(filePath);
      file.writeAsStringSync(content);
      print('Output saved to $filePath');
    } catch (e) {
      print('Failed to save file: $e');
    }
  }

  static List<xml.XmlElement> _findAllMatchingElements(
      xml.XmlElement parentElement, bool Function(xml.XmlElement) predicate) {
    List<xml.XmlElement> matchingElements = [];
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement && predicate(node)) {
        matchingElements.add(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
    return matchingElements;
  }

  static Map<String, dynamic> _elementToJson(xml.XmlElement element) {
    var result = <String, dynamic>{};

    // Add tag name
    result['tag'] = element.name.toString();

    // Add attributes if any
    if (element.attributes.isNotEmpty) {
      result['attributes'] = {
        for (var attr in element.attributes) attr.name.toString(): attr.value
      };
    }

    // Process child elements and text
    var children = element.children
        .whereType<xml.XmlElement>()
        .map(_elementToJson)
        .toList();
    if (children.isNotEmpty) {
      result['children'] = children;
    } else {
      // Add text content if there are no child elements
      var text = _normalizeText(element.innerText);
      if (text.isNotEmpty) {
        result['value'] = text;
      }
    }

    return result;
  }

  static String _normalizeText(String text) {
    // Replace multiple whitespaces (including newlines and tabs) with a single space and trim
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Aggregates values from elements using a custom logic function, such as summing
  /// numerical values or concatenating strings. This provides a flexible way to
  /// process and compute data from XML elements.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements with the specified name and aggregate their values.
  ///
  /// The [targetElementName] parameter specifies the name of the target elements
  /// you want to search for.
  ///
  /// The [aggregateFunction] parameter is a function that takes two arguments: the
  /// previous aggregated value (initially set to [initialValue]) and an XML element.
  /// This function defines the logic for aggregating values and must return the
  /// updated aggregated value.
  ///
  /// The [initialValue] parameter is the initial value to start the aggregation.
  ///
  /// Returns the aggregated value computed by applying the [aggregateFunction] to
  /// the target elements. The type of the aggregated value should match the return
  /// type of the [aggregateFunction].
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><item>10</item><item>20</item><item>30</item></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  /// final targetElementName = 'item';
  ///
  /// final total = XmlElementHandler.aggregateElementValues<int>(
  ///   parentElement,
  ///   targetElementName,
  ///   (previousValue, element) => previousValue + int.parse(element.text),
  ///   0,
  /// );
  ///
  /// print('Total: $total');
  /// ```
  ///
  /// In the above example, the function aggregates numerical values within 'item'
  /// elements by summing them.
  static T aggregateElementValues<T>(
      xml.XmlElement parentElement,
      String targetElementName,
      T Function(T previousValue, xml.XmlElement element) aggregateFunction,
      T initialValue) {
    var elements = parentElement.findElements(targetElementName);
    return elements.fold(initialValue,
        (previousValue, element) => aggregateFunction(previousValue, element));
  }

  /// Applies an action to each XML element within a parent element that matches
  /// specific criteria, such as text, integer values, or other custom conditions.
  /// This function is particularly useful for searching and manipulating elements
  /// based on various criteria.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements that match the specified criteria.
  ///
  /// The [condition] parameter is a function that takes an XML element as its
  /// argument and returns a boolean value. The function is used to evaluate whether
  /// an element meets the specified criteria.
  ///
  /// The [action] parameter is a function that takes an XML element as its argument
  /// and performs an operation on that element.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><item>Item A</item><item>Item B</item><value>42</value></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  ///
  /// // Example 1: Search and apply action based on text
  /// XmlElementHandler.applyActionToElementsMatching(
  ///   parentElement,
  ///   (element) => element.text.contains('Item'),
  ///   (element) {
  ///     print('Matching element (text): ${element.name} - ${element.text}');
  ///   },
  /// );
  ///
  /// // Output for Example 1:
  /// // Matching element (text): item - Item A
  /// // Matching element (text): item - Item B
  ///
  /// // Example 2: Search and apply action based on integer values
  /// XmlElementHandler.applyActionToElementsMatching(
  ///   parentElement,
  ///   (element) {
  ///     final text = element.text;
  ///     return int.tryParse(text) != null && int.parse(text) > 10;
  ///   },
  ///   (element) {
  ///     print('Matching element (integer): ${element.name} - ${element.text}');
  ///   },
  /// );
  ///
  /// // Output for Example 2:
  /// // Matching element (integer): value - 42
  /// ```
  ///
  /// In the above examples, the function searches for elements within the `<root>`
  /// element that match specific criteria, either based on text content or integer
  /// values, and applies the specified action to each matching element. The output
  /// shows the matched elements along with their details.
  static void applyActionToElementsMatching(
      xml.XmlElement parentElement,
      bool Function(xml.XmlElement) condition,
      void Function(xml.XmlElement) action) {
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement && condition(node)) {
        action(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
  }

  /// Groups XML elements within a parent element by their tag name, returning a
  /// map with tag names as keys and lists of elements as values. This function
  /// is useful for categorizing and processing elements based on their types.
  ///
  /// The [parentElement] is the XML element within which you want to group
  /// elements by their tag names.
  ///
  /// Returns a map where each key is a unique tag name found within the
  /// [parentElement], and the corresponding value is a list of XML elements with
  /// that tag name. If no elements are found, an empty map is returned.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a>Element 1</a><b>Element 2</b><a>Element 3</a></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  ///
  /// final groupedElements = XmlElementHandler.groupElementsByTag(parentElement);
  ///
  /// groupedElements.forEach((tagName, elements) {
  ///   print('Elements with tag $tagName:');
  ///   elements.forEach((element) {
  ///     print('  ${element.text}');
  ///   });
  /// });
  /// ```
  ///
  /// In the above example, the function groups elements within the `<root>` element
  /// by their tag names and prints the elements within each group.
  ///
  /// Returns an empty map if no elements are found within the [parentElement].
  static Map<String, List<xml.XmlElement>> groupElementsByTag(
      xml.XmlElement parentElement) {
    Map<String, List<xml.XmlElement>> groupedElements = {};
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement) {
        groupedElements.putIfAbsent(node.name.local, () => []).add(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
    return groupedElements;
  }

  /// Finds all XML elements within a parent element that have a specific attribute
  /// with a given value. This function is useful for filtering elements based on
  /// attribute criteria.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements with the specified attribute value.
  ///
  /// The [attributeName] parameter specifies the name of the attribute you want
  /// to check for.
  ///
  /// The [attributeValue] parameter specifies the value that the attribute should
  /// have for an element to be considered a match.
  ///
  /// Returns a list of XML elements that have the specified attribute with the
  /// given value. If no matching elements are found, an empty list is returned.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a id="1">Element 1</a><b id="2">Element 2</b></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  /// final attributeName = 'id';
  /// final attributeValue = '2';
  ///
  /// final matchingElements = XmlElementHandler.findAllElementsWithAttributeValues(
  ///     parentElement, attributeName, attributeValue);
  ///
  /// matchingElements.forEach((element) {
  ///   print('Element with attribute $attributeName=$attributeValue: ${element.name}');
  /// });
  /// ```
  ///
  /// In the above example, the function finds and prints the 'b' element within
  /// the `<root>` element, which has the attribute 'id' with the value '2'.
  ///
  /// Returns an empty list if no elements with the specified attribute and value
  /// are found within the [parentElement].
  static List<xml.XmlElement> findAllElementsWithAttributeValues(
      xml.XmlElement parentElement,
      String attributeName,
      String attributeValue) {
    List<xml.XmlElement> matchingElements = [];
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement &&
          node.getAttribute(attributeName) == attributeValue) {
        matchingElements.add(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
    return matchingElements;
  }

  /// Finds all XML elements within a parent element that have one or more child
  /// elements. This function is useful for identifying parent elements or
  /// processing complex nested XML structures.
  ///
  /// The [parentElement] is the XML element within which you want to search for
  /// elements with child elements.
  ///
  /// Returns a list of XML elements that have at least one child element. If no
  /// such elements are found, an empty list is returned.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a><b>1</b></a><c>2</c></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  ///
  /// final elementsWithChildren =
  ///     XmlElementHandler.findAllElementsWithChildren(parentElement);
  ///
  /// elementsWithChildren.forEach((element) {
  ///   print('Element with children: ${element.name}');
  /// });
  /// ```
  ///
  /// In the above example, the function finds and prints elements ('a' in this case)
  /// within the `<root>` element that have child elements.
  ///
  /// Returns an empty list if no elements with child elements are found within
  /// the [parentElement].
  static List<xml.XmlElement> findAllElementsWithChildren(
      xml.XmlElement parentElement) {
    List<xml.XmlElement> elementsWithChildren = [];
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement &&
          node.children.any((child) => child is xml.XmlElement)) {
        elementsWithChildren.add(node);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
    return elementsWithChildren;
  }

  /// Calculates the depth of a specific XML element within the XML structure
  /// relative to a given parent element. This function is useful for determining
  /// the hierarchical level of a particular element within an XML document.
  ///
  /// The [parentElement] is the XML element that serves as the starting point for
  /// the depth calculation.
  ///
  /// The [targetElement] is the XML element whose depth is to be calculated
  /// relative to the [parentElement].
  ///
  /// Returns the depth of the [targetElement] within the XML structure. If the
  /// [targetElement] is not found within the [parentElement]'s hierarchy, it returns
  /// -1.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a><b><c>1</c></b></a><d>2</d></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// final parentElement = xmlDoc.rootElement;
  /// final targetElement = xmlDoc.findElements('c').single;
  ///
  /// final depth = XmlElementHandler.calculateDepthOfElement(parentElement, targetElement);
  /// print('Depth of targetElement: $depth');
  /// ```
  ///
  /// In the above example, the function calculates the depth of the 'c' element
  /// relative to the `<root>` element and prints the result.
  ///
  /// Returns -1 if the [targetElement] is not found within the [parentElement].
  static int calculateDepthOfElement(
      xml.XmlElement parentElement, xml.XmlElement targetElement) {
    int depth = 0;
    bool found = false;
    void recurse(xml.XmlNode node, int currentDepth) {
      if (found) return;
      if (node == targetElement) {
        depth = currentDepth;
        found = true;
        return;
      }
      if (node is xml.XmlElement) {
        node.children.forEach((child) => recurse(child, currentDepth + 1));
      }
    }

    recurse(parentElement, 0);
    return found ? depth : -1; // Returns -1 if the element is not found
  }

  /// Applies a specified action to every pair of adjacent XML elements within a
  /// parent XML element. This function is useful for performing operations
  /// involving sequential elements or conducting comparative analysis between
  /// adjacent elements.
  ///
  /// The [parentElement] is the XML element containing child elements that you
  /// want to process in pairs.
  ///
  /// The [action] parameter is a function that takes two XML elements as
  /// arguments: the first element represents the previous element in the sequence,
  /// and the second element represents the current element in the sequence.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a>1</a><b>2</b><c>3</c></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// void printPair(xml.XmlElement prev, xml.XmlElement curr) {
  ///   print('Pair: ${prev.name} - ${curr.name}');
  /// }
  ///
  /// MyClass.forEachElementPair(xmlDoc.rootElement, printPair);
  /// ```
  ///
  /// In the above example, the `printPair` function is applied to every adjacent
  /// pair of child elements within the `<root>` element.
  ///
  /// Throws an exception if [parentElement] is null or if it contains less than
  /// two child elements.
  static void forEachElementPair(xml.XmlElement parentElement,
      void Function(xml.XmlElement, xml.XmlElement) action) {
    var previousElement = parentElement.firstChild as xml.XmlElement?;
    for (var node in parentElement.children.skip(1)) {
      if (node is xml.XmlElement && previousElement != null) {
        action(previousElement, node);
        previousElement = node;
      }
    }
  }

  /// Recursively applies a specified action to each element up to a specified depth
  /// within an XML structure. This function allows you to control the depth of
  /// traversal, making it useful for efficiently processing large or deeply nested
  /// XML documents.
  ///
  /// The [parentElement] is the XML element from which traversal begins.
  ///
  /// The [depth] parameter determines the maximum depth to which elements are
  /// traversed. Elements at a depth greater than the specified value will not be
  /// processed.
  ///
  /// The [action] parameter is a function that takes two arguments: an XML element
  /// and its current depth in the XML structure. This function is applied to each
  /// eligible element within the specified depth.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><a><b><c>1</c></b></a><d>2</d></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// void printElement(xml.XmlElement element, int depth) {
  ///   print('Depth $depth: ${element.name}');
  /// }
  ///
  /// XmlElementHandler.applyActionToDepth(xmlDoc.rootElement, 2, printElement);
  /// ```
  ///
  /// In the above example, the `printElement` function is applied to elements within
  /// a depth of 2 from the root element of the XML document.
  ///
  /// Note that the depth is zero-based, so a depth of 0 processes only the
  /// [parentElement] itself.
  ///
  /// Throws an exception if [parentElement] is null or if [depth] is less than 0.
  static void applyActionToDepth(xml.XmlElement parentElement, int depth,
      void Function(xml.XmlElement, int) action) {
    void recurse(xml.XmlNode node, int currentDepth) {
      if (currentDepth > depth) return;
      if (node is xml.XmlElement) {
        action(node, currentDepth);
        node.children.forEach((child) => recurse(child, currentDepth + 1));
      }
    }

    recurse(parentElement, 0);
  }

  /// Updates specific child elements within an XML parent element with new values.
  ///
  /// This function allows for targeted modifications of child elements based on their names.
  /// It is useful for making updates to specific elements within a parent element, replacing
  /// their contents with new values.
  ///
  /// Parameters:
  /// - `parentElement` (xml.XmlElement): The XML element containing child elements to be updated.
  /// - `childElementNames` (List<String>): A list of the names of child elements to be updated.
  /// - `newValue` (String): The new value to replace the contents of each specified child element.
  ///
  /// Example Usage:
  /// Given the following XML structure:
  /// ```xml
  /// <root>
  ///   <a>oldValue</a>
  ///   <b>oldValue</b>
  ///   <c>oldValue</c>
  /// </root>
  /// ```
  /// To update elements 'a' and 'b' with the new value 'newValue', use:
  /// ```dart
  /// XmlElementHandler.updateSpecificChildElements(
  ///   xmlDoc.rootElement,
  ///   ['a', 'b'],
  ///   'newValue',
  /// );
  /// ```
  /// After applying the function, the modified XML structure will be:
  /// ```xml
  /// <root>
  ///   <a>newValue</a>
  ///   <b>newValue</b>
  ///   <c>oldValue</c>
  /// </root>
  /// ```
  ///
  static void updateSpecificChildElements(xml.XmlElement parentElement,
      List<String> childElementNames, String newValue) {
    for (var name in childElementNames) {
      var elements = parentElement.findElements(name);
      for (var element in elements) {
        // Update the element with the new value
        element.children.clear();
        element.children.add(xml.XmlText(newValue));
      }
    }
  }

  /// Merges elements with the same name within the parent element.
  /// The text contents of these elements are concatenated.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><item>A</item><item>B</item></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// // Merge elements with the name 'item' within the <root> element.
  /// XmlElementHandler.mergeElements(xmlDoc.rootElement, 'item');
  ///
  /// // The <root> element now contains a single <item> with text 'AB'.
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  /// In this example, the function merges elements with the specified name ('item') within the `<root>` element.
  /// The text contents of these elements ('A' and 'B') are concatenated, resulting in a single `<item>` element
  /// with the text 'AB'.
  ///
  /// Original XML structure:
  /// ```xml
  /// <root>
  ///   <item>A</item>
  ///   <item>B</item>
  /// </root>
  /// ```
  ///
  /// Modified XML structure after merging:
  /// ```xml
  /// <root>
  ///   <item>AB</item>
  /// </root>
  /// ```
  ///
  /// The function locates elements with the same name within the parent element and concatenates their text contents.
  ///
  /// Note: This function modifies the provided XML document in place.
  ///
  /// Parameters:
  /// - `parentElement`: The XML element containing elements to be merged.
  /// - `targetElementName`: The name of the elements to be merged.
  static void mergeElements(
      xml.XmlElement parentElement, String targetElementName) {
    var elements = parentElement.findElements(targetElementName).toList();
    if (elements.isEmpty) return;

    // Concatenate the text of all elements
    var combinedText = elements.map((e) => e.innerText).join();
    var newElement = xml.XmlElement(
        xml.XmlName(targetElementName), [], [xml.XmlText(combinedText)]);

    // Remove old elements and add the new one
    elements.forEach(parentElement.children.remove);
    parentElement.children.add(newElement);
  }

  /// Converts child elements of a specified parent element into attributes
  /// of the parent. This is useful for simplifying XML structures.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<person><name>John</name><age>30</age></person>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// // Convert child elements of the <person> element into attributes.
  /// XmlElementHandler.convertElementsToAttributes(xmlDoc.rootElement, 'person');
  ///
  /// // The <person> element now has attributes 'name' and 'age'.
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  /// In this example, the function converts child elements of the specified `<person>` element
  /// into attributes of the parent element. After the conversion, the `<person>` element has
  /// attributes 'name' and 'age', simplifying the XML structure.
  ///
  /// Original XML structure:
  /// ```xml
  /// <person>
  ///   <name>John</name>
  ///   <age>30</age>
  /// </person>
  /// ```
  ///
  /// Modified XML structure with attributes:
  /// ```xml
  /// <person name="John" age="30"/>
  /// ```
  ///
  /// The function searches for the specified parent element and converts its child elements
  /// into attributes, using the element names as attribute names and the element text content
  /// as attribute values.
  ///
  /// Note: This function modifies the provided XML document in place.
  ///
  /// Parameters:
  /// - `parentElement`: The XML element containing child elements to be converted into attributes.
  /// - `parentElementName`: The name of the parent element whose children should be converted.
  static void convertElementsToAttributes(
      xml.XmlElement parentElement, String parentElementName) {
    var targetParent =
        parentElement.findElements(parentElementName).firstOrNull;
    if (targetParent == null) return;

    targetParent.children.whereType<xml.XmlElement>().forEach((child) {
      targetParent.setAttribute(child.name.local, child.innerText);
      targetParent.children.remove(child);
    });
  }

  /// Extracts paths to deeply nested elements, represented as a list of element names.
  /// This can be used to understand the structure or to navigate complex XML trees.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '''
  ///   <root>
  ///     <action>
  ///       <layouts>
  ///         <normal>
  ///           <layouts>
  ///             <value>Value 1</value>
  ///           </layouts>
  ///         </normal>
  ///         <hard>
  ///           <layouts>
  ///             <value>Value 2</value>
  ///           </layouts>
  ///         </hard>
  ///       </layouts>
  ///     </action>
  ///   </root>
  /// ''';
  ///
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// // Extract paths to 'value' elements within the XML document.
  /// final paths = XmlElementHandler.extractNestedElementPaths(
  ///   xmlDoc.rootElement,
  ///   'value',
  /// );
  ///
  /// // Expected paths:
  /// // ["action/layouts/normal/layouts/value", "action/layouts/hard/layouts/value"]
  /// print(paths);
  /// ```
  /// In this example, the function extracts paths to 'value' elements within the provided XML document.
  ///
  /// The XML structure in this example includes nested 'value' elements within 'normal' and 'hard' layouts
  /// under the 'action' element. The extracted paths represent the hierarchy to these 'value' elements.
  static List<String> extractNestedElementPaths(
      xml.XmlElement parentElement, String targetElementName) {
    List<String> paths = [];
    void recurse(xml.XmlNode node, [String path = '']) {
      if (node is xml.XmlElement) {
        var newPath =
            path.isEmpty ? node.name.local : '$path/${node.name.local}';
        if (node.name.local == targetElementName) {
          paths.add(newPath);
        }
        node.children.forEach((child) => recurse(child, newPath));
      }
    }

    recurse(parentElement);
    return paths;
  }

  /// Replaces values of a specified attribute in elements with a given name.
  /// This is useful for updating XML data based on attributes.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '''
  ///   <root>
  ///     <code str="oldValue">Some Code</code>
  ///     <code str="anotherValue">More Code</code>
  ///   </root>
  /// ''';
  ///
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// XmlElementHandler.replaceAttributeValues(
  ///   xmlDoc.rootElement,
  ///   'code',
  ///   'str',
  ///   'newValue',
  /// );
  ///
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  /// In this example, the function replaces the 'str' attribute values in 'code' elements with 'newValue'
  /// within the provided XML document.
  ///
  /// Expected output after the update:
  /// ```
  /// <root>
  ///   <code str="newValue">Some Code</code>
  ///   <code str="newValue">More Code</code>
  /// </root>
  /// ```
  ///
  /// The function searches for 'code' elements within the XML and updates their 'str' attribute values to 'newValue'.
  static void replaceAttributeValues(xml.XmlElement parentElement,
      String targetElementName, String attributeName, String newValue) {
    void recurse(xml.XmlNode node) {
      if (node is xml.XmlElement && node.name.local == targetElementName) {
        node.setAttribute(attributeName, newValue);
      }
      node.children.forEach(recurse);
    }

    recurse(parentElement);
  }

  /// Creates a summary of the count of different element types within a specified depth.
  /// This is useful for analyzing the composition of an XML document.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '''
  ///   <root>
  ///     <action>Do Action</action>
  ///     <layouts>
  ///       <normal>Normal Layout</normal>
  ///       <hard>Hard Layout</hard>
  ///       <extreme>Extreme Layout</extreme>
  ///     </layouts>
  ///   </root>
  /// ''';
  ///
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// // Calculate element counts within a depth of 2
  /// final summary = XmlElementHandler.summarizeElementCounts(xmlDoc.rootElement, 2);
  ///
  /// // Expected summary:
  /// // {
  /// //   "action": 1,
  /// //   "layouts": 1,
  /// //   "normal": 1,
  /// //   "hard": 1,
  /// //   "extreme": 1
  /// // }
  /// print(summary);
  /// ```
  /// In this example, the function creates a summary of element counts within a depth of 2
  /// from the provided XML document. The resulting summary includes counts of different
  /// element types.
  ///
  /// The XML structure in this example:
  /// - 'action' appears once.
  /// - 'layouts' appears once.
  /// - Within 'layouts':
  ///   - 'normal' appears once.
  ///   - 'hard' appears once.
  ///   - 'extreme' appears once.
  static Map<String, int> summarizeElementCounts(
      xml.XmlElement parentElement, int depth) {
    Map<String, int> summary = {};
    void recurse(xml.XmlNode node, int currentDepth) {
      if (currentDepth > depth) return;
      if (node is xml.XmlElement) {
        summary[node.name.local] = (summary[node.name.local] ?? 0) + 1;
        node.children.forEach((child) => recurse(child, currentDepth + 1));
      }
    }

    recurse(parentElement, 0);
    return summary;
  }

  /// Updates the value of an element based on a matching value in a sibling element.
  /// If the sibling element's value matches the provided criteria, the target element's value is updated.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><target>Old Value</target><sibling>matchingValue</sibling></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// XmlElementHandler.updateElementValueBasedOnSiblingValue(
  ///   xmlDoc.rootElement,
  ///   'target',
  ///   'sibling',
  ///   'matchingValue',
  ///   'New Value',
  /// );
  ///
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  /// In this example, the function updates the value of the 'target' element to 'New Value'
  /// because the 'sibling' element has a value of 'matchingValue'.
  ///
  /// Output after the update:
  /// ```
  /// <root>
  ///   <target>New Value</target>
  ///   <sibling>matchingValue</sibling>
  /// </root>
  /// ```
  ///
  /// The function searches for 'target' elements within the XML and checks the value of
  /// their corresponding 'sibling' elements. If the 'sibling' element's value matches
  /// 'matchingValue', the 'target' element's value is updated to 'New Value'.
  static void updateElementValueBasedOnSiblingValue(
      xml.XmlElement parentElement,
      String targetElementName,
      String siblingElementName,
      String matchingValue,
      String newValue) {
    var elements = parentElement.findElements(targetElementName);
    for (var element in elements) {
      var siblingElement =
          element.parentElement?.findElements(siblingElementName).firstOrNull;
      if (siblingElement != null && siblingElement.innerText == matchingValue) {
        element.innerText = newValue;
      }
    }
  }

  /// Conditionally replaces or skips updating the value of elements based on a specific attribute value.
  /// If the element's attribute matches the provided value, its value is replaced; otherwise, the update is skipped.
  ///
  /// Example:
  /// ```dart
  /// final xmlString = '<root><element attribute="match">Old Value</element></root>';
  /// final xmlDoc = xml.parse(xmlString);
  ///
  /// XmlElementHandler.conditionallyReplaceOrSkipElementValue(
  ///   xmlDoc.rootElement,
  ///   'element',
  ///   'attribute',
  ///   'match',
  ///   'New Value',
  /// );
  ///
  /// print(xmlDoc.toXmlString(pretty: true));
  /// ```
  /// In this example, the function replaces the value of the 'element' element with 'New Value'
  /// because its 'attribute' matches 'match'.
  ///
  /// Output after the update:
  /// ```
  /// <root>
  ///   <element attribute="match">New Value</element>
  /// </root>
  /// ```
  ///
  /// The function searches for 'element' elements within the XML and checks their 'attribute'
  /// values. If an element's 'attribute' matches 'match', its value is updated to 'New Value'.
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

  /// Removes specified child elements from an XML structure, with an option to first climb to a specific parent element.
  ///
  /// This function facilitates targeted removal of child elements based on their names. It can optionally climb the XML tree
  /// to a parent element of a specified name before performing the removal. This is useful for manipulating XML structures
  /// where specific elements need to be removed under certain conditions or within specific parts of the tree.
  ///
  /// Parameters:
  /// - `startingElement` (xml.XmlElement): The starting element from which the removal process begins.
  ///   This is either the element where removals occur directly or the starting point to climb to a specific parent.
  /// - `elementNamesToRemove` (List<String>): A list of the names of child elements to be removed.
  /// - `climbToParentWithName` (String, optional): An optional name of a parent element to climb to before removing the specified children.
  ///   If provided, the function will climb up the XML tree from `startingElement` until it finds an element with this name, or reaches the root.
  ///
  /// Example Usage:
  /// Consider the following XML structure:
  /// ```xml
  /// <root>
  ///   <parent>
  ///     <childToRemove>...</childToRemove>
  ///     <otherChild>...</otherChild>
  ///     <childToRemove>...</childToRemove>
  ///   </parent>
  ///   <parent>
  ///     <childToRemove>...</childToRemove>
  ///   </parent>
  /// </root>
  /// ```
  /// To remove all elements named 'childToRemove' under 'parent' elements, use:
  /// ```dart
  /// XmlElementHandler.removeSpecifiedChildElements(
  ///   xmlDoc.rootElement,
  ///   ['childToRemove'],
  ///   'parent'
  /// );
  /// ```
  /// After applying the function, any 'childToRemove' elements under 'parent' elements will be removed from the XML structure.
  ///
  static void removeSpecifiedChildElements(
      xml.XmlElement startingElement, List<String> elementNamesToRemove,
      [String? climbToParentWithName]) {
    xml.XmlNode? targetNode = startingElement;

    // Optionally climb up to a specified parent element
    if (climbToParentWithName != null) {
      while (targetNode != null) {
        if (targetNode is xml.XmlElement &&
            targetNode.name.local == climbToParentWithName) {
          break;
        }
        targetNode = targetNode.parent;
      }
    }

    // Proceed only if the target is an XmlElement
    if (targetNode is xml.XmlElement) {
      // Collect elements to remove
      List<xml.XmlElement> elementsToRemove = [];

      for (var name in elementNamesToRemove) {
        var elements = targetNode.findElements(name);
        elementsToRemove.addAll(elements);
      }

      // Remove elements in a bulk operation
      elementsToRemove.forEach((element) {
        targetNode?.children.remove(element);
      });
    }
  }
}
