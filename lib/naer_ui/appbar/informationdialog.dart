import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showInformationDialog(BuildContext context, WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "Information",
    content: Text(
      "Thank you for using this tool! It is provided free of charge and developed in my personal time."
      "\n\nIf you encounter any issues or have questions, feel free to ask in the Nier Modding community!"
      "\n\nSpecial thanks to RaiderB with his NieR CLI and the entire mod community for making this possible.",
      style: TextStyle(
          color: AutomatoThemeColors.textDialogColor(ref), fontSize: 20),
    ),
    onOkPressed: () => Navigator.of(context).pop(),
    okLabel: 'Close',
  );
}
