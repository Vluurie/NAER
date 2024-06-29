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

  static Widget logIcon(AnimationController blinkController,
      VoidCallback scrollToSetup, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: "Jump to Log Output",
          icon: AnimatedBuilder(
            animation: blinkController,
            builder: (context, child) {
              final color = ColorTween(
                begin: AutomatoThemeColors.darkBrown(ref),
                end: AutomatoThemeColors.saveZone(ref),
              ).animate(blinkController).value;
              return Icon(Icons.terminal, size: 32.0, color: color);
            },
          ),
          hoverColor: AutomatoThemeColors.brown15(ref),
          onPressed: scrollToSetup,
        ),
      ],
    );
  }
}
