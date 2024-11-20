import 'dart:io';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileUtilsProvider = Provider<FileUtils>((final ref) {
  return FileUtils();
});

class FileUtils {
  static Future<String> computeFileHash(final File file) async {
    try {
      var contents = await file.readAsBytes();
      var digest = await compute(sha256.convert, contents);
      return digest.toString();
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace,
          extraMessage: "Error computing file hash: File: ${file.toString()}");
      return "ERROR_COMPUTING_HASH";
    }
  }

  static Future<void> deleteEmptyParentDirectories(
      final Directory directory, final String rootPath) async {
    if (directory.path == rootPath) {
      return;
    }
    if (await directory.list().isEmpty) {
      await directory.delete();
      await deleteEmptyParentDirectories(directory.parent, rootPath);
    }
  }
}
