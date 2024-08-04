import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_service.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

AutomatoButton navigateButton(
    BuildContext context, ScrollController scrollController, WidgetRef ref) {
  final globalState = provider.Provider.of<GlobalState>(context, listen: false);
  final globalStateRiverPod = ref.watch(globalStateProvider);
  return AutomatoButton(
    label: 'Mod Manager',
    uniqueId: 'modManagerButton',
    showPointer: false,
    maxScale: 0.9,
    baseColor: AutomatoThemeColors.darkBrown(ref),
    activeFillColor: AutomatoThemeColors.primaryColor(ref),
    fillBehavior: FillBehavior.filledRightToLeft,
    onPressed: () async {
      CLIArguments cliArgs = await gatherCLIArguments(
          context: context,
          scrollController: scrollController,
          selectedImages: globalStateRiverPod.selectedImages,
          categories: globalStateRiverPod.categories,
          level: globalStateRiverPod.level,
          ignoredModFiles: globalState.ignoredModFiles,
          input: globalState.input,
          specialDatOutputPath: globalState.specialDatOutputPath,
          scriptPath: globalState.scriptPath,
          enemyStats: globalStateRiverPod.enemyStats,
          enemyLevel: globalStateRiverPod.enemyLevel,
          ref: ref);

      final modInstallHandler = ModInstallHandler(cliArgs);
      ModStateManager modStateManager =
          ModStateManager(ModService(), modInstallHandler);

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                provider.ChangeNotifierProvider<ModStateManager>(
              create: (_) => modStateManager,
              child: SecondPage(cliArguments: cliArgs),
            ),
          ),
        );
      }
    },
  );
}

class Widgetref {}
