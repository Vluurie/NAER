import 'dart:io';

import 'package:NAER/naer_database/handle_db_additions.dart';
import 'package:NAER/naer_database/handle_db_modifications.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> removeModificationWithIndicator(final WidgetRef ref,
    {required final bool isAddition}) async {
  final globalState = ref.read(globalStateProvider.notifier);

  globalState.setIsLoading(isLoading: true);
  globalState.setIsProcessing(isProcessing: true);

  await removeModificationsSilently(isAddition: isAddition);
  await deleteEmptyDirectories(Directory(globalState.readInput()));


  globalState.setIsLoading(isLoading: false);
  globalState.setIsProcessing(isProcessing: false);

  globalState.clearCreatedFiles();
}

Future<void> removeModificationsSilently(
    {required final bool isAddition}) async {
  if (!isAddition) {
    await DatabaseModificationHandler.queryModificationsFromDatabase();
    await DatabaseModificationHandler.deleteModifications();
  } else {
    await DatabaseAdditionHandler.queryAdditionsFromDatabase();
    await DatabaseAdditionHandler.deleteAdditions();
  }
  globalLog("Removed modifications.");
}
