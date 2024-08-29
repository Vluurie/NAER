import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_ui/setup/config_list/config_data_container.dart';
import 'package:automato_theme/automato_theme.dart';

final setupLoadingProvider = StateProvider<String?>((final ref) => null);
final additionLoadingProvider = StateProvider<String?>((final ref) => null);

class DynamicCard extends ConsumerStatefulWidget {
  final ConfigDataContainer configData;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onDelete;
  final bool showCheckbox;
  final ValueChanged<bool>? onCheckboxChanged;
  final String? checkboxText;
  final bool isSetup;
  final bool isAddition;

  const DynamicCard({
    super.key,
    required this.configData,
    this.onToggleSelection,
    this.onDelete,
    this.showCheckbox = false,
    this.onCheckboxChanged,
    this.checkboxText,
    this.isSetup = false,
    this.isAddition = false,
  });

  @override
  DynamicCardState createState() => DynamicCardState();
}

class DynamicCardState extends ConsumerState<DynamicCard>
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
  Widget build(final BuildContext context) {
    final setupLoadingId = ref.watch(setupLoadingProvider);
    final additionLoadingId = ref.watch(additionLoadingProvider);

    final isSetupLoading =
        widget.isSetup && setupLoadingId == widget.configData.id;
    final isAdditionLoading =
        widget.isAddition && additionLoadingId == widget.configData.id;
    final isLoading = setupLoadingId != null || additionLoadingId != null;

    final isSelected = widget.configData.isSelected;

    bool isButtonDisabled = isLoading && !isSetupLoading && !isAdditionLoading;

    return Opacity(
      opacity: isButtonDisabled ? 0.5 : 1.0,
      child: Stack(
        children: [
          Card(
            color: _getCardColor(isSetupLoading, isAdditionLoading),
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
                    child: widget.configData.imageUrl.startsWith('http')
                        ? Image.network(
                            widget.configData.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 90,
                          )
                        : Image.asset(
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
                  _buildLevelInfo(),
                  const SizedBox(height: 6),
                  _buildStatsInfo(),
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
                            : (final bool? value) {
                                ref
                                    .read(checkboxStateProvider.notifier)
                                    .toggle(shouldToggle: value ?? false);

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
                        stopColorAnimation: isButtonDisabled ||
                            isLoading && !isSetupLoading && !isAdditionLoading,
                        stopBorderAnimation: isButtonDisabled ||
                            isLoading && !isSetupLoading && !isAdditionLoading,
                        stopFillAnimation: isButtonDisabled ||
                            isLoading && !isSetupLoading && !isAdditionLoading,
                        fontSize: 30,
                        letterSpacing: 1.5,
                        baseColor:
                            isLoading && (isSetupLoading || isAdditionLoading)
                                ? AutomatoThemeColors.primaryColor(ref)
                                    .withOpacity(0.6)
                                : AutomatoThemeColors.primaryColor(ref),
                        startColor:
                            isLoading && (isSetupLoading || isAdditionLoading)
                                ? AutomatoThemeColors.saveZone(ref)
                                : widget.configData.isSelected
                                    ? AutomatoThemeColors.dangerZone(ref)
                                    : AutomatoThemeColors.darkBrown(ref),
                        maxScale: 0.8,
                        showPointer: false,
                        label: _buildButtonLabel(
                            isSelected, isSetupLoading, isAdditionLoading),
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
          if (isSelected && (isSetupLoading || isAdditionLoading))
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (final context, final _) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        width: 8.0,
                        color: AutomatoThemeColors.transparentColor(ref),
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: (final rect) {
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

  Color _getCardColor(final bool isSetupLoading, final bool isAdditionLoading) {
    if (isSetupLoading || isAdditionLoading) {
      return AutomatoThemeColors.darkBrown(ref);
    } else if (widget.isSetup) {
      return AutomatoThemeColors.darkBrown(ref);
    } else if (widget.isAddition) {
      return AutomatoThemeColors.brown25(ref);
    }
    return AutomatoThemeColors.darkBrown(ref);
  }

  String _buildButtonLabel(final bool isSelected, final bool isSetupLoading,
      final bool isAdditionLoading) {
    if (isSetupLoading || isAdditionLoading) {
      return isSelected ? 'Installing...' : 'Applying...';
    } else if (isSelected) {
      return widget.isSetup ? 'Undo Setup' : 'Remove Addition';
    } else {
      return widget.isSetup ? 'Start Setup' : 'Apply Addition';
    }
  }

  Widget _buildLevelInfo() {
    if (widget.isSetup) {
      return widget.configData.level == '1'
          ? const Text(
              'Levels: Unchanged',
              style: TextStyle(fontSize: 16),
            )
          : Text(
              'Levels: ${widget.configData.level}',
              style: const TextStyle(fontSize: 16),
            );
    } else if (widget.isAddition) {
      return const Text(
        'Additional Feature',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    } else {
      return Container();
    }
  }

  Widget _buildStatsInfo() {
    if (widget.isSetup) {
      return widget.configData.stats == '0.0'
          ? const Text(
              'Stats: Unchanged',
              style: TextStyle(fontSize: 16),
            )
          : Text(
              'Stats: ${widget.configData.stats}',
              style: const TextStyle(fontSize: 16),
            );
    } else if (widget.isAddition) {
      return const Text(
        'Enhances Setup',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    } else {
      return Container();
    }
  }
}
