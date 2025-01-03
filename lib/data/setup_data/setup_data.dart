import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';

class SetupData {
  static SetupConfigData getCurrentSelectedSetup() {
    return setups.firstWhere(
      (final setup) => setup.isSelected,
      orElse: () => throw StateError('No setup is currently selected'),
    );
  }

  static List<SetupConfigData> setups = [
    SetupConfigData(
      id: '1',
      imageUrl: 'assets/setups_images/full_randomized.jpg',
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
      imageUrl: 'assets/setups_images/android_massacre.gif',
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
        ], "em1040", isChecked: false),
        "--Fly=[]",
        generateDeleteGroupArgument(),
        "--category=default",
        "{ignore}"
      ],
      showCheckbox: true,
      checkboxText: "Add 9S",
      onCheckboxChanged: (final bool isChecked) {
        setups[1].updateGroundArgument("em1040", isChecked: isChecked);
      },
    ),
    SetupConfigData(
        id: '4',
        imageUrl: 'assets/setups_images/nightmare.jpg',
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
          "3.0",
          "--level=99",
          "--category=onlylevel",
          "{ignore}"
        ]),
    SetupConfigData(
        id: '5',
        imageUrl: 'assets/setups_images/boss_bloodpath.gif',
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
        isSelected: true,
        isAddition: false,
        doesUseDlc: true),
  ];

  static List<SetupConfigData> additions = [
    SetupConfigData(
        id: '10',
        imageUrl: 'assets/setups_images/lesser_stats.png',
        title: 'Lesser Enemy Stats',
        description: 'Reduces all enemy Stats by 50%.',
        level: '1',
        stats: '-50%',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "0.5",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isAddition: true),
    SetupConfigData(
        id: '11',
        imageUrl: 'assets/setups_images/lesser_stats.png',
        title: 'Lesser Enemy Stats',
        description: 'Reduces all enemy Stats by 30%.',
        level: '1',
        stats: '-30%',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "0.7",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isAddition: true),
    SetupConfigData(
        id: '6',
        imageUrl: 'assets/setups_images/higher_stats.png',
        title: 'Higher Enemy Stats',
        description: 'Increases all enemy stats by 50%.',
        level: '1',
        stats: '50%',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "1.5",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isAddition: true),
    SetupConfigData(
        id: '7',
        imageUrl: 'assets/setups_images/higher_stats.png',
        title: 'Higher Enemy Stats',
        description: 'Increases all enemy stats by 100%.',
        level: '1',
        stats: '100%',
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
        isAddition: true),
    SetupConfigData(
        id: '8',
        imageUrl: 'assets/setups_images/higher_stats.png',
        title: 'Higher Enemy Stats',
        description: 'Increases all enemy stats by 150%.',
        level: '1',
        stats: '150%',
        arguments: [
          "{input}",
          "--output",
          "{output}",
          "--q300",
          "--enemies",
          getArgForAllEnemiesForStatsChange(),
          "--enemyStats",
          "2.5",
          "--level=1",
          "--category=onlylevel",
          "{ignore}"
        ],
        isAddition: true),
    SetupConfigData(
        id: '9',
        imageUrl: 'assets/setups_images/higher_stats.png',
        title: 'Higher Enemy Stats',
        description: 'Increases all enemy stats by 200%.',
        level: '1',
        stats: '200%',
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
        isAddition: true),
  ];
}
