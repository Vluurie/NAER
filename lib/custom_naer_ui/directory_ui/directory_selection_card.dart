import 'package:flutter/material.dart';

class DirectorySelectionCard extends StatefulWidget {
  final String title;
  final String path;
  final Future<void> Function(Function(String)) onBrowse;
  final IconData icon;
  final double width; // Added width as a parameter

  const DirectorySelectionCard({
    super.key,
    required this.title,
    required this.path,
    required this.onBrowse,
    required this.icon,
    this.width = 300, // Default width if not provided
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

  void handleBrowse() async {
    await widget.onBrowse((selectedPath) {
      setState(() {
        isSelected = selectedPath.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleBrowse,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.green : const Color.fromARGB(255, 34, 34, 36),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).highlightColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(
              isSelected ? widget.path : 'No directory selected',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(isSelected ? Icons.check : widget.icon,
                    color: Theme.of(context).indicatorColor),
                const SizedBox(width: 8),
                Text(isSelected ? 'Selected' : 'Browse',
                    style: TextStyle(color: Theme.of(context).indicatorColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
