import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileUtilsProvider = Provider<FileUtils>((ref) {
  return FileUtils();
});

class FileUtils {
  static Future<String> computeFileHash(File file) async {
    try {
      var contents = await file.readAsBytes();
      var digest = await compute(sha256.convert, contents);
      return digest.toString();
    } catch (e) {
      print("Error computing file hash: $e");
      return "ERROR_COMPUTING_HASH";
    }
  }

  static Future<void> deleteEmptyParentDirectories(
      Directory directory, String rootPath) async {
    if (directory.path == rootPath) {
      return;
    }
    if (await directory.list().isEmpty) {
      await directory.delete();
      await deleteEmptyParentDirectories(directory.parent, rootPath);
    }
  }
}
