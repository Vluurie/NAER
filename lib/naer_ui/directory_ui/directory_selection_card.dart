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
  final double width;
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
    this.width = 200,
    this.enabled = true,
    this.hint,
    this.hints,
    required this.uniqueSuffix,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compositeKey = '${path ?? 'no-path'}-$uniqueSuffix';

    final state = ref.watch(directorySelectionCardProvider(compositeKey));
    final notifier =
        ref.read(directorySelectionCardProvider(compositeKey).notifier);

    if (state.selectedPath != path) {
      Future.microtask(() => notifier.updatePath(path ?? ''));
    }

    Color backgroundColor = state.isSelected
        ? AutomatoThemeColors.darkBrown(ref)
        : AutomatoThemeColors.primaryColor(ref);
    Color textColor = state.isSelected
        ? AutomatoThemeColors.primaryColor(ref)
        : AutomatoThemeColors.darkBrown(ref);
    Color iconColor = state.isSelected
        ? AutomatoThemeColors.saveZone(ref)
        : AutomatoThemeColors.dangerZone(ref);

    return LayoutBuilder(
      builder: (context, constraints) {
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
                  ? Matrix4.translationValues(1, -1, -1)
                  : Matrix4.identity(),
              width: responsiveWidth,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Theme.of(context).highlightColor),
                boxShadow: state.isHovered
                    ? [
                        BoxShadow(
                          color: AutomatoThemeColors.darkBrown(ref)
                              .withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 0,
                          offset: const Offset(1, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AutomatoThemeColors.darkBrown(ref)
                              .withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: const Offset(1, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Tooltip(
                    message: state.selectedPath.isNotEmpty
                        ? state.selectedPath
                        : 'No directory selected',
                    child: Text(
                      state.selectedPath.isNotEmpty
                          ? state.selectedPath
                          : 'No directory selected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        state.isSelected ? Icons.check : icon,
                        color: iconColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.isSelected ? 'Selected' : 'Browse',
                        style: TextStyle(
                            color: iconColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (hints != null && !state.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        hints!,
                        style: TextStyle(
                          color: AutomatoThemeColors.primaryColor(ref),
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!enabled && hint != null && !state.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        hint!,
                        style: TextStyle(
                          color: AutomatoThemeColors.primaryColor(ref),
                          fontSize: 8.0,
                          fontWeight: FontWeight.bold,
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
