import 'dart:io';
import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/naer_services/value_utils/handle_enemy_stats.dart';
import 'package:NAER/nier_cli/main_data_container.dart';

class ModifyEnemyStats {
  // original enemy data as a map of file paths to original data.
  static Map<String, List<EnemyExpInfoTable>> runTimeOriginalData = {};
  static List<File> runTimeEnemyFiles = [];
  static bool isOrgDataInRunTime = false;

  /// loads enemy files and original data into runtime memory if not already loaded.
  static Future<void> ensureFilesAreLoaded(final String currentDir) async {
    if (!isOrgDataInRunTime) {
      List<File> enemyFiles = await findEnemyStatFiles(currentDir);
      if (enemyFiles.isNotEmpty) {
        runTimeOriginalData =
            await ExpInfoUtils.storeOriginalValuesFromExpFile(enemyFiles);
        runTimeEnemyFiles = enemyFiles;
        isOrgDataInRunTime = true;
      }
    }
  }

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

  static Future<void> balanceEnemyStats(
      final MainData mainData, final String currentDir) async {
    await ensureFilesAreLoaded(currentDir);

    List<String> enemyList = mainData.argument['enemyList'];
    List<String> enemiesToBalance = SpecialEntities.enemiesToBalance;
    double balanceFactorHealth = 0.5;
    double balanceFactorDefence = 0.3;
    double balanceFactorAttack = 1.0;

    if (enemyList.isNotEmpty && !enemyList.contains('None')) {
      List<File> filteredFiles =
          await filterEnemyFiles(runTimeEnemyFiles, enemiesToBalance);

      await ExpInfoUtils.processExpInfoFiles(filteredFiles,
          healthMultiplier: balanceFactorHealth,
          attackMultiplier: balanceFactorDefence,
          defenceMultiplier: balanceFactorAttack);
    }
  }

  static Future<void> restoreEnemyStats() async {
    if (runTimeEnemyFiles.isNotEmpty && runTimeOriginalData.isNotEmpty) {
      await ExpInfoUtils.processExpInfoFiles(runTimeEnemyFiles,
          originalValuesMap: runTimeOriginalData,
          operation: OperationType.reset);
      runTimeOriginalData = {};
      runTimeEnemyFiles = [];
      isOrgDataInRunTime = false;
    }
  }
}
