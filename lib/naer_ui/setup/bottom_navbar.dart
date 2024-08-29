import 'package:NAER/naer_ui/dialog/modify_confirmation_dialog.dart';
import 'package:NAER/naer_ui/dialog/nier_is_running.dart';
import 'package:NAER/naer_ui/dialog/undo_dialog.dart';
import 'package:NAER/naer_utils/process_service.dart';
import 'package:NAER/naer_utils/start_modification_process.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaerBottomNavigationBar extends ConsumerWidget {
  const NaerBottomNavigationBar({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final globalState = ref.watch(globalStateProvider);

    return Container(
      height: globalState.customSelection ? 80 : 0,
      color: AutomatoThemeColors.bright(ref),
      child: globalState.customSelection
          ? Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 15,
                    width: double.infinity,
                    color: AutomatoThemeColors.bright(ref),
                    child: buildRepeatingBorderSVG(
                      context,
                      svgWidget: const AutomatoBorderSVG(
                        svgString: AutomatoSvgStrings.automatoSvgStrBorder,
                      ),
                      height: 50,
                      width: 50,
                      mirror: true,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AutomatoThemeColors.darkBrown(ref),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AutomatoThemeColors.primaryColor(ref),
                          AutomatoThemeColors.bright(ref)
                        ],
                      ),
                    ),
                    child: BottomNavigationBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: MouseRegion(
                            onEnter: (final _) => globalStateNotifier
                                .updateHoverState('selectAll',
                                    isHovering: true),
                            onExit: (final _) => globalStateNotifier
                                .updateHoverState('selectAll',
                                    isHovering: false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: globalStateNotifier
                                        .readIsHoveringSelectAll()
                                    ? AutomatoThemeColors.brown15(ref)
                                    : AutomatoThemeColors.transparentColor(ref),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.select_all,
                                size: 28.0,
                                color: AutomatoThemeColors.darkBrown(ref),
                              ),
                            ),
                          ),
                          label: 'Select All',
                        ),
                        BottomNavigationBarItem(
                          icon: MouseRegion(
                            onEnter: (final _) => globalStateNotifier
                                .updateHoverState('unselectAll',
                                    isHovering: true),
                            onExit: (final _) => globalStateNotifier
                                .updateHoverState('unselectAll',
                                    isHovering: false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: globalStateNotifier
                                        .readIsHoveringUnselectAll()
                                    ? AutomatoThemeColors.brown15(ref)
                                    : AutomatoThemeColors.transparentColor(ref),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.cancel,
                                size: 28.0,
                                color: AutomatoThemeColors.darkBrown(ref),
                              ),
                            ),
                          ),
                          label: 'Unselect All',
                        ),
                        BottomNavigationBarItem(
                          icon: MouseRegion(
                            onEnter: (final _) => globalStateNotifier
                                .updateHoverState('undo', isHovering: true),
                            onExit: (final _) => globalStateNotifier
                                .updateHoverState('undo', isHovering: false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: globalStateNotifier.readIsHoveringUndo()
                                    ? AutomatoThemeColors.brown15(ref)
                                    : AutomatoThemeColors.transparentColor(ref),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.undo,
                                size: 28.0,
                                color: AutomatoThemeColors.dangerZone(ref),
                              ),
                            ),
                          ),
                          label: 'Undo',
                        ),
                        BottomNavigationBarItem(
                          icon: MouseRegion(
                            onEnter: (final _) => globalStateNotifier
                                .updateHoverState('modify', isHovering: true),
                            onExit: (final _) => globalStateNotifier
                                .updateHoverState('modify', isHovering: false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: globalStateNotifier
                                        .readIsHoveringModify()
                                    ? AutomatoThemeColors.brown15(ref)
                                    : AutomatoThemeColors.transparentColor(ref),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.shuffle,
                                size: 28.0,
                                color: AutomatoThemeColors.saveZone(ref),
                              ),
                            ),
                          ),
                          label: 'Modify',
                        ),
                      ],
                      currentIndex: globalStateNotifier.readSelectedIndex(),
                      selectedItemColor: AutomatoThemeColors.selected(ref),
                      unselectedItemColor: AutomatoThemeColors.darkBrown(ref),
                      onTap: (final index) =>
                          _onItemTapped(context, ref, index),
                      backgroundColor:
                          AutomatoThemeColors.transparentColor(ref),
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
                      selectedLabelStyle: const TextStyle(fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  void _onItemTapped(
      final BuildContext context, final WidgetRef ref, final int index) {
    final globalState = ref.read(globalStateProvider.notifier);
    globalState.setSelectedIndex(index);

    switch (index) {
      case 0:
        globalState.selectAllImagesGrid();
        break;
      case 1:
        globalState.unselectAllImagesGrid();
        break;
      case 2:
        bool isNierRunning =
            ProcessService.isProcessRunning("NieRAutomata.exe");
        if (!isNierRunning) {
          showUndoConfirmation(context, ref, isAddition: false);
        } else {
          showNierIsRunningDialog(context, ref);
        }
        break;
      case 3:
        _onPressedAction(context, ref);
        break;
      default:
        break;
    }
  }

  void _onPressedAction(final BuildContext context, final WidgetRef ref) {
    final globalState = ref.read(globalStateProvider);
    if (globalState.isButtonEnabled) {
      showModifyDialogAndModify(context, ref, startModificationProcess,
          isAddition: false);
    }
  }
}
