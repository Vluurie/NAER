// ignore_for_file: use_build_context_synchronously

import 'package:NAER/custom_naer_ui/mod__ui/mod_list.dart';
import 'package:NAER/naer_utils/handle_zip_file.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    initMetaData();
  }

  initMetaData() async {
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
    return DropTarget(
      onDragEntered: (details) {
        setState(() => _isDraggingOver = true);
        _animationController.forward();
      },
      onDragExited: (details) {
        setState(() => _isDraggingOver = false);
        _animationController.reverse();
      },
      onDragDone: (details) async {
        var mods = await ModHandler.handleZipFile(
            details.files.map((file) => file.path).toList());

        if (mods != null && mods.isNotEmpty) {
          setState(() {
            _isDragDropEnabled = false;
            _mods.addAll(mods);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Mods loaded successfully!"),
                duration: Duration(seconds: 3)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Failed to load mods or unsupported ZIP file."),
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
        child: Center(
          child: Text(
            _isDraggingOver
                ? "Drag to load mods "
                : "Drag NAER ModPackage here to load the mods",
            style: TextStyle(
              fontSize: 25,
              color: _isDraggingOver
                  ? const Color.fromARGB(255, 21, 219, 47)
                  : const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isDragDropEnabled) _buildDragDropArea(),
        Expanded(
          child: ModsList(
              mods: _mods,
              cliArguments: widget.cliArguments,
              modStateManager: widget.modStateManager),
        ),
      ],
    );
  }
}
