import 'dart:async';

import 'package:NAER/main.dart';
import 'package:NAER/naer_database/handle_db_preferences.dart';
import 'package:NAER/naer_save_editor/save_editor.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_ui/directory_ui/balance_mode_checkbox.dart';
import 'package:NAER/naer_ui/directory_ui/dlc_checkbox.dart';
import 'package:NAER/naer_ui/button/navigate_button.dart';
import 'package:NAER/naer_ui/setup/path_checkbox_widget.dart';

import 'package:NAER/naer_utils/change_app_theme.dart';
import 'package:NAER/naer_utils/get_paths.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/delete_extracted_folders.dart';

import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OptionsPanel extends ConsumerWidget {
  final bool isVisible;
  final VoidCallback onToggle;
  final ScrollController scrollController;

  const OptionsPanel({
    required this.isVisible,
    required this.onToggle,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);

    return Stack(children: [
      if (isVisible)
        GestureDetector(
          onTap: onToggle,
          child: Container(
            color: AutomatoThemeColors.transparentColor(ref),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 150),
        left: isVisible ? 0 : -400,
        top: 0,
        bottom: 0,
        child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: AutomatoThemeColors.primaryColor(ref),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(3, 0),
                ),
              ],
            ),
            child: Stack(children: [
              AutomatoBackground(
                ref: ref,
                showBackgroundSVG: false,
                showRepeatingBorders: false,
                gradientColor: AutomatoThemeColors.gradient(ref),
                linesConfig: LinesConfig(
                    lineColor: AutomatoThemeColors.bright(ref),
                    strokeWidth: 2,
                    spacing: 5,
                    flickerDuration: const Duration(milliseconds: 2000),
                    enableFlicker: false,
                    drawHorizontalLines: true,
                    drawVerticalLines: true),
              ),
              Opacity(
                  opacity: 0.1,
                  child: AutomatoBackgroundSVG(
                      svgColor: AutomatoThemeColors.darkBrown(ref),
                      svgOuterString: AutomatoSvgStrings.automatoSvgStrPointer,
                      svgInnerString:
                          AutomatoSvgStrings.automatoSvgStrPointer)),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AutomatoThemeColors.darkBrown(ref),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!globalState.isLoading)
                              ListTile(title: navigateButton(context, ref)),
                            if (!globalState.isLoading)
                              ListTile(
                                title: AutomatoButton(
                                  label: "Save File Editor",
                                  onPressed: () {
                                    bool isNierRunning =
                                        ProcessService.isProcessRunning(
                                            "NieRAutomata.exe");
                                    if (!isNierRunning) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (final context) =>
                                              const SaveEditor(),
                                        ),
                                      );
                                    } else {
                                      showNierIsRunningDialog(context, ref);
                                    }
                                  },
                                  uniqueId: "exp_money",
                                  maxScale: 0.9,
                                  showPointer: false,
                                  baseColor: AutomatoThemeColors.darkBrown(ref),
                                  activeFillColor:
                                      AutomatoThemeColors.primaryColor(ref),
                                  fillBehavior: FillBehavior.filledRightToLeft,
                                ),
                              ),
                            ListTile(
                              title: AutomatoButton(
                                label: "App Theme Modifier",
                                onPressed: () =>
                                    changeAppThemePopup(context, ref),
                                uniqueId: "theme",
                                maxScale: 0.9,
                                showPointer: false,
                                baseColor: AutomatoThemeColors.darkBrown(ref),
                                activeFillColor:
                                    AutomatoThemeColors.primaryColor(ref),
                                fillBehavior: FillBehavior.filledRightToLeft,
                              ),
                            ),
                            ListTile(
                              title: AutomatoButton(
                                label: "Output",
                                onPressed: () => getOutputPath(context, ref,
                                    globalState.specialDatOutputPath),
                                uniqueId: "outputPath",
                                maxScale: 0.9,
                                showPointer: false,
                                baseColor: AutomatoThemeColors.darkBrown(ref),
                                activeFillColor:
                                    AutomatoThemeColors.primaryColor(ref),
                                fillBehavior: FillBehavior.filledRightToLeft,
                              ),
                            ),
                            if (!globalState.isLoading)
                              ListTile(
                                title: AutomatoButton(
                                  maxScale: 0.8,
                                  onPressed: () async {
                                    AutomatoDialogManager().showYesNoDialog(
                                      context: context,
                                      ref: ref,
                                      title: 'Are you sure?',
                                      content: Text(
                                        'This will reset the app and clear all local app settings data. Do you want to proceed?',
                                        style: TextStyle(
                                          color: AutomatoThemeColors
                                              .textDialogColor(ref),
                                          fontSize: 20,
                                        ),
                                      ),
                                      onYesPressed: () async {
                                        await DatabasePreferenceHandler
                                            .deleteAllPreferences();
                                        await deleteSharedPreferences();

                                        await resetGlobalState(ref);
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ref
                                              .read(appKeyProvider.notifier)
                                              .state = UniqueKey();
                                        }
                                      },
                                      onNoPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      yesLabel: 'OK',
                                      noLabel: 'Cancel',
                                      activeHoverColorNo:
                                          AutomatoThemeColors.darkBrown(ref),
                                      activeHoverColorYes:
                                          AutomatoThemeColors.dangerZone(ref),
                                      yesButtonColor:
                                          AutomatoThemeColors.darkBrown(ref),
                                      noButtonColor:
                                          AutomatoThemeColors.darkBrown(ref),
                                    );
                                  },
                                  label: 'Reset Application Local State',
                                  uniqueId: 'reset',
                                  activeHoverColor:
                                      AutomatoThemeColors.dangerZone(ref),
                                  showPointer: false,
                                ),
                              ),
                            if (!globalState.isLoading)
                              ListTile(
                                title: AutomatoButton(
                                  label: "Delete Extracted Backup",
                                  onPressed: () =>
                                      AutomatoDialogManager().showYesNoDialog(
                                    context: context,
                                    ref: ref,
                                    title: 'Are you sure?',
                                    content: Text(
                                      'This will delete the 9GB backup that got created from extracting. Are you sure?',
                                      style: TextStyle(
                                        color:
                                            AutomatoThemeColors.textDialogColor(
                                                ref),
                                        fontSize: 20,
                                      ),
                                    ),
                                    onYesPressed: () async {
                                      Navigator.of(context).pop(false);

                                      unawaited(showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (final BuildContext context) {
                                          return PopScope(
                                            onPopInvokedWithResult:
                                                (final canPop,
                                                    final result) async {},
                                            child: Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Center(
                                                child: SizedBox(
                                                  width: 150,
                                                  height: 150,
                                                  child: AutomatoLoading(
                                                    color: AutomatoThemeColors
                                                        .bright(ref),
                                                    translateX: 0,
                                                    svgString:
                                                        AutomatoSvgStrings
                                                            .automatoSvgStrHead,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ));

                                      await deleteBackupGameFolders(
                                          globalState.input);
                                      if (context.mounted) {
                                        Navigator.of(context).pop(true);
                                      }
                                    },
                                    onNoPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    yesLabel: 'OK',
                                    noLabel: 'Cancel',
                                    activeHoverColorNo:
                                        AutomatoThemeColors.darkBrown(ref),
                                    activeHoverColorYes:
                                        AutomatoThemeColors.dangerZone(ref),
                                    yesButtonColor:
                                        AutomatoThemeColors.darkBrown(ref),
                                    noButtonColor:
                                        AutomatoThemeColors.darkBrown(ref),
                                  ),
                                  uniqueId: "deleteBackup",
                                  maxScale: 0.8,
                                  activeHoverColor:
                                      AutomatoThemeColors.dangerZone(ref),
                                  showPointer: false,
                                ),
                              ),
                            const Divider(),
                            ListTile(
                              title: const Text('Options'),
                              tileColor: AutomatoThemeColors.darkBrown(ref),
                              textColor: AutomatoThemeColors.darkBrown(ref),
                            ),
                            const ListTile(
                              title: PathCheckBoxWidget(),
                            ),
                            const ListTile(
                              title: DLCCheckBox(),
                            ),
                            const ListTile(
                              title: BalanceModeCheckBox(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ])),
      )
    ]);
  }
}
