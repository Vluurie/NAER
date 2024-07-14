import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_ui/setup/path_checkbox_widget.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DirectorySelectionCard(
                  title: "Input Directory:",
                  path: widget.globalState.input,
                  onBrowse: (updatePath) =>
                      InputFileDialog().openInputFileDialog(
                    updatePath,
                    context,
                    widget.globalState,
                    () => setState(() {}),
                    ref,
                  ),
                  icon: Icons.folder_open,
                  hints: "Hints: Your Game data folder.",
                ),
                const SizedBox(width: 16),
                DirectorySelectionCard(
                  title: "Output Directory:",
                  path: widget.globalState.specialDatOutputPath,
                  onBrowse: (updatePath) =>
                      OutputFileDialog().openOutputFileDialog(
                    updatePath,
                    context,
                    widget.globalState,
                    () => setState(() {}),
                    ref,
                  ),
                  icon: Icons.folder_open,
                  hints: "Hints: Also Game data folder.",
                ),
                const SizedBox(width: 16),
                PathCheckBoxWidget(
                  loadPathsFuture: widget.loadPathsFuture,
                  globalState: widget.globalState,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
