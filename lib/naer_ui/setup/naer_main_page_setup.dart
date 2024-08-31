import 'package:NAER/naer_ui/image_ui/enemy_image_grid.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_list.dart';
import 'package:NAER/naer_ui/setup/directory_selection_widget.dart';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:NAER/naer_ui/setup/setup_all_selections.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaerMainPageSetup extends StatelessWidget {
  const NaerMainPageSetup({
    super.key,
    required this.ref,
    required this.logOutputKey,
  });

  final WidgetRef ref;
  final GlobalKey<LogOutputState> logOutputKey;

  @override
  Widget build(final BuildContext context) {
    final globalState = ref.watch(globalStateProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                KeyedSubtree(
                  key: globalState.setupDirectorySelectionKey,
                  child: const DirectorySelection(),
                ),
              ],
            ),
          ),
          if (!globalState.customSelection)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: SetupList(),
              ),
            ),
          if (globalState.customSelection)
            KeyedSubtree(
              key: globalState.setupCategorySelectionKey,
              child: setupAllSelections(context, ref),
            ),
          if (globalState.customSelection)
            KeyedSubtree(
              key: globalState.setupImageGridKey,
              child: EnemyImageGrid(key: globalState.enemyImageGridKey),
            ),
        ],
      ),
    );
  }
}
