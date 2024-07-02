import 'dart:io';

/// Finds and processes enemy CSV files containing bosenemys stats in the specified directory.
///
/// This function searches through the given [directoryPath] for files that match
/// the specific enemy pattern that contains enemy stats information. It then processes each
/// matching file by modifying its contents based on the provided [enemyStats] value.
///
/// - Parameters:
///   - directoryPath: The path of the directory to search in.
///   - enemyList: A list of enemy names or identifiers, which can be nested.
///   - enemyStats: A value representing the enemy stats to be used for modifying file contents.
Future<void> findEnemyStatFiles(String directoryPath, List<dynamic> enemyList,
    double enemyStats, bool reverseStats) async {
  var directory = Directory(directoryPath);

  if (!await directory.exists()) {
    //print("Directory does not exist: $directoryPath");
    return;
  }

  String directoryPattern = '\\nier2blender_extracted\\';

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File &&
        entity.path.contains(directoryPattern) &&
        entity.path.contains('ExpInfo')) {
      await processCsvFile(entity, enemyStats, reverseStats);
    }
  }
}

/// Processes a CSV file by modifying its contents based on the enemy stats.
///
/// This function reads the lines of the specified [file], modifies each line
/// based on the provided [enemyStats] value, and then writes the modified lines
/// back to the file. If [enemyStats] is 0.0, the file is skipped.
///
/// - Parameters:
///   - file: The file to process.
///   - enemyList: A list of enemy names or identifiers, not used in this function but retained for possible future use.
///   - enemyStats: A value representing the enemy stats to be used for modifying file contents.
Future<void> processCsvFile(
    File file, double enemyStats, bool reverseStats) async {
  try {
    if (enemyStats == 0.0) {
      // print("Enemy stats are 0.0, skipping file ${file.path}");
      return;
    }
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];

    for (var line in lines) {
      if (!reverseStats) {
        String modifiedLine = modifyLine(line, enemyStats);
        modifiedLines.add(modifiedLine);
      } else {
        String modifiedLine = reverseModifyLine(line, enemyStats);
        modifiedLines.add(modifiedLine);
      }
    }

    await file.writeAsString(modifiedLines.join('\r\n'));
  } catch (e) {
    //print("Error processing file ${file.path}: $e");
  }
}

/// Modifies a line of CSV content based on the enemy stats.
///
/// This function takes a line of CSV data, parses it, and modifies the values in
/// specific columns (columns 2 and 3) based on the provided [enemyStats] value. The
/// values are scaled by predetermined factors and the modified line is returned as a string.
/// If the values in columns 2 or 3 are not valid numbers, they are left unchanged.
/// The values in columns 0, 3, and 4 are preserved as they are.
///
/// - Parameters:
///   - line: A line of CSV content to modify.
///   - enemyStats: A value representing the enemy stats to be used for modifying the line.
/// - Returns: The modified line of CSV content as a string.
String modifyLine(String line, double enemyStats) {
  const double maxFactorColumn2 = 2.30;
  const double maxFactorColumn3 = 1.90;

  var values = line.split(',');

  if (values.length >= 5) {
    // Parse and modify the value in the second column (index 1)
    var valueColumn2 = double.tryParse(values[1]);
    if (valueColumn2 != null) {
      double scaleFactorColumn2 = enemyStats / 5.0 * maxFactorColumn2;
      double modifiedValueColumn2 = valueColumn2 * scaleFactorColumn2;
      values[1] = modifiedValueColumn2.round().toString();
    }

    // Parse and modify the value in the third column (index 2)
    var valueColumn3 = double.tryParse(values[2]);
    if (valueColumn3 != null) {
      double scaleFactorColumn3 = enemyStats / 5.0 * maxFactorColumn3;
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

/// Reverts the modifications of a line of CSV content based on the enemy stats.
///
/// This function takes a line of CSV data, parses it, and reverts the values in
/// specific columns (columns 2 and 3) based on the provided [enemyStats] value. The
/// values are scaled by predetermined factors and the reverted line is returned as a string.
/// If the values in columns 2 or 3 are not valid numbers, they are left unchanged.
/// The values in columns 0, 3, and 4 are preserved as they are.
///
/// - Parameters:
///   - line: A line of CSV content to revert.
///   - enemyStats: A value representing the enemy stats to be used for reverting the line.
/// - Returns: The reverted line of CSV content as a string.
String reverseModifyLine(String line, double enemyStats) {
  const double maxFactorColumn2 = 2.30;
  const double maxFactorColumn3 = 1.90;

  var values = line.split(',');

  if (values.length >= 5) {
    // Parse and revert the value in the second column (index 1)
    var valueColumn2 = double.tryParse(values[1]);
    if (valueColumn2 != null) {
      double scaleFactorColumn2 = enemyStats / 5.0 * maxFactorColumn2;
      double revertedValueColumn2 = valueColumn2 / scaleFactorColumn2;
      values[1] = revertedValueColumn2.round().toString();
    }

    // Parse and revert the value in the third column (index 2)
    var valueColumn3 = double.tryParse(values[2]);
    if (valueColumn3 != null) {
      double scaleFactorColumn3 = enemyStats / 5.0 * maxFactorColumn3;
      double revertedValueColumn3 = valueColumn3 / scaleFactorColumn3;
      values[2] = revertedValueColumn3.round().toString();
    }

    // Preserve the original values for columns 0, 3, and 4
    values[0] = line.split(',')[0];
    values[3] = line.split(',')[3];
    values[4] = line.split(',')[4];
  }

  return values.join(',');
}
