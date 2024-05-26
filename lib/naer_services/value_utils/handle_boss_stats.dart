// ignore_for_file: avoid_print

import 'dart:io';

/// Finds and processes enemy CSV files containing boss stats in the specified directory.
///
/// This function searches through the given [directoryPath] for files that match
/// the specific boss pattern that contains boss stats information. It then processes each
/// matching file by modifying its contents based on the provided [bossStats] value.
///
/// - Parameters:
///   - directoryPath: The path of the directory to search in.
///   - bossList: A list of boss names or identifiers, which can be nested.
///   - bossStats: A value representing the boss stats to be used for modifying file contents.
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

/// Flattens a nested list of boss names or identifiers into a single list.
///
/// This helper function recursively flattens the provided [list], ensuring that all
/// nested lists are merged into a single list of strings.
///
/// - Parameters:
///   - list: A list which may contain nested lists of strings.
/// - Returns: A flattened list of strings.
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

/// Processes a CSV file by modifying its contents based on the boss stats.
///
/// This function reads the lines of the specified [file], modifies each line
/// based on the provided [bossStats] value, and then writes the modified lines
/// back to the file. If [bossStats] is 0.0, the file is skipped.
///
/// - Parameters:
///   - file: The file to process.
///   - bossList: A list of boss names or identifiers, not used in this function but retained for possible future use.
///   - bossStats: A value representing the boss stats to be used for modifying file contents.
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

/// Modifies a line of CSV content based on the boss stats.
///
/// This function takes a line of CSV data, parses it, and modifies the values in
/// specific columns (columns 2 and 3) based on the provided [bossStats] value. The
/// values are scaled by predetermined factors and the modified line is returned as a string.
/// If the values in columns 2 or 3 are not valid numbers, they are left unchanged.
/// The values in columns 0, 3, and 4 are preserved as they are.
///
/// - Parameters:
///   - line: A line of CSV content to modify.
///   - bossStats: A value representing the boss stats to be used for modifying the line.
/// - Returns: The modified line of CSV content as a string.
String modifyLine(String line, double bossStats) {
  const double maxFactorColumn2 = 2.30;
  const double maxFactorColumn3 = 1.90;

  var values = line.split(',');

  if (values.length >= 5) {
    // Parse and modify the value in the second column (index 1)
    var valueColumn2 = double.tryParse(values[1]);
    if (valueColumn2 != null) {
      double scaleFactorColumn2 = bossStats / 5.0 * maxFactorColumn2;
      double modifiedValueColumn2 = valueColumn2 * scaleFactorColumn2;
      values[1] = modifiedValueColumn2.round().toString();
    }

    // Parse and modify the value in the third column (index 2)
    var valueColumn3 = double.tryParse(values[2]);
    if (valueColumn3 != null) {
      double scaleFactorColumn3 = bossStats / 5.0 * maxFactorColumn3;
      double modifiedValueColumn3 = valueColumn3 * scaleFactorColumn3;
      values[2] = modifiedValueColumn3.round().toString();
    }

    // Preserve the original values for columns 0, 3, and 4
    values[0] = line.split(',')[0];
    values[3] = line.split(',')[3];
    values[4] = line.split(',')[4];
  }

  return values.join(',');
}
