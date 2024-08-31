import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SnackBarType { success, failure, info }

class SnackBarHandler {
  SnackBarHandler._();

  static void showSnackBar(final BuildContext context, final WidgetRef ref,
      final String message, final SnackBarType type) {
    ScaffoldMessenger.of(context).clearSnackBars();

    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_circle;
        iconColor = AutomatoThemeColors.saveZone(ref);
        backgroundColor = AutomatoThemeColors.darkBrown(ref);
        break;
      case SnackBarType.failure:
        iconData = Icons.error;
        iconColor = AutomatoThemeColors.dangerZone(ref);
        backgroundColor = AutomatoThemeColors.darkBrown(ref);
        break;
      case SnackBarType.info:
      default:
        iconData = Icons.info;
        iconColor = AutomatoThemeColors.bright(ref);
        backgroundColor = AutomatoThemeColors.brown(ref);
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            iconData,
            color: iconColor,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AutomatoThemeColors.textColor(ref),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: AutomatoThemeColors.bright(ref),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
