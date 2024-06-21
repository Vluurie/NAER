import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';

void changeAppThemePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Change App Theme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('NieR Theme (Default)'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToDefaultTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Angel Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToAngelTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Cyberpunk Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToCyberpunkTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Danger Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToDangerTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Desert Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToDesertTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Floral Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToFloralTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Futuristic Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToFuturisticTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Ice Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToIceTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Lava Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToLavaTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Neon Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToNeonTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Nightmare Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToNightmareTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Pastel Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToPastelTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Retro Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToRetroTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Steampunk Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToSteampunkTheme();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Sunset Theme'),
                onTap: () {
                  Provider.of<AutomatoThemeNotifier>(context, listen: false)
                      .switchToSunsetTheme();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
