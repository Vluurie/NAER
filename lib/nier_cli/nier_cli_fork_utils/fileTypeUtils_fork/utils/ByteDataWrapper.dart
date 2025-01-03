import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:euc/jis.dart';

enum StringEncoding {
  utf8,
  utf16,
  shiftJis,
}

class ByteDataWrapper {
  final ByteBuffer buffer;
  late final ByteData _data;
  Endian endian;
  final int _parentOffset;
  final int length;
  int _position = 0;

  ByteDataWrapper(
    this.buffer, {
    this.endian = Endian.little,
    final int parentOffset = 0,
    final int? length,
  })  : _parentOffset = parentOffset,
        length = length ?? buffer.lengthInBytes - parentOffset {
    _data = buffer.asByteData(0, buffer.lengthInBytes);
    _position = _parentOffset;
  }

  ByteDataWrapper.allocate(final int size, {this.endian = Endian.little})
      : buffer = ByteData(size).buffer,
        _parentOffset = 0,
        length = size,
        _position = 0 {
    _data = buffer.asByteData(0, buffer.lengthInBytes);
  }

  static Future<ByteDataWrapper> fromFile(
      final String path, final SendPort sendPort) async {
    const twoGB = 2 * 1024 * 1024 * 1024;
    var fileSize = await File(path).length();
    if (fileSize < twoGB) {
      var buffer = await File(path).readAsBytes();
      return ByteDataWrapper(buffer.buffer);
    } else {
      sendPort.send("File is over 2GB, loading in chunks");
      var buffer = Uint8List(fileSize).buffer;
      var file = File(path).openRead();
      int position = 0;
      int lastReportedProgress = -1;
      await for (var bytes in file) {
        buffer.asUint8List().setRange(position, position + bytes.length, bytes);
        position += bytes.length;
        int currentProgress = ((position / fileSize) * 100).round();
        if (currentProgress >= lastReportedProgress + 10) {
          sendPort.send("$currentProgress%\r cooking..");
          lastReportedProgress = currentProgress;
        }
      }
      sendPort.send("\nRead $position bytes");
      sendPort.send("Continue processing..");
      return ByteDataWrapper(buffer);
    }
  }

  int get position => _position;

  set position(final int value) {
    if (value < 0 || value > length) {
      throw RangeError.range(value, 0, _data.lengthInBytes, "View size");
    }
    if (value > buffer.lengthInBytes) {
      throw RangeError.range(value, 0, buffer.lengthInBytes, "Buffer size");
    }

    _position = value + _parentOffset;
  }

  double readFloat32() {
    var value = _data.getFloat32(_position, endian);
    _position += 4;
    return value;
  }

  double readFloat64() {
    var value = _data.getFloat64(_position, endian);
    _position += 8;
    return value;
  }

  int readInt8() {
    var value = _data.getInt8(_position);
    _position += 1;
    return value;
  }

  int readInt16() {
    var value = _data.getInt16(_position, endian);
    _position += 2;
    return value;
  }

  int readInt32() {
    var value = _data.getInt32(_position, endian);
    _position += 4;
    return value;
  }

  int readInt64() {
    var value = _data.getInt64(_position, endian);
    _position += 8;
    return value;
  }

  int readUint8() {
    var value = _data.getUint8(_position);
    _position += 1;
    return value;
  }

  int readUint16() {
    var value = _data.getUint16(_position, endian);
    _position += 2;
    return value;
  }

  int readUint32() {
    var value = _data.getUint32(_position, endian);
    _position += 4;
    return value;
  }

  int readUint64() {
    var value = _data.getUint64(_position, endian);
    _position += 8;
    return value;
  }

  List<double> readFloat32List(final int length) {
    var list = List<double>.generate(length, (final _) => readFloat32());
    return list;
  }

  List<double> readFloat64List(final int length) {
    var list = List<double>.generate(length, (final _) => readFloat64());
    return list;
  }

  List<int> readInt8List(final int length) {
    return List<int>.generate(length, (final _) => readInt8());
  }

  List<int> readInt16List(final int length) {
    return List<int>.generate(length, (final _) => readInt16());
  }

  List<int> readInt32List(final int length) {
    return List<int>.generate(length, (final _) => readInt32());
  }

  List<int> readInt64List(final int length) {
    return List<int>.generate(length, (final _) => readInt64());
  }

  List<int> readUint8List(final int length) {
    return List<int>.generate(length, (final _) => readUint8());
  }

  List<int> readUint16List(final int length) {
    return List<int>.generate(length, (final _) => readUint16());
  }

  List<int> readUint32List(final int length) {
    return List<int>.generate(length, (final _) => readUint32());
  }

  List<int> readUint64List(final int length) {
    return List<int>.generate(length, (final _) => readUint64());
  }

  Uint8List asUint8List(final int length) {
    var list = Uint8List.view(buffer, _position, length);
    _position += length;
    return list;
  }

  Uint16List asUint16List(final int length) {
    var list = Uint16List.view(buffer, _position, length);
    _position += length * 2;
    return list;
  }

  Uint32List asUint32List(final int length) {
    var list = Uint32List.view(buffer, _position, length);
    _position += length * 4;
    return list;
  }

  Uint64List asUint64List(final int length) {
    var list = Uint64List.view(buffer, _position, length);
    _position += length * 8;
    return list;
  }

  Int8List asInt8List(final int length) {
    var list = Int8List.view(buffer, _position, length);
    _position += length;
    return list;
  }

  Int16List asInt16List(final int length) {
    var list = Int16List.view(buffer, _position, length);
    _position += length * 2;
    return list;
  }

  Int32List asInt32List(final int length) {
    var list = Int32List.view(buffer, _position, length);
    _position += length * 4;
    return list;
  }

  String readString(final int length,
      {final StringEncoding encoding = StringEncoding.utf8}) {
    List<int> bytes;
    if (encoding != StringEncoding.utf16) {
      bytes = readUint8List(length);
    } else {
      bytes = readUint16List(length ~/ 2);
    }
    return decodeString(bytes, encoding);
  }

  String _readStringZeroTerminatedUtf16() {
    var bytes = <int>[];
    while (true) {
      var byte = _data.getUint16(_position, endian);
      _position += 2;
      if (byte == 0) break;
      bytes.add(byte);
    }
    return decodeString(bytes, StringEncoding.utf16);
  }

  String readStringZeroTerminated(
      {final StringEncoding encoding = StringEncoding.utf8}) {
    if (encoding == StringEncoding.utf16) {
      return _readStringZeroTerminatedUtf16();
    }
    var bytes = <int>[];
    while (true) {
      var byte = _data.getUint8(_position);
      _position += 1;
      if (byte == 0) break;
      bytes.add(byte);
    }
    return decodeString(bytes, encoding);
  }

  ByteDataWrapper makeSubView(final int length) {
    return ByteDataWrapper(buffer,
        endian: endian, parentOffset: _position, length: length);
  }

  void writeFloat32(final double value) {
    _data.setFloat32(_position, value, endian);
    _position += 4;
  }

  void writeFloat64(final double value) {
    _data.setFloat64(_position, value, endian);
    _position += 8;
  }

  void writeInt8(final int value) {
    _data.setInt8(_position, value);
    _position += 1;
  }

  void writeInt16(final int value) {
    _data.setInt16(_position, value, endian);
    _position += 2;
  }

  void writeInt32(final int value) {
    _data.setInt32(_position, value, endian);
    _position += 4;
  }

  void writeInt64(final int value) {
    _data.setInt64(_position, value, endian);
    _position += 8;
  }

  void writeUint8(final int value) {
    _data.setUint8(_position, value);
    _position += 1;
  }

  void writeUint16(final int value) {
    _data.setUint16(_position, value, endian);
    _position += 2;
  }

  void writeUint32(final int value) {
    _data.setUint32(_position, value, endian);
    _position += 4;
  }

  void writeUint64(final int value) {
    _data.setUint64(_position, value, endian);
    _position += 8;
  }

  void writeString(final String value,
      [final StringEncoding encoding = StringEncoding.utf8]) {
    var codes = encodeString(value, encoding);
    if (encoding == StringEncoding.utf16) {
      for (var code in codes) {
        _data.setUint16(_position, code, endian);
        _position += 2;
      }
    } else {
      for (var code in codes) {
        _data.setUint8(_position, code);
        _position += 1;
      }
    }
  }

  static const _zeroStr = "\x00";
  void writeString0P(final String value,
      [final StringEncoding encoding = StringEncoding.utf8]) {
    writeString(value + _zeroStr, encoding);
  }

  void writeBytes(final List<int> value) {
    for (var byte in value) {
      _data.setUint8(_position, byte);
      _position += 1;
    }
  }
}

String decodeString(final List<int> codes, final StringEncoding encoding) {
  switch (encoding) {
    case StringEncoding.utf8:
      return utf8.decode(codes, allowMalformed: true);
    case StringEncoding.utf16:
      return String.fromCharCodes(codes);
    case StringEncoding.shiftJis:
      return ShiftJIS().decode(codes);
  }
}

List<int> encodeString(final String str, final StringEncoding encoding) {
  switch (encoding) {
    case StringEncoding.utf8:
      return utf8.encode(str);
    case StringEncoding.utf16:
      return str.codeUnits;
    case StringEncoding.shiftJis:
      return ShiftJIS().encode(str);
  }
}
