import 'dart:io';

/// Finds enemy CSV files containing enemy stats in the specified directory.
Future<List<File>> findEnemyStatFiles(final String directoryPath) async {
  var directory = Directory(directoryPath);
  List<File> enemyFiles = [];

  if (!await directory.exists()) {
    return enemyFiles;
  }

  String directoryPattern = '\\nier2blender_extracted\\';

  await for (var entity in directory.list(recursive: true)) {
    if (entity is File &&
        entity.path.contains(directoryPattern) &&
        entity.path.contains('ExpInfo')) {
      enemyFiles.add(entity);
    }
  }

  return enemyFiles;
}

Future<void> processCsvFile(final File file, final double enemyStats,
    {required final bool reverseStats}) async {
  try {
    if (enemyStats == 0.0) {
      return;
    }
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];

    for (var line in lines) {
      if (!reverseStats && enemyStats != 0.0) {
        String modifiedLine = modifyLine(line, enemyStats);
        modifiedLines.add(modifiedLine);
      } else if (reverseStats && enemyStats != 0.0) {
        String modifiedLine = reverseModifyLine(line, enemyStats);
        modifiedLines.add(modifiedLine);
      }
    }

    await file.writeAsString(modifiedLines.join('\r\n'));
  } catch (e) {
    // print("Error processing file ${file.path}: $e");
  }
}

String modifyLine(final String line, final double enemyStats) {
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

String reverseModifyLine(final String line, final double enemyStats) {
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

/// Filters the enemy files based on the list of enemies to balance.
Future<List<File>> filterEnemyFiles(
    final List<File> enemyFiles, final List<String> enemiesToBalance) async {
  List<File> filteredFiles = [];

  for (var file in enemyFiles) {
    for (var enemy in enemiesToBalance) {
      if (file.path.contains(enemy)) {
        filteredFiles.add(file);
        break; // Stop checking other enemies once a match is found
      }
    }
  }

  return filteredFiles;
}

/// Balances enemy stats in the CSV file by reducing values by balanceFactor
Future<void> balanceEnemyToBalanceCsvFiles(
    final File file, final double balanceFactor) async {
  try {
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];

    for (var line in lines) {
      var values = line.split(',');

      if (values.length >= 5) {
        // Parse and modify the value in the second column (index 0)
        var valueColumn0 = double.tryParse(values[0]);
        if (valueColumn0 != null) {
          double modifiedValueColumn0 = valueColumn0 * balanceFactor;
          values[0] = modifiedValueColumn0.round().toString();
        }

        // Parse and modify the value in the third column (index 2)
        var valueColumn1 = double.tryParse(values[2]);
        if (valueColumn1 != null) {
          double modifiedValueColumn1 = valueColumn1 * balanceFactor;
          values[2] = modifiedValueColumn1.round().toString();
        }

        // Preserve the original values for columns 0, 3, and 4
        values[1] = line.split(',')[1];
        values[3] = line.split(',')[3];
        values[4] = line.split(',')[4];
      }

      modifiedLines.add(values.join(','));
    }

    await file.writeAsString(modifiedLines.join('\r\n'));
  } catch (e) {
    //print("Error processing file ${file.path}: $e");
  }
}

/// Normalizes enemy stats in the CSV file by reverting balanced values to original.
Future<void> normalizeEnemyToBalanceCsvFiles(
    final File file, final double balanceFactor) async {
  try {
    final lines = await file.readAsLines();
    List<String> modifiedLines = [];

    for (var line in lines) {
      var values = line.split(',');

      if (values.length >= 5) {
        // Parse and revert the value in the second column (index 1)
        var valueColumn0 = double.tryParse(values[0]);
        if (valueColumn0 != null) {
          double revertedValueColumn0 = valueColumn0 / balanceFactor;
          values[0] = revertedValueColumn0.round().toString();
        }

        // Parse and revert the value in the third column (index 2)
        var valueColumn1 = double.tryParse(values[2]);
        if (valueColumn1 != null) {
          double revertedValueColumn1 = valueColumn1 / balanceFactor;
          values[2] = revertedValueColumn1.round().toString();
        }

        // Preserve the original values for columns 0, 3, and 4
        values[1] = line.split(',')[1];
        values[3] = line.split(',')[3];
        values[4] = line.split(',')[4];
      }

      modifiedLines.add(values.join(','));
    }

    await file.writeAsString(modifiedLines.join('\r\n'));
  } catch (e) {
    //print("Error processing file ${file.path}: $e");
  }
}
