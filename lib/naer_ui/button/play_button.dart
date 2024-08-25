import 'dart:async';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlayButtonState {
  idle,
  loading,
  running,
}

class PlayButtonStateNotifier extends StateNotifier<PlayButtonState> {
  PlayButtonStateNotifier() : super(PlayButtonState.idle);

  void startLoading() => state = PlayButtonState.loading;
  void stopLoading() => state = PlayButtonState.idle;
  void startRunning() => state = PlayButtonState.running;
  void stopRunning() => state = PlayButtonState.idle;
}

final playButtonStateProvider =
    StateNotifierProvider<PlayButtonStateNotifier, PlayButtonState>(
        (ref) => PlayButtonStateNotifier());

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    final buttonState = ref.watch(playButtonStateProvider);
    final playButtonNotifier = ref.read(playButtonStateProvider.notifier);

    void onNierAutomataStopped() {
      playButtonNotifier.stopRunning();
    }

    bool checkPathAndProcessing() {
      return globalState.input.isNotEmpty && !globalState.isLoading;
    }

    Color getButtonColor() {
      if (buttonState == PlayButtonState.running) {
        return AutomatoThemeColors.dangerZone(ref);
      } else if (!checkPathAndProcessing()) {
        return AutomatoThemeColors.primaryColor(ref).withOpacity(0.2);
      } else {
        return AutomatoThemeColors.primaryColor(ref);
      }
    }

    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextButton(
          onPressed:
              checkPathAndProcessing() && buttonState != PlayButtonState.loading
                  ? () async {
                      await _handleProcessButtonState(
                          buttonState,
                          playButtonNotifier,
                          globalState,
                          onNierAutomataStopped);
                    }
                  : null,
          style: TextButton.styleFrom(
            foregroundColor: getButtonColor(),
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            backgroundColor: AutomatoThemeColors.darkBrown(ref),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: AutomatoThemeColors.transparentColor(ref),
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 53.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: buttonState == PlayButtonState.loading
              ? SizedBox(
                  width: 125.0,
                  height: 70.0,
                  child: AutomatoLoading(
                    color: AutomatoThemeColors.bright(ref),
                    translateX: 0,
                    svgString: AutomatoSvgStrings.automatoSvgStrHead,
                  ),
                )
              : Text(
                  buttonState == PlayButtonState.running ? "STOP" : "PLAY",
                  style: TextStyle(
                    color: getButtonColor(),
                  ),
                ),
        ));
  }

  Future<void> _handleProcessButtonState(
      PlayButtonState buttonState,
      PlayButtonStateNotifier playButtonNotifier,
      GlobalState globalState,
      void Function() onNierAutomataStopped) async {
    if (buttonState == PlayButtonState.idle) {
      playButtonNotifier.startLoading();
      try {
        bool started = await startNierAutomataExecutable(
            globalState.input, onNierAutomataStopped);
        if (started) {
          playButtonNotifier.startRunning();
        } else {
          playButtonNotifier.stopLoading();
        }
      } catch (e) {
        globalLog("$e");
        playButtonNotifier.stopLoading();
      }
    } else if (buttonState == PlayButtonState.running) {
      playButtonNotifier.startLoading();
      final success = ProcessService.terminateProcess('NierAutomata.exe');
      if (success) {
        playButtonNotifier.stopRunning();
      }
      playButtonNotifier.stopLoading();
    }
  }
}
