extension ModifyArguments on List<String> {
  static const String bossList =
      "[em1030],[em1040],[em1074],[em1100, em1101],[em1000],[em3000],[em7000, em7001],[em4000, em4010],[em0120],[em8000, em8001, em8801],[em8010],[em8020],[em8002],[em2100, em2101],[em6000, em5100, em6200, em5300],[em5400, em5000, em5002, em5200, em5401, em5500],[em0110, em0111, emb0110, emb111],[em1010, em8802, em8800],[emb054],[emb002],[emb051],[emb010],[emb061],[emb041],[emb014],[em4100, em4110],[em3010],[em8030],[em6400],[em5600],[em0112],[em560d],[em004d],[em002d],[em9000, em9001, em9002, em9003],[em9010, em9011]";

  void modifyArgumentsForForcedBossList() {
    int bossIndex = indexWhere((arg) => arg.startsWith('--bosses'));
    if (bossIndex != -1 &&
        bossIndex + 1 < length &&
        this[bossIndex + 1].toLowerCase() == 'none') {
      this[bossIndex + 1] = bossList;
    }
  }
}
