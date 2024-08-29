import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class FileChange {
  String filePath;
  String action;
  String? originalFilePath;
  bool isAddition;

  FileChange(this.filePath, this.action, this.isAddition,
      [this.originalFilePath]);

  static String get settingsDirectoryPath {
    return 'NAER_Settings';
  }

  static List<FileChange> changes = [];
  static List<String> ignoredFiles = [];

  static Future<String> ensureSettingsDirectory() async {
    var exeDirectory = File(Platform.resolvedExecutable).parent.path;
    final settingsDirectory = Directory('$exeDirectory/NAER_Settings');
    if (!await settingsDirectory.exists()) {
      await settingsDirectory.create(recursive: true);
    }
    return settingsDirectory.path;
  }

  static Future<void> logChange(
    final String filePath,
    final String action, {
    required final bool isAddition,
    final String? originalFilePath,
  }) async {
    await loadChanges();

    FileChange? existingChange;
    try {
      existingChange =
          changes.firstWhere((final change) => change.filePath == filePath);
    } catch (e) {
      existingChange = null;
    }

    if (existingChange != null) {
      existingChange.isAddition = isAddition;
    } else {
      final change = FileChange(filePath, action, isAddition, originalFilePath);
      changes.add(change);
    }

    if (isAddition && !ignoredFiles.contains(path.basename(filePath))) {
      String ignoredAdditionFiles = path.basename(filePath);
      ignoredFiles.add(ignoredAdditionFiles);
    }

    await saveChanges();
    await saveIgnoredFiles();
  }

  static Future<void> saveIgnoredFiles() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(ignoredFiles);
    await prefs.setString('ignored_files', jsonData);
  }

  static Future<List<String>> loadIgnoredFiles() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('ignored_files') ?? '[]';
    return ignoredFiles = List<String>.from(jsonDecode(jsonData));
  }

  static Future<void> removeIgnoreFiles(
      final List<String> filesToRemove) async {
    await loadIgnoredFiles();
    ignoredFiles.removeWhere((final file) => filesToRemove.contains(file));
    await saveIgnoredFiles();
  }

  static Future<void> undoChanges({required final bool isAddition}) async {
    for (FileChange change in changes.reversed) {
      try {
        if (change.isAddition == isAddition) {
          if (change.action == 'create' &&
              !ignoredFiles.contains(change.filePath)) {
            var file = File(change.filePath);
            if (await file.exists()) {
              await file.delete();
            }
            String ignoredAdditionFile = path.basename(change.filePath);
            ignoredFiles.remove(ignoredAdditionFile);
          } else if (change.action == 'modify' &&
              change.originalFilePath != null) {
            var originalFile = File(change.originalFilePath!);
            await originalFile.copy(change.filePath);
          } else if (change.action == 'delete') {
            //.....
          }
        }
      } catch (e) {
        if (kDebugMode) {
          LogState()
              .addLog('Error during undoing change for ${change.filePath}: $e');
        }
      }
    }
    changes.removeWhere((final change) => change.isAddition == isAddition);
    await saveChanges();
    await saveIgnoredFiles();
  }

  static Future<void> saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(changes.map((final c) => c.toJson()).toList());
    await prefs.setString('file_changes', jsonData);
  }

  static Future<void> loadChanges() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('file_changes') ?? '[]';
    List<dynamic> data = jsonDecode(jsonData);
    changes = data.map((final json) => FileChange.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'action': action,
        'originalFilePath': originalFilePath,
        'isAddition': isAddition,
      };

  static FileChange fromJson(final Map<String, dynamic> json) {
    return FileChange(
      json['filePath'],
      json['action'],
      json['isAddition'] ?? false,
      json['originalFilePath'],
    );
  }

  static Future<void> savePreRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    var bufferTime = const Duration(minutes: 60);
    var preRandomizationTime = DateTime.now().subtract(bufferTime);
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(preRandomizationTime);
    await prefs.setString('pre_randomization_time', formattedTime);
    if (kDebugMode) {
      LogState().addLog("Pre-modification time saved: $formattedTime");
    }
  }

  static Future<void> saveLastRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);
    await prefs.setString('last_randomization_time', formattedTime);
    if (kDebugMode) {
      LogState().addLog("Last modification time saved: $formattedTime");
    }
  }

  static Future<DateTime> getPreRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedTime = prefs.getString('pre_randomization_time') ??
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      DateTime parsedTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedTime);
      return parsedTime;
    } catch (e) {
      if (kDebugMode) {
        LogState().addLog('Error parsing pre-modification time: $e');
      }
      return DateTime.now();
    }
  }

  static String formatKey(final String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((final word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static Future<void> deleteAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    bool undoPossible = true;

    for (String key in keys) {
      bool result = await prefs.remove(key);
      String formattedKey = formatKey(key);
      globalLog(
          '$formattedKey: ${result ? "Successfully deleted." : "Failed to delete."}');
      if (key == 'file_changes' && result) {
        undoPossible = false;
      }
    }

    bool allCleared = await prefs.clear();
    globalLog(
        'All data cleared and state removed: ${allCleared ? "Yes" : "Failed to clear all data."}');

    if (!undoPossible) {
      globalLog(
          'Undo functionality is no longer up to date as "File Changes" data has been deleted.');
    }
  }

  static Future<void> loadDLCOption(final WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    bool hasDLC = prefs.getBool('dlc') ?? false;
    ref.watch(globalStateProvider.notifier).updateDLCOption(update: hasDLC);
  }

  static Future<void> saveDLCOption(final WidgetRef ref,
      {required final bool shouldSave}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dlc', shouldSave);
    ref.watch(globalStateProvider.notifier).updateDLCOption(update: shouldSave);
  }

  static Future<Map<String, dynamic>> getPathsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final input = prefs.getString('input') ?? '';
    final output = prefs.getString('output') ?? '';
    final savePaths = prefs.getBool('savePaths') ?? false;

    return {
      'input': input,
      'output': output,
      'savePaths': savePaths,
    };
  }

  static Future<bool> getPathsPresence() async {
    final prefs = await SharedPreferences.getInstance();
    final inputPresent = prefs.containsKey('input') &&
        (prefs.getString('input') ?? '').isNotEmpty;
    final outputPresent = prefs.containsKey('output') &&
        (prefs.getString('output') ?? '').isNotEmpty;
    final savePathsPresent =
        prefs.containsKey('savePaths') && prefs.getBool('savePaths') == true;

    return inputPresent && outputPresent && savePathsPresent;
  }
}
