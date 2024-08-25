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
      imageUrl: 'https://giffiles.alphacoders.com/121/121877.gif',
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
    SetupConfigData(
        id: '5',
        imageUrl:
            'https://64.media.tumblr.com/cae34b09f91f7fc74a2f43627a9c84c3/tumblr_omixx0Y4SI1uq6svio2_r1_540.gif',
        title: 'BOSS BLOODBATH',
        description:
            'All possible enemies that can be randomized will be Bosses that can be used for modification.',
        level: '1',
        stats: '0.0',
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
          '--Ground=["em004d", "em0112", "emb110", "em1030", "em1040", "em1061", "em1074", "em5600", "em6400", "em3010", "em8030", "emb05d", "emb016", "emb014", "emb060", "emb080", "em9000", "emb010", "em002d", "emb056"]',
          "--Fly=[]",
          generateDeleteGroupArgument(),
          "--category=default",
          "{ignore}"
        ],
        isSelected: false,
        isAddition: true),
    SetupConfigData(
        id: '6',
        imageUrl: 'https://i.imgur.com/nrkU0lH.png',
        title: 'Higher Stats Only',
        description: 'Changes only enemy stats to x2.',
        level: '1',
        stats: 'x2.0',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "2.0",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isSelected: false,
        isAddition: true),
    SetupConfigData(
        id: '7',
        imageUrl: 'https://i.imgur.com/nrkU0lH.png',
        title: 'Higher Stats Only',
        description: 'Changes only enemy stats to x3.',
        level: '1',
        stats: 'x3.0',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "3.0",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isSelected: false,
        isAddition: true),
    SetupConfigData(
        id: '8',
        imageUrl: 'https://i.imgur.com/nrkU0lH.png',
        title: 'Higher Stats Only',
        description: 'Changes only enemy stats to x4.',
        level: '1',
        stats: 'x4.0',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "4.0",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isSelected: false,
        isAddition: true),
    SetupConfigData(
        id: '9',
        imageUrl: 'https://i.imgur.com/nrkU0lH.png',
        title: 'Higher Stats Only',
        description: 'Changes only enemy stats to x5.',
        level: '1',
        stats: 'x5.0',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "5.0",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isSelected: false,
        isAddition: true),
  ];
}
