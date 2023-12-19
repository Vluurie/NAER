import 'dart:convert';
import 'package:xml/xml.dart' as xml;

/// Enums defining the criteria for searching within an XML document.
///
/// - [ELEMENT_NAME]: Search for elements based on their tag name.
/// - [ATTRIBUTE_NAME]: Search for elements that contain a specific attribute name.
/// - [ATTRIBUTE_VALUE]: Search for elements that contain an attribute with a specific value.
/// - [ELEMENT_ATTRIBUTE_COMBINATION]: Search for elements based on both their tag name and an attribute condition.
/// - [ELEMENT_INNER_DATA]: Search for elements based on their inner text content.
/// - [FIND_ALL_ELEMENT_NAMES_TO_LIST]: Find all element names and return them as a list.
/// - [FIND_ALL_ELEMENT_NAMES_TO_LIST_WITH_COUNT]: Find all element names and their occurrence counts.
/// - [FIND_ALL_UNIQUE_ELEMENT_TEXT_TO_SORTED_OBJECT_WITH_COUNT]: Find all unique texts in elements and count their occurrences, sorting the result.
/// - [FIND_ALL_ATTRIBUTE_VALUES_TO_LIST]: List all values of a specific attribute.
/// - [FIND_ELEMENTS_WITH_CHILD]: Find elements that contain a specific child element.
/// - [FIND_TEXT_IN_ATTRIBUTES]: Search for and return text contained in a specific attribute.
/// - [COUNT_DISTINCT_ATTRIBUTES]: Count the number of distinct attributes in all elements with a specific name.
enum SearchCriteria {
  /// Search for elements based on their tag name. It skips empty elements and it get's returned as json format.
  ///
  /// Usage Example:
  /// ```dart
  /// var elements = searchXml(xmlDoc, SearchCriteria.ELEMENT_NAME, elementName: 'command');
  /// ```
  ///
  /// Example Output:
  /// ```json
  /// [
  ///   {
  ///     "name": "command",
  ///     "attributes": [],
  ///     "text": "Action.signal",
  ///     "children": [
  ///       {
  ///         "name": "label",
  ///         "attributes": [],
  ///         "text": "Action.signal"
  ///       }
  ///       // ... more children if present
  ///     ]
  ///   },
  ///   // ... more elements if present
  /// ]
  /// ```
  ELEMENT_NAME,

  /// Search for elements by their inner text content. For example u know a elements name and want to find any inner text content. If found, it returns them in a list.
  /// Usage Example:
  /// ```dart
  /// var elements = searchXml(xmlDoc, SearchCriteria.ELEMENT_INNER_DATA, elementName: 'example', search: 'text');
  /// // Example Output: ['text1', 'text2', ...] // The example element had as inner data text 1 and text 2.
  /// // If search: "" it searches for the element specified and gives any data from them in the list.
  /// ```
  ELEMENT_INNER_DATA,

  /// Search for elements that contain a specific attribute name.
  /// Usage Example:
  /// ```dart
  /// var elements = searchXml(xmlDoc, SearchCriteria.ATTRIBUTE_NAME, attributeName: 'attributeName');
  /// // Example Output: [XmlElement, XmlElement, ...]
  /// ```
  ATTRIBUTE_NAME,

  /// Search for elements that contain an attribute with a specific value.
  /// Usage Example:
  /// ```dart
  /// var elements = searchXml(xmlDoc, SearchCriteria.ATTRIBUTE_VALUE, attributeName: 'attributeName', attributeValue: 'value');
  /// // Example Output: [XmlElement, XmlElement, ...]
  /// ```
  ATTRIBUTE_VALUE,

  /// Search for elements based on both their tag name and an attribute condition.
  /// Usage Example:
  /// ```dart
  /// var elements = searchXml(xmlDoc, SearchCriteria.ELEMENT_ATTRIBUTE_COMBINATION, elementName: 'example', attributeName: 'attributeName', attributeValue: 'value');
  /// // Example Output: [XmlElement, XmlElement, ...]
  /// ```
  ELEMENT_ATTRIBUTE_COMBINATION,

  /// Find all element names and return them as a list.
  /// Usage Example:
  /// ```dart
  /// var elementNames = searchXml(xmlDoc, SearchCriteria.FIND_ALL_ELEMENT_NAMES_TO_LIST);
  /// // Example Output: ['element1', 'element2', ...]
  /// ```
  FIND_ALL_ELEMENT_NAMES_TO_LIST,

  /// Find all element names and their occurrence counts.
  /// Usage Example:
  /// ```dart
  /// var elementCounts = searchXml(xmlDoc, SearchCriteria.FIND_ALL_ELEMENT_NAMES_TO_LIST_WITH_COUNT);
  /// // Example Output: {'element1': 3, 'element2': 2, ...}
  /// ```
  FIND_ALL_ELEMENT_NAMES_TO_LIST_WITH_COUNT,

  /// Find all unique texts in elements and count their occurrences, sorting the result.
  /// Usage Example:
  /// ```dart
  /// var uniqueTexts = searchXml(xmlDoc, SearchCriteria.FIND_ALL_UNIQUE_ELEMENT_TEXT_TO_SORTED_OBJECT_WITH_COUNT);
  /// // Example Output: {'text1': {'count': 3}, 'text2': {'count': 2}, ...}
  /// ```
  FIND_ALL_UNIQUE_ELEMENT_TEXT_TO_SORTED_OBJECT_WITH_COUNT,

  /// List all values of a specific attribute.
  /// Usage Example:
  /// ```dart
  /// var attributeValues = searchXml(xmlDoc, SearchCriteria.FIND_ALL_ATTRIBUTE_VALUES_TO_LIST);
  /// // Example Output: ['value1', 'value2', ...]
  /// ```
  FIND_ALL_ATTRIBUTE_VALUES_TO_LIST,

  /// Find elements that contain a specific child element.
  /// Usage Example:
  /// ```dart
  /// var elementsWithChild = searchXml(xmlDoc, SearchCriteria.FIND_ELEMENTS_WITH_CHILD, elementName: 'parent', searchText: 'child');
  /// // Example Output: [XmlElement, XmlElement, ...]
  /// ```
  FIND_ELEMENTS_WITH_CHILD,

  /// Search for and return text contained in a specific attribute.
  /// Usage Example:
  /// ```dart
  /// var attributeText = searchXml(xmlDoc, SearchCriteria.FIND_TEXT_IN_ATTRIBUTES, attributeName: 'str', search: 'Enemy');
  /// // Example Output:
  ///   {
  /// "element": "code",
  ///  "attribute": "str",
  /// "value": "EnemySetAction"
  /// },
  /// ```
  FIND_TEXT_IN_ATTRIBUTES,

  /// Count the number of distinct attributes in all elements with a specific name.
  /// Usage Example:
  /// ```dart
  /// var attributeCounts = searchXml(xmlDoc, SearchCriteria.COUNT_DISTINCT_ATTRIBUTES, elementName: 'example');
  /// // Example Output: {'attribute1': 3, 'attribute2': 2, ...}
  /// ```
  COUNT_DISTINCT_ATTRIBUTES,

  /// Perform a case-insensitive search within the inner data of elements and return matched elements
  /// as a sorted JSON string. Elements are sorted based on their inner text value.
  /// Usage Example:
  /// ```dart
  /// var sortedJson = searchXml(xmlDoc, SearchCriteria.ELEMENT_INNER_DATA_TO_SORTED_OBJECT,
  ///                            elementName: 'example', search: 'searchText');
  /// // Example Output: '[{"tag": "example", "value": "First Match"}, ...]'
  /// ```
  ELEMENT_INNER_DATA_TO_SORTED_OBJECT,

  /// Perform a case-insensitive search within the inner data of elements, ensuring uniqueness,
  /// and return matched elements as a sorted JSON string. Elements are sorted based on their inner text value.
  /// Each element's inner data is ensured to be unique in the output.
  ELEMENT_UNIQUE_INNER_DATA_TO_SORTED_OBJECT,
}

/// Searches an XML document based on specified criteria and returns a list of matched elements or their inner texts.
///
/// This function allows you to search an XML document for elements or text content based on various criteria.
///
/// Parameters:
/// - [doc]: The XML document to be searched.
/// - [criteria]: The criteria for searching, defined by the [SearchCriteria] enum.
/// - [elementName]: The name of the element to search for. Relevant for [SearchCriteria.ELEMENT_NAME]
///   and [SearchCriteria.ELEMENT_INNER_DATA].
/// - [searchText]: The text content to search within elements' inner text. Relevant for [SearchCriteria.ELEMENT_INNER_DATA] and [SearchCriteria.FIND_ELEMENTS_WITH_CHILD].
/// - [attributeName]: The name of the attribute to search for. Relevant for [SearchCriteria.ATTRIBUTE_NAME]
///   and [SearchCriteria.ELEMENT_ATTRIBUTE_COMBINATION].
/// - [attributeValue]: The value of the attribute to search for. Relevant for [SearchCriteria.ATTRIBUTE_VALUE]
///   and [SearchCriteria.ELEMENT_ATTRIBUTE_COMBINATION].
///
/// Returns:
/// - A list of matched elements or their inner texts based on the search criteria. If no matches are found,
///   an empty list or map is returned.
///
/// Example:
/// ```dart
/// var xmlHandler = XmlHandler();
/// var xmlDoc = xml.XmlDocument.parse('<root><item>Example</item></root>');
///
/// // Search for elements by name
/// var elementsByName = xmlHandler.searchXml_(xmlDoc, SearchCriteria.ELEMENT_NAME, elementName: 'item');
/// // Expected output: List of XmlElement objects representing <item> elements.
///
/// // Search for elements by inner text content
/// var elementsByInnerText = xmlHandler.searchXml_(xmlDoc, SearchCriteria.ELEMENT_INNER_DATA, elementName: 'item', searchText: 'Example');
/// // Expected output: ['Example']
/// ```
///
/// Note:
/// - When searching for elements by name or attribute, the function returns a list of matched XML elements.
/// - When searching for elements by inner text content, the function returns a list of strings containing the inner text of matched elements.
/// - If no matches are found or if an error occurs during the search, an empty list or map is returned.
/// - The function can be customized to search for specific elements or attributes within the XML document.
///
/// See Also:
/// - [SearchCriteria] enum for available search criteria options.
dynamic searchXml(
  xml.XmlDocument doc,
  SearchCriteria criteria, {
  String? elementName,
  String? search,
  String? attributeName,
  String? attributeValue,
  String? filePath,
}) {
  try {
    List<dynamic> result = [];
    Iterable<xml.XmlElement> elements;
    switch (criteria) {
      case SearchCriteria.ELEMENT_INNER_DATA:
        if (search == null) {
          return [];
        }
        search = search.toLowerCase();
        List<String> matchedTexts = [];
        elements = doc.findAllElements(elementName ?? '');

        for (var element in elements) {
          for (var child in element.children.whereType<xml.XmlNode>()) {
            if (child is xml.XmlText &&
                child.value.toLowerCase().contains(search)) {
              matchedTexts.add(child.value.trim());
              break;
            }
          }
        }
        return matchedTexts;

      case SearchCriteria.ELEMENT_INNER_DATA_TO_SORTED_OBJECT:
        if (search == null) {
          return jsonEncode(
              {'operation': 'Search and Sort XML Elements', 'result': []});
        }

        search = search.toLowerCase();
        var operationSummary = {
          'filePath': filePath,
          'searchCriteria': search,
          'elementName': elementName ?? 'Any',
          'Found': [],
        };

        var matchedElements = <Map<String, dynamic>>[];
        var elements = doc.findAllElements(elementName ?? '');

        for (var element in elements) {
          for (var child in element.children.whereType<xml.XmlNode>()) {
            if (child is xml.XmlText) {
              String childValueTrimmed = child.value.trim();
              if (childValueTrimmed.toLowerCase().contains(search)) {
                matchedElements.add({
                  'tag': element.name.toString(),
                  'value': childValueTrimmed
                });
              }
            }
          }
        }

        matchedElements
            .sort((a, b) => (a['value']?.compareTo(b['value'] ?? '') ?? 0));

        operationSummary['Found'] = matchedElements;

        // Check if the matchedElements list is empty
        if (matchedElements.isEmpty) {
          return;
        }

        String jsonPrettified =
            JsonEncoder.withIndent('  ').convert(operationSummary);
        return jsonPrettified;

      case SearchCriteria.FIND_ALL_ELEMENT_NAMES_TO_LIST:
        Set<String> allElementNames = Set<String>();
        elements = doc.findAllElements(elementName ?? '*');

        for (var element in elements) {
          allElementNames.add(element.name.local);
        }
        return allElementNames.toList();

      case SearchCriteria.ELEMENT_UNIQUE_INNER_DATA_TO_SORTED_OBJECT:
        if (search == null) {
          return jsonEncode(
              {'operation': 'Search and Sort XML Elements', 'result': []});
        }

        search = search.toLowerCase();
        var operationSummary = {
          'filePath': filePath,
          'searchCriteria': search,
          'elementName': elementName ?? 'Any',
          'Found': [],
        };

        var uniqueElements = <String, Map<String, dynamic>>{};
        var elements = doc.findAllElements(elementName ?? '');

        for (var element in elements) {
          for (var child in element.children.whereType<xml.XmlNode>()) {
            if (child is xml.XmlText) {
              String childValueTrimmed = child.value.trim();
              if (childValueTrimmed.toLowerCase().contains(search)) {
                uniqueElements[childValueTrimmed.toLowerCase()] = {
                  'tag': element.name.toString(),
                  'value': childValueTrimmed
                };
              }
            }
          }
        }

        var sortedMatchedElements = uniqueElements.values.toList()
          ..sort((a, b) => (a['value']?.compareTo(b['value'] ?? '') ?? 0));

        operationSummary['Found'] = sortedMatchedElements;

        // Check if the sortedMatchedElements list is empty
        if (sortedMatchedElements.isEmpty) {
          return;
        }

        String jsonPrettified =
            JsonEncoder.withIndent('  ').convert(operationSummary);
        return jsonPrettified;

      case SearchCriteria
            .FIND_ALL_UNIQUE_ELEMENT_TEXT_TO_SORTED_OBJECT_WITH_COUNT:
        Map<String, Map<String, int>> elementTextCounts = {};
        var elements = doc.descendants.whereType<xml.XmlElement>();

        for (var element in elements) {
          for (var node in element.nodes) {
            if (node is xml.XmlText) {
              var text = node.value.trim();

              text = text.replaceAll('\n', '').replaceAll('\t', '');

              if (text.isNotEmpty) {
                var sanitizedText = text.trim();

                var key = "'$sanitizedText'";
                elementTextCounts[key] ??= {'count': 0};
                elementTextCounts[key]!['count'] =
                    (elementTextCounts[key]!['count'] ?? 0) + 1;
              }
            }
          }
        }

        var sortedEntries = elementTextCounts.entries.toList()
          ..sort((a, b) {
            var aNum = double.tryParse(a.key);
            var bNum = double.tryParse(b.key);

            if (aNum != null && bNum != null) {
              return aNum.compareTo(bNum);
            } else if (aNum != null) {
              return -1;
            } else if (bNum != null) {
              return 1;
            } else {
              return a.key.compareTo(b.key);
            }
          });

        var structuredJson = {
          for (var entry in sortedEntries)
            entry.key: {'count': entry.value['count'] ?? 0}
        };

        var encoder = JsonEncoder.withIndent('  ');
        var jsonOutput = encoder.convert(structuredJson);

        return jsonOutput;

      case SearchCriteria.FIND_ALL_ATTRIBUTE_VALUES_TO_LIST:
        List<String> allAttributeValues = [];
        elements = doc.descendants.whereType<xml.XmlElement>();

        for (var element in elements) {
          var attributes = element.attributes;
          for (var attribute in attributes) {
            allAttributeValues.add(attribute.value);
          }
        }
        return allAttributeValues;
      case SearchCriteria.ELEMENT_NAME:
        var elementsList = doc.findAllElements(elementName ?? '').toList();

        // Sort elements by their name
        elementsList.sort((a, b) => a.name.local.compareTo(b.name.local));

        var result = elementsList.map((element) {
          var childElementsList =
              element.children.whereType<xml.XmlElement>().toList();

          // Sort child elements by their name
          childElementsList
              .sort((a, b) => a.name.local.compareTo(b.name.local));

          Map<String, dynamic> elementMap = {'name': element.name.local};

          // Add attributes if any
          if (element.attributes.isNotEmpty) {
            elementMap['attributes'] = element.attributes
                .map((attr) => {'name': attr.name.local, 'value': attr.value})
                .toList();
          }

          // Add text if not empty
          String cleanedText = cleanText(element.innerText);
          if (cleanedText.isNotEmpty) {
            elementMap['text'] = cleanedText;
          }

          // Process children if any
          if (childElementsList.isNotEmpty) {
            elementMap['children'] = childElementsList.map((child) {
              Map<String, dynamic> childMap = {'name': child.name.local};

              // Add child attributes if any
              if (child.attributes.isNotEmpty) {
                childMap['attributes'] = child.attributes
                    .map((attr) =>
                        {'name': attr.name.local, 'value': attr.value})
                    .toList();
              }

              // Add child text if not empty
              String childCleanedText = cleanText(child.innerText);
              if (childCleanedText.isNotEmpty) {
                childMap['text'] = childCleanedText;
              }

              return childMap;
            }).toList();
          }

          return elementMap;
        }).toList();

        // Convert the result to a pretty-printed JSON string
        String jsonResult = JsonEncoder.withIndent('  ').convert(result);
        return jsonResult;

      case SearchCriteria.ATTRIBUTE_NAME:
        elements = doc.descendants.whereType<xml.XmlElement>().where(
            (element) => element.attributes
                .any((attr) => attr.name.local == attributeName));
        break;

      case SearchCriteria.ATTRIBUTE_VALUE:
        elements = doc.descendants.whereType<xml.XmlElement>().where(
            (element) =>
                element.attributes.any((attr) => attr.value == attributeValue));
        break;

      case SearchCriteria.ELEMENT_ATTRIBUTE_COMBINATION:
        elements = doc.findAllElements(elementName ?? '').where((element) =>
            element.getAttribute(attributeName ?? '') == attributeValue);
        break;

      case SearchCriteria.FIND_ELEMENTS_WITH_CHILD:
        // New case: Find Elements with Specific Child Elements
        if (elementName == null || search == null) {
          return []; // or throw an exception
        }
        elements = doc
            .findAllElements(elementName)
            .where((element) => element.findElements(search!).isNotEmpty);
        break;

      case SearchCriteria.FIND_TEXT_IN_ATTRIBUTES:
        // New case: Find Text in Specific Attributes
        if (attributeName == null) {
          return JsonEncoder.withIndent('  ')
              .convert([]); // or throw an exception
        }

        var matchingAttributes = doc.descendants
            .whereType<xml.XmlElement>()
            .map((e) {
              var attrValue = e.getAttribute(attributeName);
              if (attrValue != null && attrValue.contains(search ?? '')) {
                return {
                  'element': e.name.local,
                  'attribute': attributeName,
                  'value': attrValue
                };
              }
              return null;
            })
            .where((item) => item != null)
            .toList();

        return JsonEncoder.withIndent('  ').convert(matchingAttributes);

      case SearchCriteria.COUNT_DISTINCT_ATTRIBUTES:
        // New case: Count Distinct Attributes
        var attributeCounts = Map<String, int>();

        void countAttributes(xml.XmlElement element) {
          for (var attr in element.attributes) {
            attributeCounts[attr.name.local] =
                (attributeCounts[attr.name.local] ?? 0) + 1;
          }
          for (var childElement
              in element.children.whereType<xml.XmlElement>()) {
            countAttributes(childElement);
          }
        }

        Iterable<xml.XmlElement> elements;
        if (elementName == null || elementName.isEmpty) {
          // Count attributes for all elements if no specific element name is provided
          elements = doc.descendants.whereType<xml.XmlElement>();
        } else {
          // Otherwise, find elements by the specified name
          elements = doc.findAllElements(elementName);
        }

        elements.forEach(countAttributes);
        return attributeCounts;

      default:
        break;
    }

    return result;
  } catch (e) {
    print('Error in searchXml: $e');
    return [];
  }
}

String cleanText(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}
