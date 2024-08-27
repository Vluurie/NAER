import 'dart:io';

import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void undoLastModification(final WidgetRef ref) async {
  final globalState = ref.read(globalStateProvider.notifier);
  await FileChange.loadChanges();
  await FileChange.undoChanges();

  final createdFiles = globalState.readCreatedFiles();

  try {
    for (var filePath in createdFiles) {
      var file = File(filePath);

      if (await file.exists()) {
        try {
          await file.delete();
          globalLog("Deleted file: $filePath");
        } catch (e) {
          globalLog("Error deleting file $filePath: $e");
        }
      } else {
        globalLog("File not found: $filePath");
      }
    }

    globalLog("Last modification undone.");
    globalState.setIsLoading(isLoading: false);
    globalState.setIsProcessing(isProcessing: false);

    globalState.clearCreatedFiles();
  } catch (e) {
    globalLog("An error occurred during undo: $e");
    globalLog("Error during undo: $e");
    globalState.setIsLoading(isLoading: false);
    globalState.setIsProcessing(isProcessing: false);
  }
}
