import 'dart:developer';
import 'dart:io';

import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_database/handle_db_modifcation_time.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:path/path.dart' as path;

Future<List<String>> findModFiles(final String outputDirectory) async {
  List<String> modFiles = [];
  DateTime preRandomizationTime =
      await DatabaseModificationTimeHandler.getPreModificationTime();
  try {
    var directory = Directory(outputDirectory);
    if (await directory.exists()) {
      log("Scanning directory: $outputDirectory");
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dat')) {
          var fileModTime = await entity.lastModified();
          var fileName = path.basename(entity.path);
          if (fileName.startsWith("p100") ||
              fileName.startsWith("p200") ||
              fileName.startsWith("p300") ||
              fileName.startsWith("p400") ||
              fileName.startsWith("q") ||
              fileName.startsWith("r") ||
              fileName.startsWith("corehap") ||
              fileName.startsWith("em")) {
            log("Found .dat file: ${entity.path}, last modified: $fileModTime");

            if (fileModTime.isBefore(preRandomizationTime)) {
              modFiles.add(fileName);
              log("Adding mod file: $fileName");
            }
          }
        }
      }
    } else {
      log("Directory does not exist: $outputDirectory");
    }
  } catch (e, stackTrace) {
    ExceptionHandler().handle(
      e,
      stackTrace,
      extraMessage:
          "Caught while finding mod files in: Future<List<String>> findModFiles in $outputDirectory",
    );
  }

  DatabaseIgnoredFilesHandler.ignoredFiles.addAll(modFiles);
  await DatabaseIgnoredFilesHandler.saveIgnoredFilesToDatabase();
  log("Mod files found: $modFiles");
  return modFiles;
}

Future<bool> containsValidFiles(final String directoryPath) async {
  var directory = Directory(directoryPath);
  var files = directory.listSync();
  for (var file in files) {
    if (file is File) {
      var extension = file.path.split('.').last;
      if (extension == 'cpk' || extension == 'dat') {
        return true;
      }
    }
  }
  return false;
}
