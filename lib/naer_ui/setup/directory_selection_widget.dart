import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_ui/directory_ui/directory_selection_card.dart';
import 'package:NAER/naer_ui/setup/path_checkbox_widget.dart';
import 'package:NAER/naer_utils/get_paths.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';

class DirectorySelection extends StatefulWidget {
  final Future<bool> loadPathsFuture;
  final GlobalState globalState;

  const DirectorySelection({
    super.key,
    required this.loadPathsFuture,
    required this.globalState,
  });

  @override
  State<DirectorySelection> createState() => _DirectorySelectionState();
}

class _DirectorySelectionState extends State<DirectorySelection> {
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
            Text('Directory Selection',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                DirectorySelectionCard(
                  title: "Input Directory:",
                  path: widget.globalState.input,
                  onBrowse: (updatePath) => InputFileDialog()
                      .openInputFileDialog(updatePath, context,
                          widget.globalState, () => setState(() {})),
                  icon: Icons.folder_open,
                  hints: "Hints: Your Game data folder.",
                ),
                DirectorySelectionCard(
                  title: "Output Directory:",
                  path: widget.globalState.specialDatOutputPath,
                  onBrowse: (updatePath) => OutputFileDialog()
                      .openOutputFileDialog(updatePath, context,
                          widget.globalState, () => setState(() {})),
                  icon: Icons.folder_open,
                  hints: "Hints: Also Game data folder.",
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_full, size: 18),
                  label:
                      const Text('Open output', style: TextStyle(fontSize: 14)),
                  onPressed: () => getOutputPath(
                      context, widget.globalState.specialDatOutputPath),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Settings', style: TextStyle(fontSize: 14)),
                  onPressed: () => getNaerSettings(context),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 25, 25, 26)),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 71, 192, 240)),
                  ),
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
