// ignore_for_file: avoid_print

import 'dart:io';

Future<void> findBossStatFiles(String directoryPath, List<String> bossList,
    double bossStats, String enemyLevel) async {
  var directory = Directory(directoryPath);

  // Check if the provided directory exists
  if (!await directory.exists()) {
    print("Directory does not exist: $directoryPath");
    return;
  }

  // Traverse directories
  await for (var entity in directory.list(recursive: true)) {
    if (entity is Directory &&
        entity.path.contains("_extracted\\em\\nier2blender_extracted\\")) {
      // Process each CSV file in the directory
      await for (var file in entity.list()) {
        if (file is File && file.path.contains('ExpInfo')) {
          await processCsvFile(file, bossList, bossStats, enemyLevel);
        }
      }
    }
  }
}

bool isSpecialBoss(String fileName, List<String> bossList) {
  var enemyName = fileName.split('ExpInfo.csv')[0];
  for (var sublist in bossList) {
    var bosses = sublist.replaceAll('[', '').replaceAll(']', '').split(',');

    // Check if enemyName is a special boss
    if (bosses.contains(enemyName)) {
      switch (enemyName) {
        case "em1000":
        case "em1100":
          return true;
        default:
          // If it's not one of the explicitly specified special bosses, return false
          return false;
      }
    }
  }
  // Return false if enemyName is not found in any sublist
  return false;
}

Future<void> processCsvFile(File file, List<String> bossList, double bossStats,
    String enemyLevel) async {
  try {
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];
    String? firstRowStatsForSpecialBoss;
    int levelIndex = int.tryParse(enemyLevel) ?? 1;
    String fileName = file.uri.pathSegments.last;

    bool isFileSpecialBoss = isSpecialBoss(fileName, bossList);
    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];
      String modifiedLine = modifyLine(line, bossStats, enemyLevel);
      modifiedLines.add(modifiedLine);

      // Store the stats for the specified level if it's a special boss
      if (isFileSpecialBoss && i == levelIndex - 1) {
        firstRowStatsForSpecialBoss = modifiedLine;
      }
    }

    // Replace the first row for special bosses
    if (firstRowStatsForSpecialBoss != null) {
      modifiedLines[0] = firstRowStatsForSpecialBoss;
      // Debug: Confirming the first row replacement
      print('First row replaced with: $firstRowStatsForSpecialBoss');
    }

    // Write the modified data back to the file
    await file.writeAsString(modifiedLines.join('\n'));
  } catch (e) {
    print("Error processing file ${file.path}: $e");
  }
}

String modifyLine(String line, double bossStats, String enemyLevel) {
  // Maximum multiplication factors for each of the first three columns when bossStats is 5.0
  const List<double> maxFactors = [16.00, 1.30, 1.60];

  var values = line.split(',');
  // Check if there are at least 5 columns
  if (values.length >= 5) {
    // Modify only the first three columns
    for (var i = 0; i < 3; i++) {
      var value = double.tryParse(values[i]);
      if (value != null) {
        // Linearly scale the multiplication factor based on bossStats
        double scaledFactor = maxFactors[i] * (bossStats / 5.0);
        // Apply the scaled factor to the value and round it
        double modifiedValue = value * scaledFactor;
        values[i] = modifiedValue.round().toString();
      }
    }
    // The last two columns remain unchanged
    values[3] = line.split(',')[3];
    values[4] = line.split(',')[4];
  }
  return values.join(',');
}
