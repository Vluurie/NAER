import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void onCopyArgsPressed(final BuildContext context, final WidgetRef ref) {
  WidgetsBinding.instance.addPostFrameCallback((final _) {
    final globalState = ref.watch(globalStateProvider);

    if (globalState.customSelection) {
      _performCopyCLIArguments(context, ref);
    } else {
      try {
        final selectedSetup =
            ref.read(setupConfigProvider.notifier).getCurrentSelectedSetup();
        if (selectedSetup != null && selectedSetup.isSelected) {
          final arguments = selectedSetup.generateArguments(ref);
          copyToClipboard(arguments, context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No setup is currently selected.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error occurred while copying arguments.')),
        );
      }
    }
  });
}

Future<void> _performCopyCLIArguments(
  final BuildContext context,
  final WidgetRef ref,
) async {
  final globalState = ref.watch(globalStateProvider);
  try {
    if (globalState.input.isEmpty || globalState.specialDatOutputPath.isEmpty) {
      globalLog("Error: Please select both input and output directories. 💋 ");
      return;
    }

    CLIArguments cliArgs = await getGlobalArguments(ref);

    if (context.mounted) {
      copyToClipboard(cliArgs.fullCommand, context);
    }
  } catch (e) {
    if (context.mounted) {
      globalLog("Error gathering CLI arguments: $e");
    }
  }
}

void copyToClipboard(final List<String> command, final BuildContext context) {
  String formattedCommand = command.map((final cmd) {
    if (cmd.contains('=') && (cmd.contains('[') && cmd.contains(']'))) {
      return cmd
          .replaceAll(' ', '')
          .replaceAll('",', '",')
          .replaceAll("'", '"');
    } else {
      return cmd.startsWith('"') && cmd.endsWith('"') ? cmd : '"$cmd"';
    }
  }).join(' ');

  Clipboard.setData(ClipboardData(text: formattedCommand)).then((final result) {
    const snackBar = SnackBar(content: Text('Command copied to clipboard'));
    globalLog("Copied Command: $formattedCommand");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }).catchError((final e) {
    globalLog("Error copying to clipboard: $e");
  });
}
