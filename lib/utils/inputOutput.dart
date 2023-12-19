import 'dart:io';
import 'package:NAER/utils/modFileUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class InputOutputHandler {
  Future<String> openInputFileDialog(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      bool containsValidFiles = await _containsValidFiles(selectedDirectory);

      if (containsValidFiles) {
        return selectedDirectory;
      } else {
        await _showErrorDialog(context, "Invalid Directory",
            "The selected directory does not contain .cpk or .dat files.");
      }
    }
    return '';
  }

  Future<String> openOutputFileDialog(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      var modFiles = await ModFileUtils.findModFiles(selectedDirectory);
      if (modFiles.isNotEmpty) {
        await ModFileUtils.showModsMessage(context, modFiles);
        return selectedDirectory;
      } else {
        await _showErrorDialog(context, "No Mod Files",
            "No mod files were found in the selected directory.");
      }
      return selectedDirectory;
    }
    return '';
  }

  Future<bool> _containsValidFiles(String directoryPath) async {
    var directory = Directory(directoryPath);
    var files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        var extension = file.path.split('.').last;
        if (extension == 'cpk' || extension == 'dat') {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _showErrorDialog(
      BuildContext context, String title, String content) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
