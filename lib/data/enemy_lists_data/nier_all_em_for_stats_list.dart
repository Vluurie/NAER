import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Enemy {
  String name;
  String imageUrl;
  List<String> emIdentifiers;
  bool isSelected;
  bool? dlcEnemy;

  Enemy(
      {required this.name,
      required this.imageUrl,
      required this.emIdentifiers,
      this.isSelected = false,
      this.dlcEnemy});
}

class EnemyList {
  static List<Enemy> getDLCFilteredEnemies(WidgetRef ref) {
    final hasDLC = ref.watch(globalStateProvider).hasDLC;
    return allEmForStatsChangeList.where((enemy) {
      return hasDLC || enemy.dlcEnemy != true;
    }).toList();
  }

  static final List<Enemy> allEmForStatsChangeList = [
    Enemy(
      name: 'A2',
      imageUrl: 'assets/nier_image_folders/nier_boss_images/em1030.png',
      emIdentifiers: ['em1030'],
    ),
    Enemy(
        name: '9S',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1040.png',
        emIdentifiers: ['em1040']),
    Enemy(
        name: 'Operator 21O',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1074.png',
        emIdentifiers: ['em1074']),
    Enemy(
        name: 'Engels',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1100.png',
        emIdentifiers: ['em1100, em1101']),
    Enemy(
        name: 'Marx',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1000.png',
        emIdentifiers: ['em1000']),
    Enemy(
        name: 'Simone',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em3000.png',
        emIdentifiers: ['em3000']),
    Enemy(
        name: 'Red Girl',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em7000.png',
        emIdentifiers: ['em7000', 'em7001']),
    Enemy(
        name: 'Grun',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em4000.png',
        emIdentifiers: ['em4000', 'em4010']),
    Enemy(
        name: 'Goliath Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0120.png',
        emIdentifiers: ['em0120']),
    Enemy(
        name: 'So-Shi',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em8000.png',
        emIdentifiers: ['em8000', 'em8001', 'em8801']),
    Enemy(
        name: 'Ro-Shi',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em8010.png',
        emIdentifiers: ['em8010']),
    Enemy(
        name: 'Ko-Shi',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em8020.png',
        emIdentifiers: ['em8020']),
    Enemy(
        name: 'Ro-Shi & Ko-Shi',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em8002.png',
        emIdentifiers: ['em8002']),
    Enemy(
        name: 'Auguste',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em2100.png',
        emIdentifiers: ['em2100', 'em2101']),
    Enemy(
        name: 'Adam',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em6000.png',
        emIdentifiers: ['em6000', 'em5100', 'em6200', 'em5300']),
    Enemy(
        name: 'Eve',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em5400.png',
        emIdentifiers: [
          'em5400',
          'em5000',
          'em5002',
          'em5200',
          'em5401',
          'em5500'
        ]),
    Enemy(
        name: 'Goliath Tank',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0110.png',
        emIdentifiers: ['em0110', 'em0111', 'emb0110', 'emb111']),
    Enemy(
        name: 'Emil',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1010.png',
        emIdentifiers: ['em1010', 'em8802', 'em8800']),
    Enemy(
        name: 'Masamune',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb054.png',
        emIdentifiers: ['emb054'],
        dlcEnemy: true),
    Enemy(
        name: 'Father Servo One',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb002.png',
        emIdentifiers: ['emb002']),
    Enemy(
        name: 'Father Servo Two',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb051.png',
        emIdentifiers: ['emb051']),
    Enemy(
        name: 'Father Servo Three',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb010.png',
        emIdentifiers: ['emb010']),
    Enemy(
        name: 'Father Servo Four',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb061.png',
        emIdentifiers: ['emb061']),
    Enemy(
        name: 'Father Servo Five',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb041.png',
        emIdentifiers: ['emb041']),
    Enemy(
        name: 'Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em4100.png',
        emIdentifiers: ['em4100', 'em4110']),
    Enemy(
        name: 'Simone Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em3010.png',
        emIdentifiers: ['em3010'],
        dlcEnemy: true),
    Enemy(
        name: 'Ro-Shi Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em8030.png',
        emIdentifiers: ['em8030'],
        dlcEnemy: true),
    Enemy(
        name: 'Adam Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em6400.png',
        emIdentifiers: ['em6400'],
        dlcEnemy: true),
    Enemy(
        name: 'Eve Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em5600.png',
        emIdentifiers: ['em5600'],
        dlcEnemy: true),
    Enemy(
        name: 'Tank Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0112.png',
        emIdentifiers: ['em0112'],
        dlcEnemy: true),
    Enemy(
        name: 'President',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em560d.png',
        emIdentifiers: ['em560d'],
        dlcEnemy: true),
    Enemy(
        name: 'Goliath Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em004d.png',
        emIdentifiers: ['em004d'],
        dlcEnemy: true),
    Enemy(
        name: 'Multileg Shade',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em002d.png',
        emIdentifiers: ['em002d'],
        dlcEnemy: true),
    Enemy(
        name: 'Ball',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em9001.png',
        emIdentifiers: ['em9000', 'em9001', 'em9002', 'em9003']),
    Enemy(
        name: 'Snake',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em9010.png',
        emIdentifiers: ['em9010', 'em9011']),
    Enemy(
        name: 'Cowboy Small Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb004.png',
        emIdentifiers: ['emb004']),
    Enemy(
        name: 'Cowboy Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb012.png',
        emIdentifiers: ['emb012']),
    Enemy(
        name: 'Zombie Machine sparking',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb052.png',
        emIdentifiers: ['emb052']),
    Enemy(
        name: 'Murder Blooded Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb056.png',
        emIdentifiers: ['emb056']),
    Enemy(
        name: 'Desert Goliath Tank',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb110.png',
        emIdentifiers: ['emb110']),
    Enemy(
        name: 'Shade Drill-Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em200d.png',
        emIdentifiers: ['em200d'],
        dlcEnemy: true),
    Enemy(
        name: 'YorHa Android Unit',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1050.png',
        emIdentifiers: ['em1050']),
    Enemy(
        name: 'YorHa Android Soldier Unit',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1060.png',
        emIdentifiers: ['em1060']),
    Enemy(
        name: 'YorHa Operator Unit',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1070.png',
        emIdentifiers: ['em1070']),
    Enemy(
        name: 'Deserted YorHa Unit',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1061.png',
        emIdentifiers: ['em1061']),
    Enemy(
        name: 'Religion Animal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0065.png',
        emIdentifiers: ['em0065']),
    Enemy(
        name: 'Operator 6O Boss',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1074.png',
        emIdentifiers: ['em1074']),
    Enemy(
        name: '2B Clone',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em1020.png',
        emIdentifiers: ['em1020']),
    Enemy(
        name: 'Godzilla Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb080.png',
        emIdentifiers: ['emb080']),
    Enemy(
        name: 'Animal Leader Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb060.png',
        emIdentifiers: ['emb060']),
    Enemy(
        name: 'Enhanced Stubby Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0006.png',
        emIdentifiers: ['em0006']),
    Enemy(
        name: 'Enhanced Multi-Body Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0106.png',
        emIdentifiers: ['em0106']),
    Enemy(
        name: 'Enhanced Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0056.png',
        emIdentifiers: ['em0056']),
    Enemy(
        name: 'Enhanced Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0016.png',
        emIdentifiers: ['em0016']),
    Enemy(
        name: 'Enhanced Animal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0066.png',
        emIdentifiers: ['em0066']),
    Enemy(
        name: 'Enhanced Humanoid Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0069.png',
        emIdentifiers: ['em0069']),
    Enemy(
        name: 'Enhanced Multi-Leg Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0026.png',
        emIdentifiers: ['em0026']),
    Enemy(
        name: 'Enhanced Goliath Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0046.png',
        emIdentifiers: ['em0046']),
    Enemy(
        name: 'Enhanced Goliath Legged Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0096.png',
        emIdentifiers: ['em0096']),
    Enemy(
        name: 'Enhanced Dino Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0086.png',
        emIdentifiers: ['em0086']),
    Enemy(
        name: 'Enhanced Drill Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em2006.png',
        emIdentifiers: ['em2006']),
    Enemy(
        name: 'Normal Machine with Explo Bomb',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em005a.png',
        emIdentifiers: ['em005a']),
    Enemy(
        name: 'Long Drill Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em2007.png',
        emIdentifiers: ['em2007']),
    Enemy(
        name: 'Religion Small Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0005.png',
        emIdentifiers: ['em0005']),
    Enemy(
        name: 'Small Stubby with Explo Bomb',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em000e.png',
        emIdentifiers: ['em000e']),
    Enemy(
        name: 'Religion Small Stubby with Explo Bomb',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em000d.png',
        emIdentifiers: ['em000d']),
    Enemy(
        name: 'Religion Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0055.png',
        emIdentifiers: ['em0055']),
    Enemy(
        name: 'Religion Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0015.png',
        emIdentifiers: ['em0015']),
    Enemy(
        name: 'Religion Humanoid Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0068.png',
        emIdentifiers: ['em0068']),
    Enemy(
        name: 'Forest Small Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0004.png',
        emIdentifiers: ['em0004']),
    Enemy(
        name: 'Forest Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0054.png',
        emIdentifiers: ['em0054']),
    Enemy(
        name: 'Forest Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0014.png',
        emIdentifiers: ['em0014']),
    Enemy(
        name: 'Forest Animal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0064.png',
        emIdentifiers: ['em0064']),
    Enemy(
        name: 'Forest Humanoid Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0067.png',
        emIdentifiers: ['em0067']),
    Enemy(
        name: 'Forest Legged Goliath Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0094.png',
        emIdentifiers: ['em0094']),
    Enemy(
        name: 'Amusement Park Small Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0003.png',
        emIdentifiers: ['em0003']),
    Enemy(
        name: 'Amusement Park Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0053.png',
        emIdentifiers: ['em0053']),
    Enemy(
        name: 'Amusement Park Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0013.png',
        emIdentifiers: ['em0013']),
    Enemy(
        name: 'Amusement Park Zombie Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb05a.png',
        emIdentifiers: ['emb05a']),
    Enemy(
        name: 'Amusement Park Zombie Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb015.png',
        emIdentifiers: ['emb015']),
    Enemy(
        name: 'Desert Small Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0002.png',
        emIdentifiers: ['em0002']),
    Enemy(
        name: 'Desert Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0052.png',
        emIdentifiers: ['em0052']),
    Enemy(
        name: 'Desert Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0012.png',
        emIdentifiers: ['em0012']),
    Enemy(
        name: 'Desert Goliath Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0042.png',
        emIdentifiers: ['em0042']),
    Enemy(
        name: 'Default Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0000.png',
        emIdentifiers: ['em0000']),
    Enemy(
        name: 'Default multi-body stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0100.png',
        emIdentifiers: ['em0100']),
    Enemy(
        name: 'Default Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0050.png',
        emIdentifiers: ['em0050']),
    Enemy(
        name: 'Default Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0010.png',
        emIdentifiers: ['em0010']),
    Enemy(
        name: 'Colosseum Champion Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb016.png',
        emIdentifiers: ['emb016'],
        dlcEnemy: true),
    Enemy(
        name: 'Default Animal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0060.png',
        emIdentifiers: ['em0060']),
    Enemy(
        name: 'Default Humanoid Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0061.png',
        emIdentifiers: ['em0061']),
    Enemy(
        name: 'Default Multi-Leg Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0020.png',
        emIdentifiers: ['em0020']),
    Enemy(
        name: 'Default Goliath',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0040.png',
        emIdentifiers: ['em0040']),
    Enemy(
        name: 'Default Legged Goliath',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0090.png',
        emIdentifiers: ['em0090']),
    Enemy(
        name: 'Default Dino Goliath',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0080.png',
        emIdentifiers: ['em0080']),
    Enemy(
        name: 'Explosion Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em005c.png',
        emIdentifiers: ['em005c']),
    Enemy(
        name: 'Explosion Biped Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em001c.png',
        emIdentifiers: ['em001c']),
    Enemy(
        name: 'Drill Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em2001.png',
        emIdentifiers: ['em2001']),
    Enemy(
        name: 'Drill Machine Long',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em2002.png',
        emIdentifiers: ['em2002']),
    Enemy(
        name: 'Angry Stubby',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0007.png',
        emIdentifiers: ['em0007']),
    Enemy(
        name: 'Angry Normal Machine',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0057.png',
        emIdentifiers: ['em0057']),
    Enemy(
        name: 'Angry Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0017.png',
        emIdentifiers: ['em0017']),
    Enemy(
        name: 'Goliath Ball',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em9000.png',
        emIdentifiers: ['em9000']),
    Enemy(
        name: 'Animal Enhanced',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/ema001.png',
        emIdentifiers: ['ema001']),
    Enemy(
        name: 'Animal Default',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/ema002.png',
        emIdentifiers: ['ema002']),
    Enemy(
        name: 'Animal Default',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/ema010.png',
        emIdentifiers: ['ema010']),
    Enemy(
        name: 'Animal Enhanced',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/ema011.png',
        emIdentifiers: ['ema011']),
    Enemy(
        name: 'Gravekeeper Shield Biped',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb014.png',
        emIdentifiers: ['emb014']),
    Enemy(
        name: 'Default Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0030.png',
        emIdentifiers: ['em0030']),
    Enemy(
        name: 'Desert Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0032.png',
        emIdentifiers: ['em0032']),
    Enemy(
        name: 'Amusement Park Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0033.png',
        emIdentifiers: ['em0033']),
    Enemy(
        name: 'Forest Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0034.png',
        emIdentifiers: ['em0034']),
    Enemy(
        name: 'Religion Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0035.png',
        emIdentifiers: ['em0035']),
    Enemy(
        name: 'Enhanced Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em0036.png',
        emIdentifiers: ['em0036']),
    Enemy(
        name: 'Cowboy Flyer',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/emb031.png',
        emIdentifiers: ['emb031']),
    Enemy(
        name: 'Android Hack Scarecrow',
        imageUrl: 'assets/nier_image_folders/nier_boss_images/em3004.png',
        emIdentifiers: ['em3004']),
  ];
}
