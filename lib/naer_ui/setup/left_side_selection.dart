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
              Flexible(
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
                  hints: "Hints: Your Game data folder.",
                  uniqueSuffix: '1',
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
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
                  hints: "Hints: Also Game data folder.",
                  uniqueSuffix: '2',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isNarrow = constraints.maxWidth < 450;

              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: [
                  const PlayButton(),
                  if (isNarrow) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ToggleButton(
                            isSelected: globalState.customSelection,
                            onLabel: 'Predefined Setup',
                            offLabel: 'Custom Modify',
                            selectedColor: AutomatoThemeColors.darkBrown(ref),
                            unselectedColor: AutomatoThemeColors.darkBrown(ref),
                            onToggle: () =>
                                globalStateNotifier.toggleCustomSelection(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SetupConfigFormScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AutomatoThemeColors.darkBrown(ref),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 12.0),
                            elevation: 3.0,
                          ),
                          child: Text(
                            'Add Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AutomatoThemeColors.primaryColor(ref),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ToggleButton(
                        isSelected: globalState.customSelection,
                        onLabel: 'Predefined Setup',
                        offLabel: 'Custom Modify',
                        selectedColor: AutomatoThemeColors.darkBrown(ref),
                        unselectedColor: AutomatoThemeColors.darkBrown(ref),
                        onToggle: () =>
                            globalStateNotifier.toggleCustomSelection(),
                      ),
                    ),
                    ElevatedButton(
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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        elevation: 3.0,
                      ),
                      child: Text(
                        'Add Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AutomatoThemeColors.primaryColor(ref),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
