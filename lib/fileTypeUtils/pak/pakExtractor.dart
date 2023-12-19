import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

import '../yax/yaxToXml.dart';
import '../utils/ByteDataWrapper.dart';

/*
struct HeaderEntry
{
	uint32 type;
	uint32 uncompressedSizeMaybe;
	uint32 offset;
};
 */
class _HeaderEntry {
  late int type;
  late int uncompressedSize;
  late int offset;

  _HeaderEntry(ByteDataWrapper bytes) {
    type = bytes.readUint32();
    uncompressedSize = bytes.readUint32();
    offset = bytes.readUint32();
  }
}

Future<int> guessType(String yaxPath, String xmlPath) async {
  var fileSize = await File(yaxPath).length();
  int value = (fileSize <= 1024) ? 1 : 4;

  if (path.basename(yaxPath) != "0.yax") {
    var xmlFile = File(xmlPath);
    var xmlContent = await xmlFile.readAsString();
    var document = XmlDocument.parse(xmlContent);

    if (document.findAllElements("node").isNotEmpty ||
        document.findAllElements("text").isNotEmpty) {
      value += 1;
    } else {
      value += 2;
    }
  }
  return value;
}

Future<void> _extractPakYax(_HeaderEntry meta, int size, ByteDataWrapper bytes,
    String extractDir, int index) async {
  bytes.position = meta.offset;
  bool isCompressed = meta.uncompressedSize > size;
  int readSize;
  if (isCompressed) {
    int compressedSize = bytes.readUint32();
    readSize = compressedSize;
  } else {
    int paddingEndLength = (4 - (meta.uncompressedSize % 4)) % 4;
    readSize = size - paddingEndLength;
  }

  var extractedFile = File(path.join(extractDir, "$index.yax"));
  var fileBytes = bytes.readUint8List(readSize);
  if (isCompressed) fileBytes = zlib.decode(fileBytes);
  await extractedFile.writeAsBytes(fileBytes);
}

Future<List<String>> extractPakFiles(String pakPath, String extractDir,
    {bool yaxToXml = true}) async {
  var bytes = await ByteDataWrapper.fromFile(pakPath);

  bytes.position = 8;
  var firstOffset = bytes.readUint32();
  var fileCount = (firstOffset - 4) ~/ 12;

  bytes.position = 0;
  var headerEntries =
      List<_HeaderEntry>.generate(fileCount, (index) => _HeaderEntry(bytes));

  // calculate file sizes from offsets
  List<int> fileSizes = List<int>.generate(
      fileCount,
      (index) => index == fileCount - 1
          ? bytes.length - headerEntries[index].offset
          : headerEntries[index + 1].offset - headerEntries[index].offset);

  await Directory(extractDir).create(recursive: true);
  for (int i = 0; i < fileCount; i++) {
    await _extractPakYax(headerEntries[i], fileSizes[i], bytes, extractDir, i);
  }

  dynamic meta = {
    "files": List.generate(
        fileCount,
        (index) => {
              "name": "$index.yax",
              "type": headerEntries[index].type,
            })
  };

  if (yaxToXml) {
    for (int i = 0; i < fileCount; i++) {
      var yaxPath = path.join(extractDir, "$i.yax");
      var xmlPath = path.setExtension(yaxPath, ".xml");
      await yaxFileToXmlFile(yaxPath, xmlPath);
      int newType = await guessType(yaxPath, xmlPath);
      meta["files"][i]["type"] = newType; // Update the type
    }
  }
  var pakInfoPath = path.join(extractDir, "pakInfo.json");
  await File(pakInfoPath)
      .writeAsString(JsonEncoder.withIndent("\t").convert(meta));

  var extractedFiles = List<String>.generate(
      fileCount, (index) => path.join(extractDir, "$index.yax"));
  // print("Extracted ${extractedFiles.length} files.");
  return extractedFiles;
}
