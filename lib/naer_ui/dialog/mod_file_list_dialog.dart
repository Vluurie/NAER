import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModFilesList extends StatefulWidget {
  final List<String> modFiles;
  final WidgetRef ref;
  final void Function(int?) onRemovePressed;

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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            "Below is a list of detected scripted mod files. Mods listed here will be ignored by the tool during modification. You can remove mods from this list to include them in the tool's operations. This will overwrite them. For a lot of scripted mod files, you can randomize them using the mod manager. \nFor example: A language mod is installed: For this to work with the randomizer you need to drag the language mod in the mod manager folder randomization or add it to the mod list manually. For more information visit the NAER Guide.",
            style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AutomatoThemeColors.textDialogColor(widget.ref)),
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.modFiles.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: AutomatoThemeColors.darkBrown(widget.ref),
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  child: ListTile(
                    leading: Icon(Icons.extension,
                        color: AutomatoThemeColors.saveZone(widget.ref)),
                    title: Text(
                      widget.modFiles[index],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AutomatoThemeColors.primaryColor(widget.ref)),
                    ),
                    subtitle: Text('Currently ignored by the tool',
                        style: TextStyle(
                            color: AutomatoThemeColors.bright(widget.ref))),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: AutomatoThemeColors.dangerZone(widget.ref)),
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
