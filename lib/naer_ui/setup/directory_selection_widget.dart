import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_utils/change_app_theme.dart';
import 'package:NAER/naer_utils/get_paths.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'path_checkbox_widget.dart';

class DirectorySelection extends ConsumerStatefulWidget {
  final Future<bool> loadPathsFuture;
  final GlobalState globalState;

  const DirectorySelection({
    super.key,
    required this.loadPathsFuture,
    required this.globalState,
  });

  @override
  ConsumerState<DirectorySelection> createState() => _DirectorySelectionState();
}

class _DirectorySelectionState extends ConsumerState<DirectorySelection> {
  @override
  void initState() {
    super.initState();
    widget.globalState.addListener(_onGlobalStateChange);
  }

  @override
  void dispose() {
    widget.globalState.removeListener(_onGlobalStateChange);
    super.dispose();
  }

  void _onGlobalStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                DirectorySelectionCard(
                  title: "Input Directory:",
                  path: widget.globalState.input,
                  onBrowse: (updatePath) => InputFileDialog()
                      .openInputFileDialog(updatePath, context,
                          widget.globalState, () => setState(() {}), ref),
                  icon: Icons.folder_open,
                  hints: "Hints: Your Game data folder.",
                ),
                DirectorySelectionCard(
                  title: "Output Directory:",
                  path: widget.globalState.specialDatOutputPath,
                  onBrowse: (updatePath) => OutputFileDialog()
                      .openOutputFileDialog(updatePath, context,
                          widget.globalState, () => setState(() {}), ref),
                  icon: Icons.folder_open,
                  hints: "Hints: Also Game data folder.",
                ),
                AutomatoButton(
                  label: "Open Output",
                  onPressed: () => getOutputPath(
                      context, widget.globalState.specialDatOutputPath),
                  uniqueId: "outputPath",
                  maxScale: 0.8,
                  showPointer: false,
                ),
                // AutomatoButton(
                //   label: "Settings",
                //   onPressed: () => getNaerSettings(context),
                //   uniqueId: "settingsPath",
                //   maxScale: 0.8,
                //   showPointer: false,
                // ),
                AutomatoButton(
                  label: "Change App Theme",
                  onPressed: () => changeAppThemePopup(context, ref),
                  uniqueId: "theme",
                  maxScale: 0.8,
                  showPointer: false,
                ),
                PathCheckBoxWidget(
                  loadPathsFuture: widget.loadPathsFuture,
                  globalState: widget.globalState,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
