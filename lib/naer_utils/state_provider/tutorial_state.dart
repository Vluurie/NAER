import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorialStateNotifier extends StateNotifier<bool> {
  TutorialStateNotifier() : super(false);

  void markTutorialAttempted() {
    state = true;
  }
}

final tutorialAttemptedProvider =
    StateNotifierProvider<TutorialStateNotifier, bool>((ref) {
  return TutorialStateNotifier();
});
