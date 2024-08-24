import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void onCopyArgsPressed(BuildContext context, WidgetRef ref) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final globalState = ref.watch(globalStateProvider);

    if (globalState.customSelection) {
      _performCopyCLIArguments(context, ref);
    } else {
      try {
        final selectedSetup = SetupData.getCurrentSelectedSetup();
        if (selectedSetup.isSelected) {
          final arguments = selectedSetup.generateArguments(ref);
          copyToClipboard(arguments, context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No setup is currently selected.')),
        );
      }
    }
  });
}

Future<void> _performCopyCLIArguments(
  BuildContext context,
  WidgetRef ref,
) async {
  final globalState = ref.watch(globalStateProvider);
  try {
    if (globalState.input.isEmpty || globalState.specialDatOutputPath.isEmpty) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      return;
    }

    CLIArguments cliArgs = await getGlobalArguments(ref);

    if (context.mounted) {
      List<String> command = cliArgs.fullCommand;
      List<String> copiedCommand = copyToClipboard(command, context);
      globalLog("Copied Command List: $copiedCommand");
    }
  } catch (e) {
    if (context.mounted) {
      globalLog("Error gathering CLI arguments: $e");
    }
  }
}

List<String> copyToClipboard(List<String> command, BuildContext context) {
  //String commandString = command.join(' ');
  String formattedCommand = command.map((cmd) => '"$cmd"').toList().toString();

  Clipboard.setData(ClipboardData(text: formattedCommand)).then((result) {
    const snackBar = SnackBar(content: Text('Command copied to clipboard'));
    globalLog("Copied Command List: $formattedCommand");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }).catchError((e) {
    globalLog("Error copying to clipboard: $e");
  });

  // Return the original command list
  return command;
}
