// ignore_for_file: avoid_print

import 'dart:io';

Future<void> findBossStatFiles(
    String directoryPath, List<String> bossList, double bossStats) async {
  var directory = Directory(directoryPath);

  if (!await directory.exists()) {
    print("Directory does not exist: $directoryPath");
    return;
  }

  await for (var entity in directory.list(recursive: true)) {
    if (entity is Directory &&
        entity.path.contains("_extracted\\em\\nier2blender_extracted\\")) {
      await for (var file in entity.list()) {
        if (file is File && file.path.contains('ExpInfo')) {
          await processCsvFile(file, bossList, bossStats);
        }
      }
    }
  }
}

Future<void> processCsvFile(
    File file, List<String> bossList, double bossStats) async {
  try {
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
  const double maxFactorColumn3 = 1.75;

  var values = line.split(',');

  if (values.length >= 5) {
    var valueColumn2 = double.tryParse(values[1]);
    if (valueColumn2 != null) {
      // Scale factor for column 2 based on bossStats
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
