import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogState with ChangeNotifier {
  static final LogState _instance = LogState._internal();

  factory LogState() {
    return _instance;
  }

  LogState._internal();

  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void addLog(final String log) {
    _logs.add(log);
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await Future(() {
      _logs.clear();
      notifyListeners();
    });
  }

  static String processLog(final String log) {
    return log;
  }

  static List<String> getGlobalLogs() {
    return _instance._logs;
  }

  static void logError(final String error, final StackTrace stackTrace) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '[$timestamp] Error: $error\nStack trace:\n$stackTrace\n';

    globalLog(logMessage);

    try {
      final logFile = File('log.txt');
      await logFile.writeAsString(logMessage, mode: FileMode.append);
    } catch (e) {
      globalLog('Failed to write to log.txt: $e');
    }
  }
}

final logsProvider =
    FutureProvider<List<Map<String, dynamic>>>((final ref) async {
  final logFilePath = 'logs.json';
  final file = File(logFilePath);

  if (!await file.exists()) {
    return [];
  }

  final jsonString = await file.readAsString();

  try {
    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is List) {
      // JSON contains a list of logs
      return decodedJson.map((final log) {
        return {
          "DateTime": log["DateTime"] ?? "Unknown",
          "Exception": log["Exception"] ?? "Unknown",
          "Extra Message": log["Extra Message"] ?? "",
          "Method": log["Method"] ?? "Unknown",
          "File": log["File"] ?? "Unknown",
          "Line": log["Line"]?.toString() ?? "Unknown",
          "Column": log["Column"]?.toString() ?? "Unknown",
          "StackTrace": log["StackTrace"] ?? "",
        };
      }).toList();
    } else if (decodedJson is Map) {
      // JSON contains a single log
      return [
        {
          "DateTime": decodedJson["DateTime"] ?? "Unknown",
          "Exception": decodedJson["Exception"] ?? "Unknown",
          "Extra Message": decodedJson["Extra Message"] ?? "",
          "Method": decodedJson["Method"] ?? "Unknown",
          "File": decodedJson["File"] ?? "Unknown",
          "Line": decodedJson["Line"]?.toString() ?? "Unknown",
          "Column": decodedJson["Column"]?.toString() ?? "Unknown",
          "StackTrace": decodedJson["StackTrace"] ?? "",
        }
      ];
    } else {
      throw Exception("Unexpected JSON format");
    }
  } catch (e) {
    print("Error parsing logs: $e");
    return [];
  }
});
