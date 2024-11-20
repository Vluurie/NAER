import 'dart:io';
import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_stats.dart';
import 'package:NAER/nier_cli/main_data_container.dart';

/// A utility class for modifying and managing enemy stats in runtime.
class ModifyEnemyStats {
  /// Stores the original enemy data as a map of file paths to their corresponding data.
  static Map<String, List<EnemyExpInfoTable>> runTimeOriginalData = {};

  /// A list of enemy stat files currently loaded into runtime.
  static List<File> runTimeEnemyFiles = [];

  /// Tracks whether the original data has been loaded into runtime memory.
  static bool isOrgDataInRunTime = false;

  /// Ensures that enemy files and original data are loaded into runtime memory if not already done.
  ///
  /// Parameters:
  /// - [currentDir]: The directory where enemy stat files are located.
  static Future<void> ensureFilesAreLoaded(final String currentDir) async {
    if (!isOrgDataInRunTime) {
      // Find and load enemy stat files
      List<File> enemyFiles = await findEnemyStatFiles(currentDir);
      if (enemyFiles.isNotEmpty) {
        runTimeOriginalData =
            await ExpInfoUtils.storeOriginalValuesFromExpFile(enemyFiles);
        runTimeEnemyFiles = enemyFiles;
        isOrgDataInRunTime = true;
      }
    }
  }

  /// Processes and modifies enemy stats based on user-specified arguments.
  ///
  /// Parameters:
  /// - [mainData]: Contains user arguments, including the enemy list and stats multiplier.
  /// - [currentDir]: The directory where enemy stat files are located.
  ///
  /// Adjusts the health, attack, and defence stats for specified enemies.
  static Future<void> processEnemyStats(
      final MainData mainData, final String currentDir) async {
    await ensureFilesAreLoaded(currentDir);

    List<String> enemyList = mainData.argument['enemyList'];
    double enemyStats = mainData.argument['enemyStats'];

    if (enemyList.isNotEmpty &&
        !enemyList.contains('None') &&
        enemyStats.sign != 0 &&
        enemyStats != 1.0) {
      await ExpInfoUtils.processExpInfoFiles(runTimeEnemyFiles,
          healthMultiplier: enemyStats,
          attackMultiplier: enemyStats,
          defenceMultiplier: enemyStats);
    }
  }

  /// Balances enemy stats using predefined factors for health, defence, and attack.
  ///
  /// Parameters:
  /// - [mainData]: Contains user arguments, including the enemy list.
  /// - [currentDir]: The directory where enemy stat files are located.
  ///
  /// Filters the enemy files to apply balance adjustments only to specific entities.
  static Future<void> balanceEnemyStats(
      final MainData mainData, final String currentDir) async {
    await ensureFilesAreLoaded(currentDir);

    List<String> enemyList = mainData.argument['enemyList'];
    List<String> enemiesToBalance = SpecialEntities.enemiesToBalance;
    double balanceFactorHealth = 0.5;
    double balanceFactorDefence = 0.3;
    double balanceFactorAttack = 1.0;

    if (enemyList.isNotEmpty && !enemyList.contains('None')) {
      // Filter files to balance only specific enemies
      List<File> filteredFiles =
          await filterEnemyFiles(runTimeEnemyFiles, enemiesToBalance);

      await ExpInfoUtils.processExpInfoFiles(filteredFiles,
          healthMultiplier: balanceFactorHealth,
          attackMultiplier: balanceFactorDefence,
          defenceMultiplier: balanceFactorAttack);
    }
  }

  /// Restores enemy stats to their original values.
  ///
  /// Clears runtime memory and resets enemy stats using the stored original data.
  static Future<void> restoreEnemyStats() async {
    if (runTimeEnemyFiles.isNotEmpty && runTimeOriginalData.isNotEmpty) {
      await ExpInfoUtils.processExpInfoFiles(runTimeEnemyFiles,
          originalValuesMap: runTimeOriginalData,
          operation: OperationType.reset);
      // Clear runtime data
      runTimeOriginalData = {};
      runTimeEnemyFiles = [];
      isOrgDataInRunTime = false;
    }
  }
}
