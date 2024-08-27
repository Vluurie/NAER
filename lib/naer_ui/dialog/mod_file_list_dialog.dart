import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModFilesList extends StatefulWidget {
  final List<String> modFiles;
  final WidgetRef ref;
  final void Function(int) onRemovePressed;

  const ModFilesList({
    super.key,
    required this.modFiles,
    required this.ref,
    required this.onRemovePressed,
  });

  @override
  ModFilesListState createState() => ModFilesListState();
}

class ModFilesListState extends State<ModFilesList> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Detected mod files, they will be ignored by NAER during modification. Remove them from the list to include them in NAER's operations.",
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.normal,
              color: AutomatoThemeColors.textDialogColor(widget.ref),
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.modFiles.length,
              itemBuilder: (final BuildContext context, final int index) {
                return Card(
                  color: AutomatoThemeColors.darkBrown(widget.ref),
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  child: ListTile(
                    leading: Icon(
                      Icons.extension,
                      color: AutomatoThemeColors.saveZone(widget.ref),
                    ),
                    title: Text(
                      widget.modFiles[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AutomatoThemeColors.primaryColor(widget.ref),
                      ),
                    ),
                    subtitle: Text(
                      'Ignored by the tool',
                      style: TextStyle(
                        color: AutomatoThemeColors.bright(widget.ref),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AutomatoThemeColors.dangerZone(widget.ref),
                      ),
                      tooltip: 'Remove mod from ignore list',
                      onPressed: () => widget.onRemovePressed(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
