import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:NAER/naer_save_editor/name/name_animation.dart';
import 'package:flutter/material.dart';

class SaveFileName extends StatefulWidget {
  final String filePath;
  const SaveFileName({super.key, required this.filePath});

  @override
  State<SaveFileName> createState() => _SaveFileNameState();
}

class _SaveFileNameState extends State<SaveFileName> {
  static const int startNamePosition = 0x00034;
  static const int nameLength =
      70; // The length is in bytes, but since UTF-16 uses 2 bytes per character, the max character length will be nameLength / 2
  String ingameName = "";

  @override
  void initState() {
    super.initState();
    readInGameName().then((final name) {
      setState(() {
        ingameName = name;
      });
    });
  }

  Future<String> readInGameName() async {
    File file = File(widget.filePath);
    if (!await file.exists()) {
      return "File not found";
    }

    RandomAccessFile raf = await file.open();
    await raf.setPosition(startNamePosition);
    List<int> bytes = await raf.read(nameLength);
    await raf.close();

    // Convert List<int> to Uint16List for UTF-16 decoding
    Uint8List byteList = Uint8List.fromList(bytes);
    Uint16List uint16List = byteList.buffer.asUint16List();
    String name = String.fromCharCodes(uint16List).replaceAll('\x00', '');

    return name;
  }

  @override
  Widget build(final BuildContext context) {
    return AnimatedNameDisplay(ingameName: ingameName);
  }
}
