import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showNierIsRunningDialog(BuildContext context, WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: 'NieR:Automata is currently running.',
    content: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: AutomatoThemeColors.textDialogColor(ref),
          fontSize: 22,
        ),
        children: const [
          TextSpan(
            text:
                'NAER has detected that NieR:Automata is already running. As this tool does not operate in memory, the game must be closed and the files must be modified before NieR:Automata reads the modified files.\n\n',
          ),
          TextSpan(
            text: 'ヽ(｀Д´)ﾉ Sorry',
            style: TextStyle(
              fontSize: 38,
            ),
          ),
        ],
      ),
    ),
    onOkPressed: () {
      Navigator.of(context).pop();
    },
    okLabel: "Ok",
  );
}
