import 'package:NAER/naer_ui/setup/config_list/tabbar_with_loading.dart';
import 'package:NAER/naer_ui/setup/flutter_carousel_desktop.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/addition_utils.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_card.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_utils.dart';
import 'package:NAER/naer_utils/state_provider/addition_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';

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
  Widget build(final BuildContext context) {
    final setups = ref.watch(setupConfigProvider);
    final additions = ref.watch(additionConfigProvider);
    final selectedSetupId = ref.watch(setupStateProvider);
    final globalState = ref.watch(globalStateProvider);

    for (var setup in setups) {
      setup.isSelected = setup.id == selectedSetupId;
    }

    setups.sort((final a, final b) {
      final isCustomA = !SetupData.setups.any((final s) => s.id == a.id);
      final isCustomB = !SetupData.setups.any((final s) => s.id == b.id);
      if (isCustomA && !isCustomB) return -1;
      if (!isCustomA && isCustomB) return 1;
      return 0;
    });

    additions.sort((final a, final b) {
      final isCustomA = !SetupData.additions.any((final s) => s.id == a.id);
      final isCustomB = !SetupData.additions.any((final s) => s.id == b.id);
      if (isCustomA && !isCustomB) return -1;
      if (!isCustomA && isCustomB) return 1;
      return 0;
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AutomatoThemeColors.transparentColor(ref),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AutomatoThemeColors.darkBrown(ref),
                    AutomatoThemeColors.darkBrown(ref),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.5),
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: TabBarWithLoadingOverlay(
                tabBar: TabBar(
                  unselectedLabelColor:
                      AutomatoThemeColors.primaryColor(ref).withOpacity(0.5),
                  labelColor: AutomatoThemeColors.primaryColor(ref),
                  dividerColor:
                      AutomatoThemeColors.primaryColor(ref).withOpacity(0.5),
                  indicatorColor: AutomatoThemeColors.primaryColor(ref),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (final Set<WidgetState> states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AutomatoThemeColors.bright(ref).withOpacity(0.5);
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return AutomatoThemeColors.bright(ref).withOpacity(0.5);
                      }
                      return null;
                    },
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 20.0,
                  ),
                  tabs: const [
                    Tab(text: 'Setups'),
                    Tab(text: 'Additions'),
                  ],
                ),
                isLoading: globalState.isLoading,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCarouselView(context, setups, isSetup: true),
                  _buildCarouselView(context, additions, isSetup: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselView(
      final BuildContext context, final List<SetupConfigData> items,
      {required final bool isSetup}) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      child: CarouselViewDesktopSupport(
        backgroundColor: AutomatoThemeColors.transparentColor(ref),
        useDesktop: true,
        itemExtent: 300.0,
        shrinkExtent: 300.0,
        children: items.map((final item) {
          final isCustom =
              !SetupData.setups.any((final s) => s.id == item.id) &&
                  !SetupData.additions.any((final s) => s.id == item.id);

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
        }).toList(),
      ),
    );
  }
}
