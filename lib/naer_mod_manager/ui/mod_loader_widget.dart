// ignore_for_file: use_build_context_synchronously

import 'package:NAER/naer_ui/animations/dotted_line_progress_animation.dart';
import 'package:NAER/naer_mod_manager/ui/mod_list.dart';
import 'package:NAER/naer_mod_manager/utils/handle_zip_file.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:NAER/naer_utils/change_tracker.dart' as tracker;

class ModLoaderWidget extends StatefulWidget {
  final CLIArguments cliArguments;
  final ModStateManager modStateManager;

  const ModLoaderWidget({
    super.key,
    required this.cliArguments,
    required this.modStateManager,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ModLoaderWidgetState createState() => _ModLoaderWidgetState();
}

class _ModLoaderWidgetState extends State<ModLoaderWidget>
    with SingleTickerProviderStateMixin {
  bool _isDragDropEnabled = true;
  bool _isDraggingOver = false;
  bool modsWerePreviouslyLoaded = false;
  final List<Mod> _mods = [];
  late AnimationController _animationController;
  bool _isLoadingMods = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    initMetaData();
  }

  void initMetaData() async {
    final directoryPath =
        "${await tracker.FileChange.ensureSettingsDirectory()}/ModPackage";

    final mods = await ModHandler.parseModMetadata(directoryPath);
    setState(() {
      _mods.addAll(mods);
      modsWerePreviouslyLoaded = mods.isNotEmpty;
      _isDragDropEnabled = !modsWerePreviouslyLoaded;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDragDropArea() {
    if (_isLoadingMods) {
      return const Center(child: DottedLineProgressIndicator());
    }

    return DropTarget(
      onDragEntered: (final details) {
        setState(() => _isDraggingOver = true);
        _animationController.forward();
      },
      onDragExited: (final details) {
        setState(() => _isDraggingOver = false);
        _animationController.reverse();
      },
      onDragDone: (final details) async {
        bool isFileSupported = false;
        String filePath = details.files.first.path;
        if (filePath.endsWith("ModPackage.zip")) {
          isFileSupported = true;
        }

        if (isFileSupported) {
          setState(() => _isLoadingMods = true);

          var mods = await ModHandler.handleZipFile(
              details.files.map((final file) => file.path).toList());

          if (mods != null && mods.isNotEmpty) {
            setState(() {
              _isDragDropEnabled = false;
              _mods.addAll(mods);
              widget.modStateManager.fetchAndUpdateModsList();
              _isLoadingMods = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Mods loaded successfully!"),
                  duration: Duration(seconds: 3)),
            );
          } else {
            setState(() => _isLoadingMods = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      "Failed to load mods from the ZIP file. Probably invalid package/name/file."),
                  duration: Duration(seconds: 3)),
            );
          }
        } else {
          setState(() => _isLoadingMods = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Unsupported file. Only ModPackage.zip is allowed."),
                duration: Duration(seconds: 3)),
          );
        }
      },
      child: AnimatedContainer(
        width: 800,
        duration: const Duration(milliseconds: 100),
        height: _isDraggingOver ? 220 : 200,
        decoration: BoxDecoration(
          color: _isDraggingOver
              ? const Color.fromARGB(134, 25, 224, 250).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          border: Border.all(
            color: _isDraggingOver
                ? const Color.fromARGB(255, 33, 219, 243)
                : Colors.grey,
            width: _isDraggingOver ? 4 : 1,
          ),
          borderRadius: BorderRadius.circular(_isDraggingOver ? 20 : 0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              _isDraggingOver
                  ? "Drag to load mods "
                  : "Drop ModPackage.zip here to load the mod manager feature.",
              style: TextStyle(
                fontSize: 25,
                color: _isDraggingOver
                    ? const Color.fromARGB(255, 21, 219, 47)
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final bool _isLoading = false;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        if (_isDragDropEnabled)
          _isLoading
              ? const DottedLineProgressIndicator()
              : _buildDragDropArea(),
        Expanded(
          child: _isLoading
              ? const Center(child: DottedLineProgressIndicator())
              : ModsList(
                  mods: _mods,
                  cliArguments: widget.cliArguments,
                  modStateManager: widget.modStateManager),
        ),
      ],
    );
  }
}
