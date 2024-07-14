import 'dart:developer';
import 'dart:io';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:path/path.dart' as path;

Future<List<String>> findModFiles(String outputDirectory) async {
  List<String> modFiles = [];
  DateTime preRandomizationTime = await FileChange.getPreRandomizationTime();
  try {
    var directory = Directory(outputDirectory);
    if (await directory.exists()) {
      log("Scanning directory: $outputDirectory");
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dat')) {
          var fileModTime = await entity.lastModified();
          var fileName = path.basename(entity.path);
          if (fileName.contains("p100") ||
              fileName.contains("p200") ||
              fileName.contains("p300") ||
              fileName.contains("p400") ||
              fileName.contains("q") ||
              fileName.contains("r") ||
              fileName.contains("corehap") ||
              fileName.contains("em")) {
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
  } catch (e) {
    log('Error while finding mod files: $e');
  }
  FileChange.ignoredFiles.addAll(modFiles);
  await FileChange.saveIgnoredFiles();
  log("Mod files found: $modFiles");
  return modFiles;
}

Future<bool> containsValidFiles(String directoryPath) async {
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
