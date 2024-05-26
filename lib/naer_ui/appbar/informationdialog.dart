import 'package:flutter/material.dart';

void showInformationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const InformationDialog();
    },
  );
}

class InformationDialog extends StatelessWidget {
  const InformationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Information"),
      content: const Text(
        "Thank you for using this tool! It is provided free of charge and developed in my personal time."
        "\n\nIf you encounter any issues or have questions, feel free to ask in the Nier Modding community!"
        ".\n\nSpecial thanks to RaiderB with his NieR CLI and the entire mod community for making this possible.",
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
