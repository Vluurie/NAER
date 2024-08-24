import 'package:NAER/naer_ui/appbar/informationdialog.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppIcons {
  static Widget informationIcon(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: "Information",
          icon: const Icon(Icons.info, size: 32.0),
          color: AutomatoThemeColors.darkBrown(ref),
          onPressed: () => showInformationDialog(context, ref),
        ),
      ],
    );
  }
}
