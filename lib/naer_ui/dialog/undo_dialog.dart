import 'dart:async';
import 'package:NAER/naer_utils/undo.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showUndoConfirmation(
    final BuildContext context, final WidgetRef ref) {
  Completer<bool> completer = Completer<bool>();

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    title: 'Confirm Undo',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you sure you want to undo your recent changes?',
          style: TextStyle(
            color: AutomatoThemeColors.textDialogColor(ref),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
    onYesPressed: () {
      undoLastModification(ref);
      completer.complete(true);
      Navigator.of(context).pop();
    },
    onNoPressed: () {
      completer.complete(false);
      Navigator.of(context).pop();
    },
    ref: ref,
  );

  return completer.future;
}
