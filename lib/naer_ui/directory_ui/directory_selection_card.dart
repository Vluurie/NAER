import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectorySelectionCard extends ConsumerStatefulWidget {
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
  DirectorySelectionCardState createState() => DirectorySelectionCardState();
}

class DirectorySelectionCardState
    extends ConsumerState<DirectorySelectionCard> {
  bool isSelected = false;
  bool isHovered = false;
  String selectedPath = '';

  @override
  void initState() {
    super.initState();
    isSelected = widget.path.isNotEmpty;
    selectedPath = widget.path;
  }

  @override
  void didUpdateWidget(covariant DirectorySelectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      setState(() {
        isSelected = widget.path.isNotEmpty;
        selectedPath = widget.path;
      });
    }
  }

  void handleBrowse() async {
    await widget.onBrowse((newPath) {
      setState(() {
        isSelected = newPath.isNotEmpty;
        selectedPath = newPath;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isSelected
        ? AutomatoThemeColors.primaryColor(ref)
        : AutomatoThemeColors.darkBrown(ref);
    Color textColor = isSelected
        ? AutomatoThemeColors.darkBrown(ref)
        : AutomatoThemeColors.primaryColor(ref);
    Color iconColor = isSelected
        ? AutomatoThemeColors.saveZone(ref)
        : AutomatoThemeColors.dangerZone(ref);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.enabled ? handleBrowse : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovered
              ? Matrix4.translationValues(4, -4, -4)
              : Matrix4.identity(),
          width: widget.width,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).highlightColor),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color:
                          AutomatoThemeColors.darkBrown(ref).withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 0,
                      offset: const Offset(3, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color:
                          AutomatoThemeColors.darkBrown(ref).withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: const Offset(2, 2),
                    ),
                  ],
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
                isSelected ? selectedPath : 'No directory selected',
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
                    style: TextStyle(
                      color: AutomatoThemeColors.primaryColor(ref),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              if (!widget.enabled && widget.hint != null && !isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.hint!,
                    style: TextStyle(
                      color: AutomatoThemeColors.primaryColor(ref),
                      fontSize: 12.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
