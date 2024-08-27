import 'package:xml/xml.dart';

extension XmlExtension on XmlNode {
  /// Converts the XML node to a pretty-printed string with [Shift-JIS Japanese] indentation.
  ///
  /// This method converts the XML node to a string with pretty formatting, using
  /// tab characters for indentation. It also changes spaces to Shift-JIS Japanese
  /// spaces (1 byte) to avoid game crashes, as normal spaces (2 bytes) are not used
  /// in the script engine.
  ///
  /// Returns:
  /// A pretty-printed string representation of the XML node.
  String toPrettyString({final int? level}) {
    return "${toXmlString(pretty: true, indent: "\t", level: level, preserveWhitespace: (final node) => node.children.whereType<XmlText>().isNotEmpty)}\n";
  }
}
