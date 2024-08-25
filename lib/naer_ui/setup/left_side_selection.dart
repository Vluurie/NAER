import 'package:NAER/naer_ui/button/play_button.dart';
import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_ui/button/toggle_button.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_form.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftSideSelection extends ConsumerWidget {
  const LeftSideSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);

    return Flexible(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PlayButton(),
              const SizedBox(width: 16),
              Expanded(
                child: DirectorySelectionCard(
                  title: "Input Directory:",
                  path: globalState.input,
                  onBrowse: (updatePath) async {
                    await InputDirectoryHandler().openInputFileDialog(
                      context,
                      ref,
                    );
                  },
                  icon: Icons.folder_open,
                  uniqueSuffix: '1',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DirectorySelectionCard(
                  title: "Output Directory:",
                  path: globalState.specialDatOutputPath,
                  onBrowse: (updatePath) async {
                    await OutputDirectoryHandler().openOutputFileDialog(
                      context,
                      ref,
                    );
                  },
                  icon: Icons.folder_open,
                  uniqueSuffix: '2',
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButton(
                isSelected: globalState.customSelection,
                onLabel: 'Predefined Setup',
                offLabel: 'Custom Modify',
                selectedColor: AutomatoThemeColors.darkBrown(ref),
                unselectedColor: AutomatoThemeColors.darkBrown(ref),
                onToggle: () => globalStateNotifier.toggleCustomSelection(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Tooltip(
                  message: 'Add new configuration',
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SetupConfigFormScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AutomatoThemeColors.darkBrown(ref),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      elevation: 3.0,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AutomatoThemeColors.primaryColor(ref),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
