import 'dart:io';
import 'dart:isolate';

import 'package:NAER/naer_cli/console_service.dart';
import 'package:NAER/naer_cli/handle_guided_argument.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:NAER/nier_cli/nier_cli_isolation.dart';
import 'package:flutter/foundation.dart';

void handleCommandLineExecution(List<String> arguments) async {
  bool isBalanceMode = false;
  bool hasDLC = false;
  bool backUp = false;
  bool guided = arguments.contains('--guided');

  // // Test mode: predefined arguments
  // if (arguments.isEmpty) {
  //   arguments = [
  //     r'D:\SteamLibrary\steamapps\common\NieRAutomata\data',
  //     '--output',
  //     r'D:\SteamLibrary\steamapps\common\NieRAutomata\data',
  //     'ALL',
  //     '--enemies',
  //     '[em3000]',
  //     '--enemyStats',
  //     '5.0',
  //     '--level=99',
  //     '--p100',
  //     '--category=allenemies',
  //     '--backUp',
  //   ];
  //   print('test arguments: $arguments');
  // }

  if (guided) {
    List<String> guidedArgs = await guidedMode();
    arguments = guidedArgs;
  }

  // Process the arguments
  if (arguments.isNotEmpty) {
    for (String arg in arguments) {
      if (arg == '--balance') {
        isBalanceMode = true;
      } else if (arg == '--dlc') {
        hasDLC = true;
      } else if (arg == '--backUp') {
        backUp = true;
      }
    }

    final receivePort = ReceivePort();
    final cmh = ConsoleMessageHandler();
    cmh.listenToReceivePort(receivePort);
    Map<String, dynamic> args = {
      'processArgs': arguments,
      'isManagerFile': false,
      'sendPort': receivePort.sendPort,
      'isBalanceMode': isBalanceMode,
      'hasDLC': hasDLC,
      'backUp': backUp,
      'isAddition': false,
    };

    await compute(runNierCliIsolated, args);
    cmh.printAsciiMessage("Cleaning Input: ${arguments[0]}");
    await deleteExtractedGameFolders(arguments[0]);
    cmh.printAsciiMessage('''
                                                                                                                                       
                  All modifications were successfully completed!
  ''');
    exit(0);
  }
}
