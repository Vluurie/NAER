import 'package:NAER/naer_ui/appbar/informationdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';

class AppIcons {
  static Widget informationIcon(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.info, size: 32.0),
          color: AutomatoThemeColors.darkBrown(context),
          onPressed: () => showInformationDialog(context),
        ),
      ],
    );
  }

  static Widget logIcon(
      AnimationController blinkController, VoidCallback scrollToSetup) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: AnimatedBuilder(
            animation: blinkController,
            builder: (context, child) {
              final color = ColorTween(
                begin: AutomatoThemeColors.darkBrown(context),
                end: AutomatoThemeColors.saveZone(context),
              ).animate(blinkController).value;
              return Icon(Icons.terminal, size: 32.0, color: color);
            },
          ),
          onPressed: scrollToSetup,
        ),
      ],
    );
  }
}
