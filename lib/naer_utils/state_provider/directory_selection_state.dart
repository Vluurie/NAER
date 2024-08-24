import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectorySelectionCardState {
  final bool isSelected;
  final bool isHovered;
  final String selectedPath;

  DirectorySelectionCardState({
    required this.isSelected,
    required this.isHovered,
    required this.selectedPath,
  });

  DirectorySelectionCardState copyWith({
    bool? isSelected,
    bool? isHovered,
    String? selectedPath,
  }) {
    return DirectorySelectionCardState(
      isSelected: isSelected ?? this.isSelected,
      isHovered: isHovered ?? this.isHovered,
      selectedPath: selectedPath ?? this.selectedPath,
    );
  }
}

class DirectorySelectionCardStateNotifier
    extends StateNotifier<DirectorySelectionCardState> {
  DirectorySelectionCardStateNotifier(String initialPath)
      : super(DirectorySelectionCardState(
          isSelected: initialPath.isNotEmpty,
          isHovered: false,
          selectedPath: initialPath,
        ));

  void updatePath(String newPath) {
    state = state.copyWith(
      isSelected: newPath.isNotEmpty,
      selectedPath: newPath,
    );
  }

  void setHovered(bool hovered) {
    state = state.copyWith(isHovered: hovered);
  }
}
