import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';
import 'package:provider/provider.dart';

AutomatoButton navigateButton(
    BuildContext context, ScrollController scrollController) {
  final globalState = Provider.of<GlobalState>(context, listen: false);
  return AutomatoButton(
    label: 'Mod Manager',
    uniqueId: 'modManagerButton',
    onPressed: () async {
      CLIArguments cliArgs = await gatherCLIArguments(
        context: context,
        scrollController: scrollController,
        enemyImageGridKey: globalState.enemyImageGridKey,
        categories: globalState.categories,
        level: globalState.level,
        ignoredModFiles: globalState.ignoredModFiles,
        input: globalState.input,
        specialDatOutputPath: globalState.specialDatOutputPath,
        scriptPath: globalState.scriptPath,
        enemyStats: globalState.enemyStats,
        enemyLevel: globalState.enemyLevel,
      );

      ModInstallHandler modInstallHandler =
          ModInstallHandler(cliArguments: cliArgs);
      ModStateManager modStateManager = ModStateManager(modInstallHandler);

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ModStateManager>(
              create: (_) => modStateManager,
              child: SecondPage(cliArguments: cliArgs),
            ),
          ),
        );
      }
    },
    letterSpacing: 5.0,
    startColor: AutomatoThemeColors.primaryColor(context),
    activeFillColor: AutomatoThemeColors.darkBrown(context),
    startFontWeight: FontWeight.normal,
    endFontWeight: FontWeight.bold,
    fillBehavior: FillBehavior.filled,
    animationDuration: const Duration(milliseconds: 300),
    hoverBlinkDuration: const Duration(milliseconds: 600),
  );
}
