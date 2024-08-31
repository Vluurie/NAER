import 'dart:io';

import 'package:NAER/naer_ui/setup/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void getOutputPath(
    final BuildContext context, final WidgetRef ref, String outputPath) async {
  if (outputPath.isEmpty) {
    SnackBarHandler.showSnackBar(
      context,
      ref,
      'Output path is empty',
      SnackBarType.failure,
    );

    return;
  }

  outputPath = outputPath.replaceAll('"', '');

  if (!await Directory(outputPath).exists()) {
    if (context.mounted) {
      SnackBarHandler.showSnackBar(
        context,
        ref,
        'Path does not exist: $outputPath',
        SnackBarType.info,
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
      SnackBarHandler.showSnackBar(
        context,
        ref,
        'Opening output path is not supported on this platform.',
        SnackBarType.failure,
      );
    }
  }
}

void getNaerSettings(final BuildContext context, final WidgetRef ref) async {
  String settingsDirectoryPath = await ensureSettingsDirectory();

  if (Platform.isWindows) {
    await Process.run('cmd', ['/c', 'start', '', settingsDirectoryPath]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [settingsDirectoryPath]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [settingsDirectoryPath]);
  } else {
    if (context.mounted) {
      SnackBarHandler.showSnackBar(
        context,
        ref,
        'Opening output path is not supported on this platform.',
        SnackBarType.failure,
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
