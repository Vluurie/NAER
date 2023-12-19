import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ModFileUtils {
  static Future<List<String>> findModFiles(String outputDirectory) async {
    List<String> modFiles = [];
    DateTime preRandomizationTime = await _getPreRandomizationTime();

    try {
      var directory = Directory(outputDirectory);
      if (await directory.exists()) {
        await for (FileSystemEntity entity in directory.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dat')) {
            var fileModTime = await entity.lastModified();
            var fileName = path.basename(entity.path);
            if (fileModTime.isBefore(preRandomizationTime)) {
              modFiles.add(fileName);
            }
          }
        }
      }
    } catch (e) {
      // Handle exceptions
    }

    return modFiles;
  }

  static Future<DateTime> _getPreRandomizationTime() async {
    var preRandomizationFile = File('pre_randomization_time.json');
    if (await preRandomizationFile.exists()) {
      var content = await preRandomizationFile.readAsString();
      var preRandomizationData = jsonDecode(content);
      return DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(preRandomizationData['pre_randomization_time']);
    }
    return DateTime.now();
  }

  static Future<void> showModsMessage(
      BuildContext context, List<String> modFiles,
      [Function(List<String>)? onModFilesUpdated]) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mod Files Detected"),
          content: Container(
            width: double.maxFinite,
            child: modFiles.isNotEmpty
                ? ListView.builder(
                    itemCount: modFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(modFiles[index]),
                        subtitle: const Text('Ignored during randomization'),
                      );
                    },
                  )
                : const Text('No mod files found'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
