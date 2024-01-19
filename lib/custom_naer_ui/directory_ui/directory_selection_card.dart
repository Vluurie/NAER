import 'dart:io';
import 'package:flutter/material.dart';

class DirectorySelectionCard extends StatefulWidget {
  final String title;
  final String path;
  final Future<void> Function(Function(String)) onBrowse;
  final IconData icon;
  final double width;
  final bool enabled;
  final String? hint;
  final String? hints;

  const DirectorySelectionCard({
    super.key,
    required this.title,
    required this.path,
    required this.onBrowse,
    required this.icon,
    this.width = 300,
    this.enabled = true,
    this.hint,
    this.hints,
  });

  @override
  _DirectorySelectionCardState createState() => _DirectorySelectionCardState();
}

class _DirectorySelectionCardState extends State<DirectorySelectionCard> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.path.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant DirectorySelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      setState(() {
        isSelected = widget.path.isNotEmpty;
      });
    }
  }

  void handleBrowse() async {
    await widget.onBrowse((selectedPath) {
      setState(() {
        isSelected = selectedPath.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on the platform and enabled state
    Color backgroundColor =
        isSelected ? Colors.green : const Color.fromARGB(255, 34, 34, 36);
    Color textColor = isSelected ? Colors.white : Colors.grey;
    Color iconColor = isSelected
        ? Theme.of(context).indicatorColor
        : const Color.fromARGB(255, 255, 0, 0);

    if (Platform.isWindows && !widget.enabled) {
      backgroundColor = const Color.fromARGB(24, 71, 70, 70);
      textColor = const Color.fromARGB(151, 70, 69, 69);
      iconColor = const Color.fromARGB(153, 58, 57, 57);
    }

    return GestureDetector(
      onTap: widget.enabled ? handleBrowse : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).highlightColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: textColor)),
            const SizedBox(height: 5),
            Text(
              isSelected ? widget.path : 'No directory selected',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check : widget.icon,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isSelected ? 'Selected' : 'Browse',
                  style: TextStyle(color: iconColor),
                ),
              ],
            ),
            if (widget.hints != null && !isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.hints!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ),
            if (!widget.enabled && widget.hint != null && !isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  widget.hint!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
