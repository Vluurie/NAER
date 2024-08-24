import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showCompletionDialog(
    BuildContext context, WidgetRef ref, String directoryPath) {
  final globalState = ref.read(globalStateProvider.notifier);
  globalState.setIsLoading(false);

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    title: 'Modification Complete',
    content: Text(
      'Modification process completed successfully.',
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 18,
      ),
    ),
    yesLabel: "Play now!",
    noLabel: 'Close',
    onYesPressed: () async {
      globalState.setIsLoading(true);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            onPopInvokedWithResult: (canPop, result) async {},
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: AutomatoLoading(
                    color: AutomatoThemeColors.bright(ref),
                    translateX: 0,
                    svgString: AutomatoSvgStrings.automatoSvgStrHead,
                  ),
                ),
              ),
            ),
          );
        },
      );

      try {
        bool isClean = await validateExtractedFolderDeletion(directoryPath);
        if (isClean) {
          void onNierAutomataStopped() {
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }

          await startNierAutomataExecutable(
              directoryPath, onNierAutomataStopped);
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            showErrorDialog(
                context,
                ref,
                'Extracted folder deletion is still in process... Retry in a few seconds...',
                directoryPath);
          }
        }
      } catch (e) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          showErrorDialog(
            context,
            ref,
            e.toString(),
            directoryPath,
          );
        }
      } finally {
        globalState.setIsLoading(false);
      }
    },
    onNoPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    },
  );
}

void showErrorDialog(BuildContext context, WidgetRef ref, String errorMessage,
    String directoryPath) {
  final globalState = ref.read(globalStateProvider.notifier);
  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    title: 'Is this a curse or some kind of punishment?',
    content: Text(
      'Stopped starting Nier: Automata.\nError: $errorMessage',
      style: TextStyle(
        color: AutomatoThemeColors.textDialogColor(ref),
        fontSize: 18,
      ),
    ),
    yesLabel: "Retry",
    noLabel: 'Close',
    onYesPressed: () async {
      try {
        bool isClean = await validateExtractedFolderDeletion(directoryPath);
        if (isClean) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();

            void onNierAutomataStopped() {
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }

            await startNierAutomataExecutable(
                directoryPath, onNierAutomataStopped);
          }
        } else {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();

            showErrorDialog(
              context,
              ref,
              'Extracted folder deletion is still in process... Retry in a few seconds...',
              directoryPath,
            );
          }
        }
      } catch (e) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();

          showErrorDialog(context, ref, e.toString(), directoryPath);
        }
      } finally {
        globalState.setIsLoading(false);
      }
    },
    onNoPressed: () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    },
  );
}
