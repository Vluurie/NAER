import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_utils.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupList extends ConsumerStatefulWidget {
  const SetupList({super.key});

  @override
  SetupListState createState() => SetupListState();
}

class SetupListState extends ConsumerState<SetupList> {
  @override
  Widget build(BuildContext context) {
    final setups = ref.watch(setupConfigProvider);
    final selectedSetupId = ref.watch(setupStateProvider);
    final SetupUtils setupUtils = SetupUtils(ref, context);

    for (var setup in setups) {
      setup.isSelected = setup.id == selectedSetupId;
    }

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
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: setups.length,
            itemBuilder: (context, index) {
              final setup = setups[index];
              final isCustom = !SetupData.setups.any((s) => s.id == setup.id);

              return SetupCard(
                configData: setup,
                onToggleSelection: () => setupUtils.toggleSetupSelection(setup),
                onDelete: isCustom ? () => setupUtils.deleteSetup(setup) : null,
                showCheckbox: setup.showCheckbox,
                onCheckboxChanged: setup.onCheckboxChanged,
                checkboxText: setup.checkboxText,
              );
            },
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: setups.length,
            itemBuilder: (context, index) {
              final setup = setups[index];
              final isCustom = !SetupData.setups.any((s) => s.id == setup.id);

              return SetupCard(
                configData: setup,
                onToggleSelection: () => setupUtils.toggleSetupSelection(setup),
                onDelete: isCustom ? () => setupUtils.deleteSetup(setup) : null,
                showCheckbox: setup.showCheckbox,
                onCheckboxChanged: setup.onCheckboxChanged,
                checkboxText: setup.checkboxText,
              );
            },
          );
        }
      },
    );
  }
}
