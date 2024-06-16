import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

ElevatedButton navigateButton(
    BuildContext context, ScrollController scrollController) {
  final globalState = Provider.of<GlobalState>(context, listen: false);
  return ElevatedButton(
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
    style: ElevatedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 45, 45, 48),
      backgroundColor: const Color.fromARGB(255, 28, 31, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
    ),
    child: const Text(
      'Mod Manager',
      style: TextStyle(
        fontSize: 16.0,
        color: Color.fromRGBO(0, 255, 255, 1),
      ),
    ),
  );
}
