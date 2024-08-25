import 'package:NAER/naer_ui/setup/config_list/config_data_container.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';

import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupCard extends ConsumerWidget {
  final ConfigDataContainer configData;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onDelete;
  final bool showCheckbox;
  final ValueChanged<bool>? onCheckboxChanged;
  final String? checkboxText;

  const SetupCard({
    super.key,
    required this.configData,
    this.onToggleSelection,
    this.onDelete,
    this.showCheckbox = false,
    this.onCheckboxChanged,
    this.checkboxText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCheckboxChecked = ref.watch(checkboxStateProvider);
    final globalState = ref.watch(globalStateProvider);

    bool isButtonDisabled = globalState.isLoading;

    return Card(
      color: AutomatoThemeColors.darkBrown(ref),
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    configData.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 90,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  configData.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (configData.level == '1')
                  const Text(
                    'Levels: Unchanged',
                    style: TextStyle(fontSize: 16),
                  ),
                if (configData.level != '1')
                  Text(
                    'Levels: ${configData.level}',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 6),
                if (configData.stats == '0.0')
                  const Text(
                    'Stats: Unchanged',
                    style: TextStyle(fontSize: 16),
                  ),
                if (configData.stats != '0.0')
                  Text(
                    'Stats: ${configData.stats}',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 6),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: SingleChildScrollView(
                      child: Text(
                        configData.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                if (showCheckbox && !configData.isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CheckboxListTile(
                      fillColor: isCheckboxChecked
                          ? WidgetStatePropertyAll(
                              AutomatoThemeColors.primaryColor(ref))
                          : WidgetStatePropertyAll(
                              AutomatoThemeColors.transparentColor(ref)),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        checkboxText ?? 'Enable Custom Behavior',
                        style: const TextStyle(fontSize: 16),
                      ),
                      value: isCheckboxChecked,
                      onChanged: (bool? value) {
                        ref
                            .read(checkboxStateProvider.notifier)
                            .toggle(value ?? false);

                        if (onCheckboxChanged != null) {
                          onCheckboxChanged!(value ?? false);
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 6),
                Center(
                  child: Opacity(
                    opacity: isButtonDisabled ? 0.1 : 1.0,
                    child: SizedBox(
                      width: double.infinity,
                      child: AutomatoButton(
                        stopColorAnimation: isButtonDisabled ? true : false,
                        stopBorderAnimation: isButtonDisabled ? true : false,
                        stopFillAnimation: isButtonDisabled ? true : false,
                        fontSize: 30,
                        letterSpacing: 1.5,
                        baseColor: AutomatoThemeColors.primaryColor(ref),
                        startColor: configData.isSelected
                            ? AutomatoThemeColors.dangerZone(ref)
                            : AutomatoThemeColors.darkBrown(ref),
                        maxScale: 0.8,
                        showPointer: false,
                        label: configData.isSelected
                            ? 'Undo Setup'
                            : 'Start Setup',
                        onPressed: () => onToggleSelection!(),
                        uniqueId: 'setup',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Visibility(
              visible: onDelete != null,
              child: InkResponse(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8.0),
                radius: 16.0,
                splashColor: Colors.red.withOpacity(0.3),
                highlightColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.close, color: Colors.red, size: 18.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
