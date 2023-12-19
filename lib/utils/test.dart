import 'package:NAER/XmlElementHandler/XmlHandler.dart';

void main() async {
  var xmlHandler = await XmlHandler.fromFile(
      'C:/Users/dmedu/Desktop/testflutter/NAER/lib/utils/28.xml');

  // Existing search functionality

  // Modification functionality
  var modifyResult = xmlHandler.modifyXml_(
      ModifyXmlCriteria.ADD_ELEMENT_CONDITIONAL_ON_CHILD, // Updated criteria
      elementName: 'body', // The parent element name
      modifyTo: '99' // The child element name to check for
      );
  print(modifyResult);
  var searchResult = xmlHandler.searchXml_(SearchCriteria.ELEMENT_INNER_DATA,
      elementName: 'body', search: '');
  print(searchResult);
}
