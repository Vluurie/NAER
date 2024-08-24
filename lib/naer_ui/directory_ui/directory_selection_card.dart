import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_utils/state_provider/directory_selection_state.dart';

final directorySelectionCardProvider = StateNotifierProvider.autoDispose.family<
    DirectorySelectionCardStateNotifier, DirectorySelectionCardState, String>(
  (ref, uniqueId) {
    return DirectorySelectionCardStateNotifier(uniqueId);
  },
);

class DirectorySelectionCard extends ConsumerWidget {
  final String title;
  final String? path;
  final Future<void> Function(Function(String)) onBrowse;
  final IconData icon;
  final double width; // This can now be treated as a maxWidth
  final bool enabled;
  final String? hint;
  final String? hints;
  final String uniqueSuffix;

  const DirectorySelectionCard({
    super.key,
    required this.title,
    this.path,
    required this.onBrowse,
    required this.icon,
    this.width = 300, // This acts as a default max width
    this.enabled = true,
    this.hint,
    this.hints,
    required this.uniqueSuffix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use uniqueSuffix to ensure each card is independently tracked
    final compositeKey = '${path ?? 'no-path'}-$uniqueSuffix';

    final state = ref.watch(directorySelectionCardProvider(compositeKey));
    final notifier =
        ref.read(directorySelectionCardProvider(compositeKey).notifier);

    // Update the path in the state only if it has changed
    if (state.selectedPath != path) {
      Future.microtask(() => notifier.updatePath(path ?? ''));
    }

    Color backgroundColor = state.isSelected
        ? AutomatoThemeColors.primaryColor(ref)
        : AutomatoThemeColors.darkBrown(ref);
    Color textColor = state.isSelected
        ? AutomatoThemeColors.darkBrown(ref)
        : AutomatoThemeColors.primaryColor(ref);
    Color iconColor = state.isSelected
        ? AutomatoThemeColors.saveZone(ref)
        : AutomatoThemeColors.dangerZone(ref);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust the width based on available space, respecting the maxWidth (width)
        final responsiveWidth =
            constraints.maxWidth < width ? constraints.maxWidth : width;

        return MouseRegion(
          onEnter: (_) => notifier.setHovered(true),
          onExit: (_) => notifier.setHovered(false),
          child: GestureDetector(
            onTap: enabled
                ? () async {
                    await onBrowse((newPath) {
                      notifier.updatePath(newPath);
                    });
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: state.isHovered
                  ? Matrix4.translationValues(4, -4, -4)
                  : Matrix4.identity(),
              width: responsiveWidth,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).highlightColor),
                boxShadow: state.isHovered
                    ? [
                        BoxShadow(
                          color: AutomatoThemeColors.darkBrown(ref)
                              .withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 0,
                          offset: const Offset(3, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AutomatoThemeColors.darkBrown(ref)
                              .withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: const Offset(2, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.selectedPath.isNotEmpty
                        ? state.selectedPath
                        : 'No directory selected',
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
                        state.isSelected ? Icons.check : icon,
                        color: iconColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.isSelected ? 'Selected' : 'Browse',
                        style: TextStyle(color: iconColor),
                      ),
                    ],
                  ),
                  if (hints != null && !state.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        hints!,
                        style: TextStyle(
                          color: AutomatoThemeColors.primaryColor(ref),
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  if (!enabled && hint != null && !state.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        hint!,
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
      },
    );
  }
}
