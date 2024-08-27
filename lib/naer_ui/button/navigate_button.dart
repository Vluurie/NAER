import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_service.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';

import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

AutomatoButton navigateButton(final BuildContext context, final WidgetRef ref) {
  return AutomatoButton(
    label: 'Mod Manager',
    uniqueId: 'modManagerButton',
    showPointer: false,
    maxScale: 0.9,
    baseColor: AutomatoThemeColors.darkBrown(ref),
    activeFillColor: AutomatoThemeColors.primaryColor(ref),
    fillBehavior: FillBehavior.filledRightToLeft,
    onPressed: () async {
      CLIArguments cliArgs = await getGlobalArguments(ref);

      final modInstallHandler = ModInstallHandler(cliArgs);
      ModStateManager modStateManager =
          ModStateManager(ModService(), modInstallHandler);

      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (final context) =>
                provider.ChangeNotifierProvider<ModStateManager>(
              create: (final _) => modStateManager,
              child: SecondPage(cliArguments: cliArgs),
            ),
          ),
        );
      }
    },
  );
}

class Widgetref {}
