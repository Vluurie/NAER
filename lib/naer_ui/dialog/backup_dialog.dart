import 'dart:async';

import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showBackupDialog(BuildContext context, WidgetRef ref) async {
  final globalState = ref.watch(globalStateProvider.notifier);
  String outputDir = path.dirname(globalState.readInput());

  bool extractionExist = checkIfExtractedFoldersExist(outputDir);

  if (!extractionExist) {
    final Completer<bool> completer = Completer<bool>();

    AutomatoDialogManager().showYesNoDialog(
      context: context,
      ref: ref,
      title: "Backup extracted files",
      content: Text(
        "Do you want to backup the extracted files, so you don't need to extract them a second time? This will take around 9GB of disk space.",
        style: TextStyle(
          color: AutomatoThemeColors.textDialogColor(ref),
          fontSize: 20,
        ),
      ),
      onYesPressed: () {
        globalState.setIsExtractCopyEnabled(true);
        completer.complete(true);
        Navigator.of(context).pop();
      },
      onNoPressed: () {
        globalState.setIsExtractCopyEnabled(false);
        completer.complete(false);
        Navigator.of(context).pop();
      },
      yesLabel: "Yes",
      noLabel: "No",
    );

    return completer.future;
  } else {
    return Future.value(false);
  }
}
