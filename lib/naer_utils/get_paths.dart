import 'dart:io';

import 'package:flutter/material.dart';

void getOutputPath(final BuildContext context, String outputPath) async {
  if (outputPath.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Output path is empty')),
    );
    return;
  }

  outputPath = outputPath.replaceAll('"', '');

  if (!await Directory(outputPath).exists()) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Path does not exist: $outputPath')),
      );
    }
    return;
  }

  if (Platform.isWindows) {
    await Process.run('explorer', [outputPath]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [outputPath]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [outputPath]);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Opening output path is not supported on this platform.')),
      );
    }
  }
}

void getNaerSettings(final BuildContext context) async {
  String settingsDirectoryPath = await ensureSettingsDirectory();

  if (Platform.isWindows) {
    await Process.run('cmd', ['/c', 'start', '', settingsDirectoryPath]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [settingsDirectoryPath]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [settingsDirectoryPath]);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Opening output path is not supported on this platform.'),
        ),
      );
    }
  }
}

Future<String> ensureSettingsDirectory() async {
  var exeDirectory = File(Platform.resolvedExecutable).parent.path;
  final settingsDirectory = Directory('$exeDirectory/NAER_Settings');
  if (!await settingsDirectory.exists()) {
    await settingsDirectory.create(recursive: true);
  }
  return settingsDirectory.path;
}
