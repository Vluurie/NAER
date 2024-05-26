import 'package:xml/xml.dart' as xml;

/// Replaces the text content of the specified XML element with the given new text.
///
/// This function clears the existing children of the XML element and adds
/// a new text node with the specified [newText].
///
/// Parameters:
/// - [element]: The XML element whose text content is to be replaced.
/// - [newText]: The new text to set for the XML element.
void replaceTextInXmlElement(xml.XmlElement element, String newText) {
  element.children.clear();
  element.children.add(xml.XmlText(newText));
}
