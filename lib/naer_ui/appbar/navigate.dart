import 'package:NAER/naer_mod_manager/mod_manager.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Navigation {
  Future<ElevatedButton> navigateButton(
      BuildContext context, CLIArguments cliArguments) async {
    return ElevatedButton(
      onPressed: () {
        print(cliArguments);
        ModInstallHandler modInstallHandler =
            ModInstallHandler(cliArguments: cliArguments);
        ModStateManager modStateManager = ModStateManager(modInstallHandler);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<ModStateManager>(
              create: (_) => modStateManager,
              child: SecondPage(cliArguments: cliArguments),
            ),
          ),
        );
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
}
