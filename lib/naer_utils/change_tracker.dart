import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

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
    // Get the directory of the executable
    var exeDirectory = File(Platform.resolvedExecutable).parent.path;

    // Construct the path to the NAER_Settings directory
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
    var settingsPath = await ensureSettingsDirectory();
    var file = File('$settingsPath/ignored_files.json');
    String jsonData = jsonEncode(ignoredFiles);
    await file.writeAsString(jsonData);
  }

  static Future<void> loadIgnoredFiles() async {
    var file = File('ignored_files.json');
    if (await file.exists()) {
      String jsonData = await file.readAsString();
      ignoredFiles = List<String>.from(jsonDecode(jsonData));
    }
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
    var settingsPath = await ensureSettingsDirectory();
    var file = File('$settingsPath/file_changes.json');
    String jsonData = jsonEncode(changes.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  static Future<void> loadChanges() async {
    var settingsPath = await ensureSettingsDirectory();
    var file = File('$settingsPath/file_changes.json');
    if (await file.exists()) {
      String jsonData = await file.readAsString();
      List<dynamic> data = jsonDecode(jsonData);
      changes = data.map((json) => FileChange.fromJson(json)).toList();
    }
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
    var bufferTime = const Duration(minutes: 60);
    var preRandomizationTime = DateTime.now().subtract(bufferTime);
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(preRandomizationTime);
    var preRandomizationData =
        jsonEncode({'pre_randomization_time': formattedTime});
    var settingsPath = await ensureSettingsDirectory();
    var file = File('$settingsPath/pre_randomization_time.json');
    await file.writeAsString(preRandomizationData);
    if (kDebugMode) {
      print("Pre-randomization time saved: $formattedTime");
    }
  }

  static Future<void> saveLastRandomizationTime() async {
    var lastRandomizationTime = DateTime.now();
    var formattedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(lastRandomizationTime);

    var lastRandomizationData =
        jsonEncode({'last_randomization_time': formattedTime});
    var settingsPath = await ensureSettingsDirectory();
    var file = File('$settingsPath/last_randomization_time.json');
    await file.writeAsString(lastRandomizationData);
  }

  static Future<DateTime> getPreRandomizationTime() async {
    var settingsPath = await ensureSettingsDirectory();
    var preRandomizationFile =
        File('$settingsPath/pre_randomization_time.json');
    try {
      if (await preRandomizationFile.exists()) {
        var content = await preRandomizationFile.readAsString();
        var preRandomizationData = jsonDecode(content);
        DateTime parsedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
            .parse(preRandomizationData['pre_randomization_time']);
        if (kDebugMode) {
          print("Loaded pre-randomization time from file: $parsedTime");
        }
        return parsedTime;
      } else {
        if (kDebugMode) {
          print("Pre-randomization time file does not exist.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading pre-randomization time: $e');
      }
    }
    if (kDebugMode) {
      print("Using current time as fallback for pre-randomization time.");
    }
    return DateTime.now();
  }
}
