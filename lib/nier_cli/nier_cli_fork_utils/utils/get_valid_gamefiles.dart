import 'dart:io';

import 'package:path/path.dart';

/// TODO FOR NOW UNUSED HELPER METHODS

Future<List<String>> getValidDatFiles(String directoryPath) async {
  return _getValidFiles(directoryPath, '.dat');
}

Future<List<String>> getValidYaxFiles(String directoryPath) async {
  return _getValidFiles(directoryPath, '.yax');
}

Future<List<String>> getValidPaksFiles(String directoryPath) async {
  return _getValidFiles(directoryPath, '.pak');
}

Future<List<String>> _getValidFiles(
    String directoryPath, String extension) async {
  final dir = Directory(directoryPath);
  if (!await dir.exists()) return [];

  final List<String> validFiles = [];

  await for (FileSystemEntity entity
      in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith(extension)) {
      validFiles.add(entity.path);
    }
  }

  return validFiles;
}

Future<List<String>> getValidCpkFiles(String directoryPath) async {
  final dir = Directory(directoryPath);
  final files = await dir.list(recursive: false).toList();

  return files
      .where((file) {
        if (file is! File || !file.path.endsWith('.cpk')) return false;

        var fileName = basename(file.path).toLowerCase();

        return fileName == 'data002.cpk' ||
            fileName == 'data012.cpk' ||
            fileName == 'data100.cpk' ||
            fileName == 'data006.cpk' ||
            fileName == 'data016.cpk';
      })
      .map((file) => file.path)
      .toList();
}
