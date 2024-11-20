import 'dart:async';
import 'dart:io';

import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/state_provider/dll_download_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void showNierIsRunningDialog(final BuildContext context, final WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: 'NieR:Automata is currently running.',
    content: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: AutomatoThemeColors.textDialogColor(ref),
          fontSize: 22,
        ),
        children: const [
          TextSpan(
            text:
                'NAER has detected that NieR:Automata is already running. As this tool does not operate in memory, the game must be closed and the files must be modified before NieR:Automata reads the modified files.\n\n',
          ),
          TextSpan(
            text: 'ヽ(｀Д´)ﾉ Sorry',
            style: TextStyle(
              fontSize: 38,
            ),
          ),
        ],
      ),
    ),
    onOkPressed: () {
      Navigator.of(context).pop();
    },
    okLabel: "Ok",
  );
}

void showDllDoesNotExistDialog(
    final BuildContext context, final WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: 'The DLL is missing.',
    content: _DllLinkWithHover(ref: ref),
    onOkPressed: () async {
      var exeDir = File(Platform.resolvedExecutable).parent.path;
      await Process.run('explorer', [exeDir]);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    },
    okLabel: "Ok and open NAER directory",
  );
}

class _DllLinkWithHover extends ConsumerWidget {
  const _DllLinkWithHover({required final WidgetRef ref});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final downloadState = ref.watch(downloadProvider);
    final downloadNotifier = ref.read(downloadProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 22,
            ),
            children: [
              const TextSpan(
                text:
                    "NAER has detected that the DLL for extracting the Game Files does not exist in NAER's directory path. Ensure you have the file ",
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              try {
                await downloadNotifier.downloadDll();
                if (context.mounted) {
                  unawaited(showDialog(
                    context: context,
                    builder: (final context) => AlertDialog(
                      title: const Text("Download Complete"),
                      content: const Text(
                          "extract_dat_files.dll has been downloaded."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  ));
                }
              } catch (e, stackTrace) {
                ExceptionHandler().handle(
                  e,
                  stackTrace,
                  extraMessage: 'Failed to download DLL',
                );

                if (context.mounted) {
                  unawaited(showDialog(
                    context: context,
                    builder: (final context) => AlertDialog(
                      title: const Text("Error"),
                      content: Text(
                          "Failed to download DLL. Check log.txt for details."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  ));
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: downloadState.isDownloading
                    ? Colors.blue.shade200
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    downloadState.isDownloading
                        ? 'Downloading... ${(downloadState.progress * 100).toStringAsFixed(0)}%'
                        : 'Download extract_dat_files.dll',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (downloadState.isDownloading)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(value: downloadState.progress),
          ),
        const SizedBox(height: 16),
        Text(
          'ヽ(｀Д´)ﾉ Sorry',
          style: TextStyle(
            fontSize: 38,
            color: AutomatoThemeColors.textDialogColor(ref),
          ),
        ),
      ],
    );
  }
}
