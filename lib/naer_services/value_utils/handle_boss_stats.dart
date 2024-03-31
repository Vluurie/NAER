// ignore_for_file: avoid_print

import 'dart:io';

Future<void> findBossStatFiles(
    String directoryPath, List<dynamic> bossList, double bossStats) async {
  var directory = Directory(directoryPath);

  if (!await directory.exists()) {
    print("Directory does not exist: $directoryPath");
    return;
  }

  var flattenedBossList = flattenList(bossList);

  String directoryPattern = '\\nier2blender_extracted\\';

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File &&
        entity.path.contains(directoryPattern) &&
        entity.path.contains('ExpInfo')) {
      await processCsvFile(entity, flattenedBossList, bossStats);
    }
  }
}

// Helper function to flatten the list
List<String> flattenList(List<dynamic> list) {
  var flattenedList = <String>[];
  for (var element in list) {
    if (element is List) {
      flattenedList.addAll(flattenList(element));
    } else if (element is String) {
      flattenedList.add(element);
    } else {
      flattenedList.add(element.toString());
    }
  }
  return flattenedList;
}

Future<void> processCsvFile(
    File file, List<String> bossList, double bossStats) async {
  try {
    if (bossStats == 0.0) {
      print("Boss stats are 0.0, skipping file ${file.path}");
      return;
    }
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];

    for (var line in lines) {
      String modifiedLine = modifyLine(line, bossStats);
      modifiedLines.add(modifiedLine);
    }

    await file.writeAsString(modifiedLines.join('\r\n'));
  } catch (e) {
    print("Error processing file ${file.path}: $e");
  }
}

String modifyLine(String line, double bossStats) {
  const double maxFactorColumn2 = 2.30;
  const double maxFactorColumn3 = 1.90;

  var values = line.split(',');

  if (values.length >= 5) {
    var valueColumn2 = double.tryParse(values[1]);
    if (valueColumn2 != null) {
      double scaleFactorColumn2 = bossStats / 5.0 * maxFactorColumn2;
      double modifiedValueColumn2 = valueColumn2 * scaleFactorColumn2;
      values[1] = modifiedValueColumn2.round().toString();
    }

    var valueColumn3 = double.tryParse(values[2]);
    if (valueColumn3 != null) {
      // Scale factor for column 3 based on bossStats
      double scaleFactorColumn3 = bossStats / 5.0 * maxFactorColumn3;
      double modifiedValueColumn3 = valueColumn3 * scaleFactorColumn3;
      values[2] = modifiedValueColumn3.round().toString();
    }

    values[0] = line.split(',')[0];
    values[3] = line.split(',')[3];
    values[4] = line.split(',')[4];
  }

  return values.join(',');
}
