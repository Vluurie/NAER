import 'package:NAER/naer_ui/setup/config_list/config_data_container.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupCard extends ConsumerStatefulWidget {
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
  SetupCardState createState() => SetupCardState();
}

class SetupCardState extends ConsumerState<SetupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);
    final isLoading = globalState.isLoading;
    final isSelected = widget.configData.isSelected;

    bool isButtonDisabled = isLoading && !isSelected;

    return Opacity(
      opacity: isButtonDisabled ? 0.5 : 1.0,
      child: Stack(
        children: [
          Card(
            color: AutomatoThemeColors.darkBrown(ref),
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: isSelected && isLoading
                  ? BorderSide.none
                  : BorderSide(
                      color: AutomatoThemeColors.transparentColor(ref),
                      width: 4.0,
                    ),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.configData.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 90,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.configData.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.configData.level == '1')
                    const Text(
                      'Levels: Unchanged',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (widget.configData.level != '1')
                    Text(
                      'Levels: ${widget.configData.level}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 6),
                  if (widget.configData.stats == '0.0')
                    const Text(
                      'Stats: Unchanged',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (widget.configData.stats != '0.0')
                    Text(
                      'Stats: ${widget.configData.stats}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: SingleChildScrollView(
                        child: Text(
                          widget.configData.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  if (widget.showCheckbox && !widget.configData.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CheckboxListTile(
                        fillColor: ref.watch(checkboxStateProvider)
                            ? WidgetStatePropertyAll(
                                AutomatoThemeColors.primaryColor(ref))
                            : WidgetStatePropertyAll(
                                AutomatoThemeColors.transparentColor(ref)),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          widget.checkboxText ?? 'Enable Custom Behavior',
                          style: const TextStyle(fontSize: 16),
                        ),
                        value: ref.watch(checkboxStateProvider),
                        onChanged: isButtonDisabled
                            ? null
                            : (bool? value) {
                                ref
                                    .read(checkboxStateProvider.notifier)
                                    .toggle(value ?? false);

                                if (widget.onCheckboxChanged != null) {
                                  widget.onCheckboxChanged!(value ?? false);
                                }
                              },
                      ),
                    ),
                  const SizedBox(height: 6),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: AutomatoButton(
                        stopColorAnimation:
                            isButtonDisabled || (isSelected && isLoading),
                        stopBorderAnimation:
                            isButtonDisabled || (isSelected && isLoading),
                        stopFillAnimation:
                            isButtonDisabled || (isSelected && isLoading),
                        fontSize: 30,
                        letterSpacing: 1.5,
                        baseColor: isSelected && isLoading
                            ? AutomatoThemeColors.primaryColor(ref)
                                .withOpacity(0.6)
                            : AutomatoThemeColors.primaryColor(ref),
                        startColor: isSelected && isLoading
                            ? AutomatoThemeColors.saveZone(ref)
                            : widget.configData.isSelected
                                ? AutomatoThemeColors.dangerZone(ref)
                                : AutomatoThemeColors.darkBrown(ref),
                        maxScale: 0.8,
                        showPointer: false,
                        label: isSelected && isLoading
                            ? 'Installing...'
                            : widget.configData.isSelected
                                ? 'Undo Setup'
                                : 'Start Setup',
                        onPressed: isButtonDisabled
                            ? () {} // do nothing :)
                            : () => widget.onToggleSelection!(),
                        uniqueId: 'setup',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected && isLoading)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        width: 8.0,
                        color: AutomatoThemeColors.transparentColor(ref),
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          colors: [
                            AutomatoThemeColors.bright(ref),
                            AutomatoThemeColors.brown025(ref),
                          ],
                          stops: [_animation.value, _animation.value + 0.5],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.mirror,
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.srcIn,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            width: 8.0,
                            color: AutomatoThemeColors.bright(ref),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AutomatoThemeColors.bright(ref)
                                  .withOpacity(0.6),
                              blurRadius: 15.0,
                              spreadRadius: 5.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: Visibility(
              visible: widget.onDelete != null,
              child: InkResponse(
                onTap: isButtonDisabled ? null : widget.onDelete,
                borderRadius: BorderRadius.circular(8.0),
                radius: 16.0,
                splashColor:
                    AutomatoThemeColors.dangerZone(ref).withOpacity(0.3),
                highlightColor: AutomatoThemeColors.transparentColor(ref),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AutomatoThemeColors.dangerZone(ref).withOpacity(0.1),
                  ),
                  child: Icon(Icons.close,
                      color: AutomatoThemeColors.dangerZone(ref), size: 18.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
