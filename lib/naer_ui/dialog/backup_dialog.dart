import 'dart:async';

import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_paths.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showBackupDialog(
    final BuildContext context, final WidgetRef ref) async {
  final globalState = ref.watch(globalStateProvider.notifier);
  String outputDir = path.dirname(globalState.readInput());

  bool extractionExist = await checkIfExtractedFoldersExist(outputDir);

  if (!extractionExist) {
    final Completer<bool> completer = Completer<bool>();

    if (context.mounted) {
      unawaited(showDialog<void>(
        context: context,
        barrierColor: AutomatoThemeColors.transparentColor(ref),
        builder: (final BuildContext dialogContext) {
          WidgetsBinding.instance.addPostFrameCallback((final _) {
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
                globalState.setIsExtractCopyEnabled(isExtractCopyEnabled: true);
                completer.complete(true);
                Navigator.of(dialogContext).pop();
              },
              onNoPressed: () {
                globalState.setIsExtractCopyEnabled(
                    isExtractCopyEnabled: false);
                completer.complete(false);
                Navigator.of(dialogContext).pop();
              },
            );
          });

          return Container();
        },
      ).then((final _) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }));
    }

    return completer.future;
  } else {
    return Future.value(false);
  }
}
