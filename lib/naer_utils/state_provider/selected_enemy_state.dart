import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedEnemyDataNotifier
    extends StateNotifier<Map<String, List<String>>> {
  SelectedEnemyDataNotifier()
      : super({
          "Ground": [],
          "Fly": [],
          "Delete": [],
        });

  void updateSelectedEnemies(Map<String, List<String>> newSortedData) {
    state = newSortedData;
  }
}

final sortedEnemyDataProvider =
    StateNotifierProvider<SelectedEnemyDataNotifier, Map<String, List<String>>>(
        (ref) {
  return SelectedEnemyDataNotifier();
});
