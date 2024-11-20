import 'dart:io';

import 'package:NAER/naer_utils/exception_handler.dart';

enum OperationType { scale, reset }

class EnemyExpInfoTable {
  final int healthPoints;
  final int attack;
  final int defence;
  final int experience;
  final int stunPenetrationResistance;

  EnemyExpInfoTable({
    required this.healthPoints,
    required this.attack,
    required this.defence,
    required this.experience,
    required this.stunPenetrationResistance,
  });

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is EnemyExpInfoTable &&
          runtimeType == other.runtimeType &&
          healthPoints == other.healthPoints &&
          attack == other.attack &&
          defence == other.defence &&
          experience == other.experience &&
          stunPenetrationResistance == other.stunPenetrationResistance;

  @override
  int get hashCode =>
      healthPoints.hashCode ^
      attack.hashCode ^
      defence.hashCode ^
      experience.hashCode ^
      stunPenetrationResistance.hashCode;

  EnemyExpInfoTable applyMultiplier({
    required final int level,
    final double? healthMultiplier,
    final double? attackMultiplier,
    final double? defenceMultiplier,
  }) {
    return EnemyExpInfoTable(
      healthPoints: _scaleStat(healthPoints, healthMultiplier ?? 1.0, level),
      attack: _scaleStat(attack, attackMultiplier ?? 1.0, level),
      defence: _scaleStat(defence, defenceMultiplier ?? 1.0, level),
      experience: experience,
      stunPenetrationResistance: stunPenetrationResistance,
    );
  }

  @override
  String toString() {
    return '$healthPoints,$attack,$defence,$experience,$stunPenetrationResistance';
  }

  int _scaleStat(final int baseStat, final double multiplier, final int level) {
    const int maxLevel = 99;

    double adjustedMultiplier;

    if (multiplier > 1.0) {
      // Case 1: Multiplier greater than 1, increasing stats
      // Apply a decaying effect as the level increases
      adjustedMultiplier =
          1.0 + (multiplier - 1.0) * (1 - (level / maxLevel.toDouble()) * 0.6);
    } else {
      // Case 2: Multiplier less than or equal to 1, reducing stats
      // Directly apply the multiplier without decay
      adjustedMultiplier = multiplier;
    }

    if (adjustedMultiplier < 0) {
      adjustedMultiplier = 0;
    }
    return (baseStat * adjustedMultiplier).round();
  }

  factory EnemyExpInfoTable.fromCsvLine(final String line) {
    var values = line.split(',');

    if (values.length >= 5) {
      return EnemyExpInfoTable(
        healthPoints: int.tryParse(values[0]) ?? 0,
        attack: int.tryParse(values[1]) ?? 0,
        defence: int.tryParse(values[2]) ?? 0,
        experience: int.tryParse(values[3]) ?? 0,
        stunPenetrationResistance: int.tryParse(values[4]) ?? 0,
      );
    } else {
      throw const FormatException("Invalid CSV line format");
    }
  }
}

class ExpInfoUtils {
  static Future<void> processExpInfoFiles(final List<File> files,
      {final double? healthMultiplier,
      final double? attackMultiplier,
      final double? defenceMultiplier,
      final OperationType operation = OperationType.scale,
      final Map<String, List<EnemyExpInfoTable>>? originalValuesMap}) async {
    for (var file in files) {
      List<EnemyExpInfoTable> localOriginalValues;

      if (operation == OperationType.reset && originalValuesMap != null) {
        localOriginalValues = originalValuesMap[file.path]!;
      } else {
        final lines = await file.readAsLines();
        localOriginalValues = lines
            .map((final line) => EnemyExpInfoTable.fromCsvLine(line))
            .toList();
      }

      await _processCsvFile(
        file,
        healthMultiplier: healthMultiplier,
        attackMultiplier: attackMultiplier,
        defenceMultiplier: defenceMultiplier,
        operation: operation,
        originalValues: localOriginalValues,
      );
    }
  }

  static Future<Map<String, List<EnemyExpInfoTable>>>
      storeOriginalValuesFromExpFile(final List<File> enemyFiles) async {
    Map<String, List<EnemyExpInfoTable>> originalValuesMap = {};

    for (var file in enemyFiles) {
      final lines = await file.readAsLines();
      final originalValues = lines
          .map((final line) => EnemyExpInfoTable.fromCsvLine(line))
          .toList();
      originalValuesMap[file.path] = originalValues;
    }

    return originalValuesMap;
  }

  static Future<void> _processCsvFile(final File file,
      {final double? healthMultiplier,
      final double? attackMultiplier,
      final double? defenceMultiplier,
      final OperationType operation = OperationType.scale,
      final List<EnemyExpInfoTable>? originalValues}) async {
    try {
      final lines = await file.readAsLines();
      List<String> modifiedLines = [];

      for (int i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.trim().isEmpty) continue;

        int level = i + 1;
        var enemy = EnemyExpInfoTable.fromCsvLine(line);
        EnemyExpInfoTable modifiedEnemy;

        if (operation == OperationType.reset && originalValues != null) {
          modifiedEnemy = originalValues[i];
        } else {
          modifiedEnemy = enemy.applyMultiplier(
            level: level,
            healthMultiplier: healthMultiplier,
            attackMultiplier: attackMultiplier,
            defenceMultiplier: defenceMultiplier,
          );
        }

        modifiedLines.add(modifiedEnemy.toString());
      }

      await file.writeAsString(modifiedLines.join('\r\n'));
    } catch (e, stackTrace) {
      ExceptionHandler().handle(e, stackTrace,
          extraMessage:
              "Caught while processing csv file: ${file.toString()} in _processCsvFile from ExpInfoUtils");
    }
  }
}

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

Future<List<File>> filterEnemyFiles(
    final List<File> enemyFiles, final List<String> enemiesToBalance) async {
  List<File> filteredFiles = [];

  for (var file in enemyFiles) {
    for (var enemy in enemiesToBalance) {
      if (file.path.contains(enemy)) {
        filteredFiles.add(file);
        break;
      }
    }
  }

  return filteredFiles;
}
