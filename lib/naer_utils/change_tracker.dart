import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileChange {
  String filePath;
  String action;
  String? originalFilePath;

  FileChange(this.filePath, this.action, [this.originalFilePath]);

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

  static void logChange(String filePath, String action,
      [String? originalFilePath]) {
    changes.add(FileChange(filePath, action, originalFilePath));
  }

  static Future<void> saveIgnoredFiles() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(ignoredFiles);
    await prefs.setString('ignored_files', jsonData);
  }

  static Future<void> loadIgnoredFiles() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('ignored_files') ?? '[]';
    ignoredFiles = List<String>.from(jsonDecode(jsonData));
    // print('Loaded ignoredFiles: $ignoredFiles');
  }

  static Future<void> removeIgnoreFiles(List<String> filesToRemove) async {
    await loadIgnoredFiles();
    ignoredFiles.removeWhere((file) => filesToRemove.contains(file));
    await saveIgnoredFiles();
    //print('Removed files and updated ignoredFiles');
  }

  static Future<void> undoChanges() async {
    for (FileChange change in changes.reversed) {
      try {
        if (change.action == 'create' &&
            !ignoredFiles.contains(change.filePath)) {
          var file = File(change.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } else if (change.action == 'modify' &&
            change.originalFilePath != null) {
          var originalFile = File(change.originalFilePath!);
          await originalFile.copy(change.filePath);
        } else if (change.action == 'delete') {
          // ...
        }
      } catch (e) {
        if (kDebugMode) {
          LogState()
              .addLog('Error during undoing change for ${change.filePath}: $e');
        }
      }
    }
    changes.clear();
  }

  static Future<void> saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(changes.map((c) => c.toJson()).toList());
    await prefs.setString('file_changes', jsonData);
    //print("Saved changed $changes");
  }

  static Future<void> loadChanges() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('file_changes') ?? '[]';
    List<dynamic> data = jsonDecode(jsonData);
    changes = data.map((json) => FileChange.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'action': action,
        'originalFilePath': originalFilePath,
      };

  static FileChange fromJson(Map<String, dynamic> json) {
    return FileChange(
      json['filePath'],
      json['action'],
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
      LogState().addLog("Pre-randomization time saved: $formattedTime");
    }
  }

  static Future<void> saveLastRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);
    await prefs.setString('last_randomization_time', formattedTime);
    if (kDebugMode) {
      LogState().addLog("Last randomization time saved: $formattedTime");
    }
  }

  static Future<DateTime> getPreRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    String formattedTime = prefs.getString('pre_randomization_time') ??
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      DateTime parsedTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedTime);
      if (kDebugMode) {
        // print(
        //     "Loaded pre-randomization time from SharedPreferences: $parsedTime");
      }
      return parsedTime;
    } catch (e) {
      if (kDebugMode) {
        LogState().addLog('Error parsing pre-randomization time: $e');
      }
      return DateTime.now();
    }
  }

  static Future<void> deleteAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // print('All Shared Preferences:');
    prefs.getKeys().forEach((key) {
      var value = prefs.clear();
      globalLog('$key: $value');
    });
  }

  static Future<void> loadDLCOption(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    bool hasDLC = prefs.getBool('dlc') ?? false;
    ref.read(globalStateProvider.notifier).updateDLCOption(hasDLC);
  }

  static Future<void> saveDLCOption(WidgetRef ref, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dlc', value);
    ref.read(globalStateProvider.notifier).updateDLCOption(value);
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
