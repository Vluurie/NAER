import 'dart:convert';
import 'dart:io';
import 'package:NAER/XmlElementHandler/utils/searchXml.dart';
import 'package:NAER/XmlElementHandler/utils/modifyXml.dart';
import 'package:xml/xml.dart' as xml;
export 'utils/searchXml.dart';
export 'utils/modifyXml.dart';

typedef XmlProcessingFunction = void Function(
    XmlHandler xmlHandler, String filePath);

/// Enums defining the various operations that can be performed on an XML document.
///
/// - [SEARCH]: Perform a search within the XML document.
/// - [MODIFY]: Modify elements or attributes in the XML document.
/// - [DELETE]: Delete specific elements or attributes from the XML document.
/// - [TRANSFORM]: Apply transformations to the structure or data within the XML document.
/// - [ADD]: Add new elements or attributes to the XML document.
enum XmlOperation { SEARCH, MODIFY, DELETE, TRANSFORM, ADD }

/// Enums identifying the types of parameters that can be interacted with in an XML document.
///
/// - [ELEMENT]: Refers to XML elements.
/// - [ATTRIBUTE]: Refers to attributes within XML elements.
/// - [TEXT]: Refers to the text content within XML elements.
enum XmlParameter { ELEMENT, ATTRIBUTE, TEXT }

/// Enums representing the types of transformations that can be applied to the XML document.
///
/// - [STRUCTURE_CHANGE]: Transform the structure of the XML document, such as rearranging elements.
/// - [DATA_AGGREGATION]: Aggregate or summarize data within the XML document, such as calculating sums or averages.
enum TransformationType { STRUCTURE_CHANGE, DATA_AGGREGATION }

/// Enums describing the possible output formats for the XML processing results.
///
/// - [DART_OBJECT]: Output the result as a Dart object.
/// - [XML_STRING]: Output the result as a string in XML format.
/// - [JSON]: Output the result in JSON format.
/// - [PLAIN_TEXT]: Output the result as plain text.
/// - [PRINT]: Print the result directly to the console.
enum OutputFormat { DART_OBJECT, XML_STRING, JSON, PLAIN_TEXT, PRINT }

/// `Created by Vluurie.`
///
/// `XmlHandler`: A utility class for handling XML data in Dart.
///
/// The `XmlHandler` class provides comprehensive functionality for manipulating,
/// querying, and transforming XML documents. It offers a user-friendly interface
/// for common XML operations, such as searching for elements, modifying content,
/// and extracting data. Users can work with XML data from various sources, including
/// files and strings.
///
/// **Setup:**
/// To use `XmlHandler`, you need to have an XML document as input. This document
/// can be obtained by reading an XML file or directly using a string containing
/// XML data. The XML data must then be parsed into an `XmlDocument` object provided
/// by the `xml` package.
///
/// **Example Setup:**
/// ```dart
///
/// void main() async {
///   // Initialize XmlHandler with the path to the XML file
///   var xmlHandler = await XmlHandler.fromFile('path/to/your/xmlfile.xml');
///
///   // Use XmlHandler for various operations
///   var elements = xmlHandler.searchXml(
///     SearchCriteria.ELEMENT_NAME,
///     elementName: 'book',
///   );
///   print(elements);
/// }
/// ```
/// This example demonstrates how to initialize `XmlHandler` with an XML file and
/// use it to perform operations on it.
///
/// **Note:**
/// - Ensure that the `xml` Dart package is included in your project dependencies
///   to parse XML strings into `XmlDocument`.
/// - The `XmlHandler` class automatically reads and parses the XML file during its
///   initialization.
///
/// **Usage:**
/// - Create an instance of `XmlHandler` using one of the provided factory methods.
/// - Call its methods with the appropriate `SearchCriteria` and other parameters
///   based on your requirements.
///
/// The class assumes a basic understanding of XML structures and Dart programming.
class XmlHandler {
  late xml.XmlDocument _document;
  final String _filePath;

  XmlHandler._internal(this._document, this._filePath);

  /// Parses XML from a string and initializes an `XmlHandler` instance.
  ///
  /// The [xmlString] parameter should contain the XML data as a string.
  ///
  /// Throws [XmlParseException] if the XML parsing fails with a detailed error message.
  factory XmlHandler.fromString(String xmlString, String path) {
    try {
      final xmlDoc = xml.XmlDocument.parse(xmlString);
      return XmlHandler._internal(xmlDoc, path);
    } catch (e) {
      throw XmlParseException(
        'Failed to parse XML from string:\n$e',
        'Ensure that the provided XML data is valid and correctly formatted.\n'
            'Check for missing or mismatched tags, attributes, or invalid characters.\n',
      );
    }
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
  /// Example:
  ///
  /// Find all unique texts in elements and count their occurrences, sorting the result.
  /// ```dart
  /// var xmlHandler = await XmlHandler.fromFile('F:/allXmlFiles');
  ///
  /// var result = xmlHandler.searchXml_(SearchCriteria.FIND_ALL_UNIQUE_ELEMENT_TEXT_TO_SORTED_OBJECT_WITH_COUNT);
  ///
  /// print(result);
  ///
  /// //This 2 Lines make the Job of finding in the File all Unique Elements text, sorting them to a object and counting how often they appeared per file.
  /// ```
  /// Note:
  /// - When searching for elements by name or attribute, the function returns a list of matched XML elements.
  /// - When searching for elements by inner text content, the function returns a list of strings containing the inner text of matched elements.
  /// - If no matches are found or if an error occurs during the search, an empty list or map is returned.
  /// - The function can be customized to search for specific elements or attributes within the XML document.
  ///
  /// See Also:
  /// - [SearchCriteria] enum for available search criteria options.
  dynamic searchXml_(SearchCriteria criteria,
      {String? elementName,
      String? search,
      String? attributeName,
      String? attributeValue}) {
    return searchXml(_document, criteria,
        elementName: elementName,
        search: search,
        attributeName: attributeName,
        attributeValue: attributeValue);
  }

  dynamic modifyXml_(
    ModifyXmlCriteria criteria, {
    String? elementName,
    String? modifyTo,
    String? attributeName,
    String? attributeValue,
  }) {
    return modifyXml(_document, criteria,
        elementName: elementName,
        modifyTo: modifyTo,
        attributeName: attributeName,
        attributeValue: attributeValue,
        filePath: _filePath);
  }

  /// Parses XML from a file and initializes an `XmlHandler` instance.
  ///
  /// The [filePath] parameter should be the path to the XML file to be read.
  ///
  /// Throws [FileReadException] if file reading fails with a detailed error message.
  /// Throws [XmlParseException] if XML parsing fails with a detailed error message.
  static Future<XmlHandler> fromFile(String filePath) async {
    try {
      final file = File(filePath);
      final xmlString = await file.readAsString();
      return XmlHandler.fromString(
          xmlString, filePath); // Correctly call the factory
    } catch (e) {
      throw FileReadException(
        'Failed to read XML file:\n$e',
        'Ensure that the file exists and the path is correct.\n'
            'Check file permissions and availability.\n'
            'If you want to use all Folders and their subfolders for XML files, try the "processAllXmlFilesInDirectory" method.\n'
            'For only one Folder, use the "processXmlFilesInDirectory" method.\n',
      );
    }
  }

  /// Processes all XML files in a specified directory and its subdirectories.
  ///
  /// This method recursively searches through the given directory and all of its subdirectories
  /// to find XML files. Each XML file found is processed by invoking the provided callback function.
  ///
  /// The [directoryPath] parameter should be the path to the directory where the search will begin.
  ///
  /// The [processFunction] is a callback function that gets called for each XML file processed.
  /// This function should take an `XmlHandler` instance as its parameter, allowing custom processing
  /// on each XML file. The `XmlHandler` instance provides access to the parsed XML document.
  ///
  /// Example usage in a main function:
  /// ```dart
  ///
  /// void main() async {
  ///   // Process each XML file found in the directory and its subdirectories
  ///   await XmlHandler.processAllXmlFilesInDirectory('F:/allextracted', processXmlFile);
  /// }
  ///
  /// // Define the callback function to process each XML file
  /// void processXmlFile(XmlHandler xmlHandler) {
  ///   var result = xmlHandler.searchXmlWrapper(
  ///     SearchCriteria.ELEMENT_NAME, // Example criteria
  ///     elementName: 'book',
  ///     // Other optional parameters as needed
  ///   );
  ///
  ///   // Handle or print the result for each XML file
  ///   print(result);
  /// }
  /// ```
  ///
  /// [directoryPath]: The starting directory for the recursive search.
  /// [processFunction]: The callback function to process each XML file.
  static Future<void> processAllXmlFilesInDirectory(
      String directoryPath, void Function(XmlHandler) processFunction) async {
    var directory = Directory(directoryPath);
    await for (var entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.xml')) {
        try {
          var xmlHandler = await fromFile(entity.path);
          processFunction(xmlHandler); // Only passing XmlHandler
        } catch (e) {
          print('Error processing ${entity.path}: $e');
        }
      }
    }
  }

  /// Processes all XML files in a specified directory, but not in its subdirectories.
  ///
  /// This method searches through the given directory (excluding subdirectories)
  /// to find XML files. Each XML file found is processed by invoking the provided callback function.
  ///
  /// The [directoryPath] parameter should be the path to the directory where the search will be conducted.
  ///
  /// The [processFunction] is a callback function that gets called for each XML file processed.
  /// This function should take an `XmlHandler` instance as its parameter, allowing custom processing
  /// on each XML file. The `XmlHandler` instance provides access to the parsed XML document.
  ///
  /// Example usage in a main function:
  /// ```dart
  ///
  /// void main() async {
  ///   // Process XML files found in the specified directory (excluding subdirectories)
  ///   await XmlHandler.processXmlFilesInDirectory('path/to/directory', processXmlFile);
  /// }
  ///
  /// // Define the callback function to process each XML file
  /// void processXmlFile(XmlHandler xmlHandler) {
  ///   var result = xmlHandler.searchXmlWrapper(
  ///     SearchCriteria.ELEMENT_NAME, // Example criteria
  ///     elementName: 'book',
  ///     // Other optional parameters as needed
  ///   );
  ///
  ///   // Handle or print the result for each XML file
  ///   print(result);
  /// }
  /// ```
  ///
  /// [directoryPath]: The directory where the search for XML files will be conducted.
  /// [processFunction]: The callback function to process each XML file.
  static Future<void> processXmlFilesInDirectory(
      String directoryPath, XmlProcessingFunction processFunction) async {
    var directory = Directory(directoryPath);
    await for (var entity in directory.list(recursive: false)) {
      // Set recursive to false
      if (entity is File && entity.path.endsWith('.xml')) {
        try {
          var xmlHandler = await fromFile(entity.path);
          processFunction(xmlHandler, entity.path);
        } catch (e) {
          print('Error processing ${entity.path}: $e');
        }
      }
    }
  }

  /// Initializes an `XmlHandler` instance using an existing `xml.XmlDocument`.
  ///
  /// The [document] parameter should be an already parsed `xml.XmlDocument`
  /// that you want to work with.
  factory XmlHandler.fromXmlDocument(xml.XmlDocument document, String path) {
    return XmlHandler._internal(document, path);
  }

  /// Gets the parsed XML document associated with this `XmlHandler` instance.
  xml.XmlDocument get document => _document;
}

/// Exception thrown when there's an issue with parsing XML data.
class XmlParseException implements Exception {
  final String message;
  final String? suggestion;

  XmlParseException(this.message, [this.suggestion]);

  @override
  String toString() {
    var errorMessage = 'XmlParseException:\n$message\n';
    if (suggestion != null) {
      errorMessage += 'Suggestion:\n$suggestion\n';
    }
    return errorMessage;
  }
}

/// Exception thrown when there's an issue with reading an XML file.
class FileReadException implements Exception {
  final String message;
  final String? suggestion;

  FileReadException(this.message, [this.suggestion]);

  @override
  String toString() {
    var errorMessage = 'FileReadException:\n$message\n';
    if (suggestion != null) {
      errorMessage += 'Suggestion:\n$suggestion\n';
    }
    return errorMessage;
  }
}

/// Outputs the XML document in various formats.
///
/// This function utilizes the [OutputFormat] enum to determine the desired output format of the XML data.
/// It supports outputting the data as a Dart object, XML string, JSON, plain text, or directly printing it.
///
/// Parameters:
/// - [doc]: The XML document to be outputted.
/// - [format]: The desired output format, defined by [OutputFormat].
///
/// Returns:
/// The XML data in the specified format. Returns `null` if the format is [OutputFormat.PRINT].
///
/// Example:
/// ```
/// var jsonString = handler.outputXml(doc, OutputFormat.JSON);
/// ```
dynamic outputXml(xml.XmlDocument doc, OutputFormat format) {
  switch (format) {
    case OutputFormat.DART_OBJECT:
      return doc;
    case OutputFormat.XML_STRING:
      return doc.toXmlString(pretty: true);
    case OutputFormat.JSON:
      return json.encode(_xmlToJson(doc.rootElement));
    case OutputFormat.PLAIN_TEXT:
      return _convertXmlToPlainText(doc);
    case OutputFormat.PRINT:
      print(doc.toXmlString(pretty: true));
      return null;
  }
}

// Helper function for XML to JSON conversion
Map<String, dynamic> _xmlToJson(xml.XmlNode node) {
  var map = <String, dynamic>{};
  if (node is xml.XmlElement) {
    node.attributes
        .forEach((attribute) => map[attribute.name.local] = attribute.value);
    node.children.forEach((child) {
      var childMap = _xmlToJson(child);
      if (childMap.isNotEmpty) {
        map[child is xml.XmlElement ? child.name.local : 'text'] = childMap;
      }
    });
  } else if (node is xml.XmlText) {
    return {'text': node.innerText};
  }
  return map;
}

// Helper function to convert XML to plain text
String _convertXmlToPlainText(xml.XmlNode node) {
  if (node is xml.XmlElement) {
    return node.children.map(_convertXmlToPlainText).join('\n');
  } else if (node is xml.XmlText) {
    return node.innerText;
  } else {
    return '';
  }
}

/// Deletes elements or attributes from an XML document.
///
/// Utilizes the [XmlParameter] enum to specify whether to delete an element or an attribute.
/// This function can target specific elements or attributes for deletion based on their names or values.
///
/// Parameters:
/// - [doc]: The XML document from which elements or attributes will be deleted.
/// - [type]: Specifies what to delete, defined by [XmlParameter].
/// - [target]: The name of the element or attribute to be deleted.
/// - [attributeName]: The name of the attribute to delete. Relevant when [type] is [XmlParameter.ATTRIBUTE].
/// - [attributeValue]: The value of the attribute to delete. Relevant when [type] is [XmlParameter.ATTRIBUTE].
///
/// Example:
/// ```
/// handler.deleteXml(doc, XmlParameter.ELEMENT, 'obsoleteElement');
/// ```
void deleteXml(xml.XmlDocument doc, XmlParameter type, String target,
    {String? attributeName, String? attributeValue}) {
  try {
    Iterable<xml.XmlElement> elements;
    switch (type) {
      case XmlParameter.ELEMENT:
        elements = doc.findAllElements(target);
        break;
      case XmlParameter.ATTRIBUTE:
        elements = doc.descendants.whereType<xml.XmlElement>().where(
            (element) => element.attributes.any((attr) =>
                attr.name.local == target && attr.value == attributeValue));
        break;
      default:
        return;
    }
    for (var element in elements) {
      if (type == XmlParameter.ELEMENT) {
        element.parent?.children.remove(element);
      } else if (type == XmlParameter.ATTRIBUTE) {
        element.removeAttribute(target);
      }
    }
  } catch (e) {
    print('Error in deleteXml: $e');
  }
}

// New function to get attribute value
String? getAttributeValue(xml.XmlElement element, String attributeName) {
  return element.getAttribute(attributeName);
}

// New function to convert XML to JSON
String convertToJSON(xml.XmlDocument doc) {
  return json.encode(_xmlToJson(doc.rootElement));
}

// New function to validate XML structure
bool validateXML(xml.XmlDocument doc, xml.XmlDocument schema) {
  // Implementation depends on the specific schema or rules to validate against
  // This is a placeholder for now
  return true;
}

int countElements(xml.XmlDocument doc, String elementName) {
  try {
    return doc.findAllElements(elementName).length;
  } catch (e) {
    print('Error in countElements: $e');
    return 0;
  }
}

// New utility method to find parent element
xml.XmlElement? findParentElement(xml.XmlElement element, String parentName) {
  try {
    var parent = element.parent;
    while (parent != null && parent is! xml.XmlDocument) {
      if (parent is xml.XmlElement && parent.name.local == parentName) {
        return parent;
      }
      parent = parent.parent;
    }
    return null;
  } catch (e) {
    print('Error in findParentElement: $e');
    return null;
  }
}

// New utility method to replace an element
bool replaceElement(xml.XmlElement oldElement, xml.XmlElement newElement) {
  try {
    var parent = oldElement.parent;
    if (parent != null) {
      var index = parent.children.indexOf(oldElement);
      if (index != -1) {
        parent.children[index] = newElement;
        return true;
      }
    }
    return false;
  } catch (e) {
    print('Error in replaceElement: $e');
    return false;
  }
}
