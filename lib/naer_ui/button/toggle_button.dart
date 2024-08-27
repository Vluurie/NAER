import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToggleButton extends ConsumerWidget {
  final bool isSelected;
  final String onLabel;
  final String offLabel;
  final VoidCallback onToggle;
  final Color selectedColor;
  final Color unselectedColor;

  const ToggleButton({
    super.key,
    required this.isSelected,
    required this.onLabel,
    required this.offLabel,
    required this.onToggle,
    this.selectedColor = Colors.red,
    this.unselectedColor = Colors.green,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return ElevatedButton(
      onPressed: onToggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? selectedColor : unselectedColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
      child: Text(
        isSelected ? onLabel : offLabel,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AutomatoThemeColors.primaryColor(ref),
        ),
      ),
    );
  }
}

class CustomSetupToggle extends ConsumerWidget {
  const CustomSetupToggle({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final globalStateNotifier = ref.watch(globalStateProvider.notifier);
    final globalState = ref.watch(globalStateProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          ToggleButton(
            isSelected: globalState.customSelection,
            onLabel: 'Predefined Setup',
            offLabel: 'Custom Modify',
            selectedColor: AutomatoThemeColors.darkBrown(ref),
            unselectedColor: AutomatoThemeColors.darkBrown(ref),
            onToggle: () {
              globalStateNotifier.toggleCustomSelection();
            },
          ),
        ],
      ),
    );
  }
}
