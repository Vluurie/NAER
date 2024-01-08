class Boss {
  String name;
  String imageUrl;
  List<String> emIdentifiers;
  bool isSelected;

  Boss({
    required this.name,
    required this.imageUrl,
    required this.emIdentifiers,
    this.isSelected = false,
  });
}

List<Boss> bossList = [
  Boss(
      name: 'A2',
      imageUrl: 'assets/bosses/em1030.png',
      emIdentifiers: ['em1030']),
  Boss(
      name: '9S',
      imageUrl: 'assets/bosses/em1040.png',
      emIdentifiers: ['em1040']),
  Boss(
      name: 'Operator 21O',
      imageUrl: 'assets/bosses/em1074.png',
      emIdentifiers: ['em1074']),
  Boss(
      name: 'Engels',
      imageUrl: 'assets/bosses/em1100.png',
      emIdentifiers: ['em1100, em1101']),
  Boss(
      name: 'Marx',
      imageUrl: 'assets/bosses/em1000.png',
      emIdentifiers: ['em1000']),
  Boss(
      name: 'Simone',
      imageUrl: 'assets/bosses/em3000.png',
      emIdentifiers: ['em3000']),
  Boss(
      name: 'Red Girl',
      imageUrl: 'assets/bosses/em7000.png',
      emIdentifiers: ['em7000', 'em7001']),
  Boss(
      name: 'Grun',
      imageUrl: 'assets/bosses/em4000.png',
      emIdentifiers: ['em4000', 'em4010']),
  Boss(
      name: 'Goliath Flyer',
      imageUrl: 'assets/bosses/em0120.png',
      emIdentifiers: ['em0120']),
  Boss(
      name: 'So-Shi',
      imageUrl: 'assets/bosses/em8000.png',
      emIdentifiers: ['em8000', 'em8001', 'em8801']),
  Boss(
      name: 'Ro-Shi',
      imageUrl: 'assets/bosses/em8010.png',
      emIdentifiers: ['em8010']),
  Boss(
      name: 'Ko-Shi',
      imageUrl: 'assets/bosses/em8020.png',
      emIdentifiers: ['em8020']),
  Boss(
      name: 'Ro-Shi & Ko-Shi',
      imageUrl: 'assets/bosses/em8002.png',
      emIdentifiers: ['em8002']),
  Boss(
      name: 'Auguste',
      imageUrl: 'assets/bosses/em2100.png',
      emIdentifiers: ['em2100', 'em2101']),
  Boss(
      name: 'Adam',
      imageUrl: 'assets/bosses/em6000.png',
      emIdentifiers: ['em6000', 'em5100', 'em6200', 'em5300']),
  Boss(name: 'Eve', imageUrl: 'assets/bosses/em5400.png', emIdentifiers: [
    'em5400',
    'em5000',
    'em5002',
    'em5200',
    'em5401',
    'em5500'
  ]),
  Boss(
      name: 'Goliath Tank',
      imageUrl: 'assets/bosses/em0110.png',
      emIdentifiers: ['em0110', 'em0111', 'emb0110', 'emb111']),
  Boss(
      name: 'Emil',
      imageUrl: 'assets/bosses/em1010.png',
      emIdentifiers: ['em1010', 'em8802', 'em8800']),
  Boss(
      name: 'Masamune',
      imageUrl: 'assets/bosses/emb054.png',
      emIdentifiers: ['emb054']),
  Boss(
      name: 'Father Servo One',
      imageUrl: 'assets/bosses/emb002.png',
      emIdentifiers: ['emb002']),
  Boss(
      name: 'Father Servo Two',
      imageUrl: 'assets/bosses/emb051.png',
      emIdentifiers: ['emb051']),
  Boss(
      name: 'Father Servo Three',
      imageUrl: 'assets/bosses/emb010.png',
      emIdentifiers: ['emb010']),
  Boss(
      name: 'Father Servo Four',
      imageUrl: 'assets/bosses/emb061.png',
      emIdentifiers: ['emb061']),
  Boss(
      name: 'Father Servo Five',
      imageUrl: 'assets/bosses/emb041.png',
      emIdentifiers: ['emb041']),
  Boss(
      name: 'Old Guardian',
      imageUrl: 'assets/bosses/emb014.png',
      emIdentifiers: ['emb014']),
  Boss(
      name: 'Shade',
      imageUrl: 'assets/bosses/em4100.png',
      emIdentifiers: ['em4100', 'em4110']),
  Boss(
      name: 'Simone Shade',
      imageUrl: 'assets/bosses/em3010.png',
      emIdentifiers: ['em3010']),
  Boss(
      name: 'Ro-Shi Shade',
      imageUrl: 'assets/bosses/em8030.png',
      emIdentifiers: ['em8030', 'em8040']),
  Boss(
      name: 'Adam Shade',
      imageUrl: 'assets/bosses/em6400.png',
      emIdentifiers: ['em6400']),
  Boss(
      name: 'Eve Shade',
      imageUrl: 'assets/bosses/em5600.png',
      emIdentifiers: ['em5600']),
  Boss(
      name: 'Tank Shade',
      imageUrl: 'assets/bosses/em0112.png',
      emIdentifiers: ['em0112']),
  Boss(
      name: 'President',
      imageUrl: 'assets/bosses/em560d.png',
      emIdentifiers: ['em560d']),
  Boss(
      name: 'Goliath Shade',
      imageUrl: 'assets/bosses/em004d.png',
      emIdentifiers: ['em004d']),
  Boss(
      name: 'Multileg Shade',
      imageUrl: 'assets/bosses/em002d.png',
      emIdentifiers: ['em002d']),
  Boss(
      name: 'Ball',
      imageUrl: 'assets/bosses/em9001.png',
      emIdentifiers: ['em9000', 'em9001', 'em9002', 'em9003']),
  Boss(
      name: 'Snake',
      imageUrl: 'assets/bosses/em9010.png',
      emIdentifiers: ['em9010', 'em9011']),
];
