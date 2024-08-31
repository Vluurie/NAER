import 'package:NAER/naer_ui/button/play_button.dart';
import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_ui/button/toggle_button.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_form.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/tutorial_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeftSideSelection extends ConsumerWidget {
  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _toggleButtonKey = GlobalKey();

  LeftSideSelection({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final tutorialAttempted = ref.watch(tutorialAttemptedProvider);

    bool wasModListDetectionDialogManaged =
        globalStateNotifier.readWasModManamentDialogShown();

    if (!tutorialAttempted) {
      WidgetsBinding.instance.addPostFrameCallback((final _) async {
        if (globalState.input.isNotEmpty &&
            globalState.specialDatOutputPath.isNotEmpty &&
            wasModListDetectionDialogManaged) {
          await _checkAndShowTutorial(context, ref);
        }
      });
    }

    return Flexible(
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
                  onBrowse: (final updatePath) async {
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
                  onBrowse: (final updatePath) async {
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
          if (!globalState.isLoading)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ToggleButton(
                  key: _toggleButtonKey,
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
                      key: _addButtonKey,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (final context) =>
                                const SetupConfigFormScreen(),
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

  Future<void> _checkAndShowTutorial(
      final BuildContext context, final WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorial_shown') ?? false;

    if (!tutorialShown && !ref.read(tutorialAttemptedProvider)) {
      ref.read(tutorialAttemptedProvider.notifier).markTutorialAttempted();
      await Future.delayed(const Duration(milliseconds: 300));

      if (_addButtonKey.currentContext != null &&
          _toggleButtonKey.currentContext != null) {
        if (context.mounted) _showTutorial(context, ref);

        await prefs.setBool('tutorial_shown', true);
      }
    }
  }

  void _showTutorial(final BuildContext context, final WidgetRef ref) {
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    print("Showing tutorial");

    TutorialCoachMark(
      targets: _createTargets(),
      onFinish: () {
        print("Tutorial finished");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (final context) => const SetupConfigFormScreen(),
          ),
        );
      },
      onClickTarget: (final target) {
        print(target);
        globalStateNotifier.toggleCustomSelection();
      },
      onSkip: () {
        print("Tutorial skipped");
        return false;
      },
    ).show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "ToggleButton",
        keyTarget: _toggleButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 0.0,
        paddingFocus: 2.0,
        contents: [
          TargetContent(
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                "Switch between predefined setups or direct selection and modification like it was in the old versions of NAER.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "AddButton",
        keyTarget: _addButtonKey,
        contents: [
          TargetContent(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "New Feature: Click here to add a new custom Setup.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
