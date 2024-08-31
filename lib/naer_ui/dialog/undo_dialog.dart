import 'dart:async';
import 'package:NAER/naer_utils/undo.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> showUndoConfirmation(
    final BuildContext context, final WidgetRef ref,
    {required final bool isAddition}) {
  Completer<bool> completer = Completer<bool>();

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    title: 'Confirm Undo',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remove this modification?',
          style: TextStyle(
            color: AutomatoThemeColors.textDialogColor(ref),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
    onYesPressed: () async {
      unawaited(showDialog(
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) {
          return Center(
            child: AutomatoLoading(
              color: AutomatoThemeColors.bright(ref),
              translateX: 0,
              svgString: AutomatoSvgStrings.automatoSvgStrHead,
            ),
          );
        },
      ));

      await removeModificationWithIndicator(ref, isAddition: isAddition);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      completer.complete(true);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    },
    onNoPressed: () {
      completer.complete(false);
      Navigator.of(context).pop();
    },
    ref: ref,
  );

  return completer.future;
}
