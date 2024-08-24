import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';

class SetupData {
  static SetupConfigData getCurrentSelectedSetup() {
    return setups.firstWhere(
      (setup) => setup.isSelected,
      orElse: () => throw StateError('No setup is currently selected'),
    );
  }

  static List<SetupConfigData> setups = [
    SetupConfigData(
      id: '1',
      imageUrl:
          'https://asset.vg247.com/NieR-Switch-Screen-2.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/NieR-Switch-Screen-2.jpg',
      title: 'FULL RANDOMIZED',
      description: 'All possible enemies will be randomized.',
      level: 'Unchanged',
      stats: 'Unchanged',
      arguments: [
        "{input}",
        "--output",
        "{output}",
        "ALL",
        "--enemies",
        "None",
        "--enemyStats",
        "0.0",
        "--level=1",
        "--category=default",
        "{ignore}"
      ],
    ),
    SetupConfigData(
      id: '2',
      imageUrl: 'https://i.ytimg.com/vi/v_P0HoB4HxE/maxresdefault.jpg',
      title: 'ANDROID MASSACRE',
      description: 'All possible enemies in the game will be Androids',
      level: 'Unchanged',
      stats: 'Unchanged',
      arguments: [
        "{input}",
        "--output",
        "{output}",
        "CUSTOM_SELECTED",
        "--enemies",
        "None",
        "--enemyStats",
        "0.0",
        "--level=1",
        generateGroundGroupArgument([
          "em1020",
          "em1070",
          "em1061",
          "em1060",
          "em1050",
          "em1030",
          "em1074"
        ], false, "em1040"),
        "--Fly=[]",
        generateDeleteGroupArgument(),
        "--category=default",
        "{ignore}"
      ],
      isSelected: false,
      showCheckbox: true,
      checkboxText: "Add 9S",
      onCheckboxChanged: (bool isChecked) {
        setups[1].updateGroundArgument(isChecked, "em1040");
      },
    ),
    SetupConfigData(
        id: '4',
        imageUrl:
            'https://lparchive.org/NieR-Automata/Update%2020/39-intoner_(48).jpg',
        title: 'NIGHTMARE',
        description:
            'All enemies max level and highest multiplier. No randomization.',
        level: '99',
        stats: 'x5.0',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "ALL",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "5.0",
          "--level=99",
          "--category=onlylevel",
          "{ignore}"
        ],
        isSelected: false),
  ];
}
