import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../../utils.dart';
import '../utils/ByteDataWrapper.dart';

const ZLibEncoder _zLibEncoder = ZLibEncoder();

class _FileEntry {
  int type;
  int uncompressedSize;
  int offset;

  int pakSize;
  List<int> data;
  List<int> compressedData;
  int compressedSize;

  _FileEntry(this.offset, this.type)
      : uncompressedSize = 0,
        pakSize = 0,
        data = [],
        compressedData = [],
        compressedSize = -1;

  Future<void> init(File file) async {
    uncompressedSize = await file.length();
    data = await file.readAsBytes();
    var paddingEndLength = (4 - (uncompressedSize % 4)) % 4;
    pakSize = data.length + paddingEndLength;

    if (uncompressedSize > 1024) {
      compressedData = _zLibEncoder.encode(data, level: 1);
      paddingEndLength = (4 - (compressedData.length % 4)) % 4;
      compressedSize = compressedData.length;
      pakSize = 4 + compressedSize + paddingEndLength;
    } else {
      compressedData = Uint8List(0);
      compressedSize = -1;
    }
  }

  void writeHeaderEntry(ByteDataWrapper bytes) {
    bytes.writeUint32(type);
    bytes.writeUint32(uncompressedSize);
    bytes.writeUint32(offset);
  }

  void writeFileEntryToFile(ByteDataWrapper bytes) {
    if (compressedData.isNotEmpty) {
      bytes.writeUint32(compressedSize);
      bytes.writeBytes(compressedData);
      var paddingEndLength = (4 - (compressedSize % 4)) % 4;
      bytes.writeBytes(Uint8List(paddingEndLength));
    } else {
      bytes.writeBytes(data);
      var paddingEndLength = (4 - (uncompressedSize % 4)) % 4;
      bytes.writeBytes(Uint8List(paddingEndLength));
    }
  }

  int get headerSize => 12;

  int get fileSize {
    if (compressedData.isNotEmpty) {
      return 4 + compressedData.length + (4 - (compressedData.length % 4)) % 4;
    } else {
      return data.length + (4 - (data.length % 4)) % 4;
    }
  }
}

Future<void> repackPak(String pakDir, String? pakFilePath) async {
  var infoJsonFile = File(path.join(pakDir, "pakInfo.json"));
  var pakInfo = jsonDecode(await infoJsonFile.readAsString());

  var filesOffset = (pakInfo["files"] as List).length * 12 + 0x4;
  var lastFileOffset = filesOffset;
  var fileEntries = <_FileEntry>[];
  for (var yaxFile in pakInfo["files"]) {
    var yaxF = File(path.join(pakDir, yaxFile["name"]));
    var fileEntry = _FileEntry(lastFileOffset, yaxFile["type"]);
    await fileEntry.init(yaxF);
    fileEntries.add(fileEntry);

    lastFileOffset += fileEntry.pakSize;
  }

  var bytes = ByteDataWrapper.allocate(lastFileOffset);
  for (var fileEntry in fileEntries) fileEntry.writeHeaderEntry(bytes);

  bytes.writeUint32(0);
  for (var fileEntry in fileEntries) fileEntry.writeFileEntryToFile(bytes);

  var pakFileName = path.basename(pakDir);
  pakFilePath ??= path.join(path.dirname(path.dirname(pakDir)), pakFileName);
  await backupFile(pakFilePath);
  var pakFile = File(pakFilePath);
  await pakFile.writeAsBytes(bytes.buffer.asUint8List());

  //print("Repacked ${pakInfo["files"].length}.");
}
