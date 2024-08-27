import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/addition_utils.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_utils.dart';
import 'package:NAER/naer_utils/state_provider/addition_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automato_theme/automato_theme.dart';

class SetupList extends ConsumerStatefulWidget {
  const SetupList({super.key});

  @override
  SetupListState createState() => SetupListState();
}

class SetupListState extends ConsumerState<SetupList> {
  late final SetupUtils setupUtils;
  late final AdditionsUtils additionsUtils;

  @override
  void initState() {
    super.initState();
    setupUtils = SetupUtils(ref, context);
    additionsUtils = AdditionsUtils(ref, context);
  }

  @override
  Widget build(BuildContext context) {
    final setups = ref.watch(setupConfigProvider);
    final additions = ref.watch(additionConfigProvider);
    final selectedSetupId = ref.watch(setupStateProvider);

    for (var setup in setups) {
      setup.isSelected = setup.id == selectedSetupId;
    }

    setups.sort((a, b) {
      final isCustomA = !SetupData.setups.any((s) => s.id == a.id);
      final isCustomB = !SetupData.setups.any((s) => s.id == b.id);
      if (isCustomA && !isCustomB) return -1;
      if (!isCustomA && isCustomB) return 1;
      return 0;
    });

    additions.sort((a, b) {
      final isCustomA = !SetupData.additions.any((s) => s.id == a.id);
      final isCustomB = !SetupData.additions.any((s) => s.id == b.id);
      if (isCustomA && !isCustomB) return -1;
      if (!isCustomA && isCustomB) return 1;
      return 0;
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: _buildItemsGrid(context, setups, isSetup: true),
          ),
          _buildHeader(context, "Additions"),
          // Container for additions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildItemsGrid(context, additions, isSetup: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      color: AutomatoThemeColors.darkBrown(ref),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          color: AutomatoThemeColors.primaryColor(ref),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, List<SetupConfigData> items,
      {required bool isSetup}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1600) {
          crossAxisCount = 6;
          childAspectRatio = 5 / 8.0;
        } else if (constraints.maxWidth > 1400) {
          crossAxisCount = 5;
          childAspectRatio = 5 / 7.5;
        } else if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 5 / 6.2;
        } else if (constraints.maxWidth > 1000) {
          crossAxisCount = 3;
          childAspectRatio = 6 / 5.5;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
          childAspectRatio = 5 / 6.0;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 2;
          childAspectRatio = 5 / 6;
        } else if (constraints.maxWidth > 700) {
          crossAxisCount = 2;
          childAspectRatio = 5 / 5.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 5 / 5;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 1;
          childAspectRatio = 5 / 4.75;
        } else if (constraints.maxWidth > 400) {
          crossAxisCount = 1;
          childAspectRatio = 5 / 4.5;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 5 / 4.25;
        }

        if (crossAxisCount > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isCustom = !SetupData.setups.any((s) => s.id == item.id) &&
                  !SetupData.additions.any((s) => s.id == item.id);

              return DynamicCard(
                configData: item,
                onToggleSelection: () {
                  if (isSetup) {
                    setupUtils.toggleSetupSelection(item);
                  } else {
                    additionsUtils.toggleAdditionSelection(item);
                  }
                },
                onDelete: isCustom
                    ? () {
                        if (isSetup) {
                          setupUtils.deleteSetup(item);
                        } else {
                          additionsUtils.deleteAddition(item);
                        }
                      }
                    : null,
                showCheckbox: item.showCheckbox,
                onCheckboxChanged: item.onCheckboxChanged,
                checkboxText: item.checkboxText,
                isSetup: isSetup,
                isAddition: !isSetup,
              );
            },
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isCustom = !SetupData.setups.any((s) => s.id == item.id) &&
                  !SetupData.additions.any((s) => s.id == item.id);

              return DynamicCard(
                configData: item,
                onToggleSelection: () {
                  if (isSetup) {
                    setupUtils.toggleSetupSelection(item);
                  } else {
                    additionsUtils.toggleAdditionSelection(item);
                  }
                },
                onDelete: isCustom
                    ? () {
                        if (isSetup) {
                          setupUtils.deleteSetup(item);
                        } else {
                          additionsUtils.deleteAddition(item);
                        }
                      }
                    : null,
                showCheckbox: item.showCheckbox,
                onCheckboxChanged: item.onCheckboxChanged,
                checkboxText: item.checkboxText,
                isSetup: isSetup,
                isAddition: !isSetup,
              );
            },
          );
        }
      },
    );
  }
}
