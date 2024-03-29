import 'dart:convert';
import 'dart:io';
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
    print('Saved ignoredFiles: $jsonData');
  }

  static Future<void> loadIgnoredFiles() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = prefs.getString('ignored_files') ?? '[]';
    ignoredFiles = List<String>.from(jsonDecode(jsonData));
    print('Loaded ignoredFiles: $ignoredFiles');
  }

  static Future<void> removeIgnoreFiles(List<String> filesToRemove) async {
    await loadIgnoredFiles();
    ignoredFiles.removeWhere((file) => filesToRemove.contains(file));
    await saveIgnoredFiles();
    print('Removed files and updated ignoredFiles');
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
          print('Error during undoing change for ${change.filePath}: $e');
        }
      }
    }
    changes.clear();
  }

  static Future<void> saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(changes.map((c) => c.toJson()).toList());
    await prefs.setString('file_changes', jsonData);
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
      print("Pre-randomization time saved: $formattedTime");
    }
  }

  static Future<void> saveLastRandomizationTime() async {
    final prefs = await SharedPreferences.getInstance();
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);
    await prefs.setString('last_randomization_time', formattedTime);
    if (kDebugMode) {
      print("Last randomization time saved: $formattedTime");
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
        print(
            "Loaded pre-randomization time from SharedPreferences: $parsedTime");
      }
      return parsedTime;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing pre-randomization time: $e');
      }
      return DateTime.now();
    }
  }
}
