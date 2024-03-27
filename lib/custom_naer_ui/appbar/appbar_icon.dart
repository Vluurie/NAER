import 'package:NAER/custom_naer_ui/appbar/informationdialog.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppIcons {
  static Widget informationIcon(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.info, size: 32.0),
          color: const Color.fromRGBO(49, 217, 240, 1),
          onPressed: () => showInformationDialog(context),
        ),
        const Text('Information', style: TextStyle(fontSize: 10.0)),
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
                begin: const Color.fromARGB(31, 206, 198, 198),
                end: const Color.fromARGB(255, 86, 244, 54),
              ).animate(blinkController).value;
              return Icon(Icons.terminal, size: 32.0, color: color);
            },
          ),
          onPressed: scrollToSetup,
        ),
        const Text('Log', style: TextStyle(fontSize: 10.0)),
      ],
    );
  }

  static Widget windowControls() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.minimize),
          onPressed: () async => await windowManager.minimize(),
          tooltip: 'Minimize',
        ),
        IconButton(
          icon: const Icon(Icons.crop_square),
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.restore();
            } else {
              await windowManager.maximize();
            }
          },
          tooltip: 'Maximize/Restore',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async => await windowManager.close(),
          tooltip: 'Close',
        ),
      ],
    );
  }
}
