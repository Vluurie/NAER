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

final talkingHeadPhraseProvider =
    StateNotifierProvider<TalkingHeadPhraseNotifier, String>(
        (ref) => TalkingHeadPhraseNotifier());

class TalkingHeadPhraseNotifier extends StateNotifier<String> {
  TalkingHeadPhraseNotifier() : super("Initializing...");

  Timer? _timer;
  final List<String> _phrases = [
    "Looking good!",
    "This'll be great!",
    "Almost there...",
    "Just a bit more...",
    "Hang tight...",
  ];

  void startTalking() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      state = _phrases[timer.tick % _phrases.length];
    });
  }

  void stopTalking() {
    _timer?.cancel();
    state = "";
  }
}

class PlayButton extends ConsumerWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    final buttonState = ref.watch(playButtonStateProvider);
    final playButtonNotifier = ref.read(playButtonStateProvider.notifier);
    final currentPhrase = ref.watch(talkingHeadPhraseProvider);
    final talkingHeadNotifier = ref.read(talkingHeadPhraseProvider.notifier);

    void onNierAutomataStopped() {
      playButtonNotifier.stopRunning();
      talkingHeadNotifier.stopTalking();
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
                        talkingHeadNotifier,
                        globalState,
                        onNierAutomataStopped);
                  }
                : null,
        style: TextButton.styleFrom(
          foregroundColor: getButtonColor(),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          backgroundColor: AutomatoThemeColors.darkBrown(ref),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: AutomatoThemeColors.transparentColor(ref),
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: buttonState == PlayButtonState.loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 50,
                    child: AutomatoLoading(
                      color: AutomatoThemeColors.bright(ref),
                      translateX: 0,
                      svgString: AutomatoSvgStrings.automatoSvgStrHead,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          AutomatoThemeColors.darkBrown(ref).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      currentPhrase,
                      style: TextStyle(
                        color: AutomatoThemeColors.primaryColor(ref),
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                buttonState == PlayButtonState.running ? "STOP" : "PLAY",
                style: TextStyle(
                  color: getButtonColor(),
                ),
              ),
      ),
    );
  }

  Future<void> _handleProcessButtonState(
      PlayButtonState buttonState,
      PlayButtonStateNotifier playButtonNotifier,
      TalkingHeadPhraseNotifier talkingHeadNotifier,
      GlobalState globalState,
      void Function() onNierAutomataStopped) async {
    if (buttonState == PlayButtonState.idle) {
      // Start Nier Automata
      playButtonNotifier.startLoading();
      talkingHeadNotifier.startTalking();
      try {
        bool started = await startNierAutomataExecutable(
            globalState.input, onNierAutomataStopped);
        if (started) {
          playButtonNotifier.startRunning();
        } else {
          playButtonNotifier.stopLoading();
          talkingHeadNotifier.stopTalking();
        }
      } catch (e) {
        globalLog("$e");
        playButtonNotifier.stopLoading();
        talkingHeadNotifier.stopTalking();
      }
    } else if (buttonState == PlayButtonState.running) {
      // Stop Nier Automata
      playButtonNotifier.startLoading();
      final success = ProcessService.terminateProcess('NierAutomata.exe');
      if (success) {
        playButtonNotifier.stopRunning();
        talkingHeadNotifier.stopTalking();
      }
      playButtonNotifier.stopLoading();
    }
  }
}
