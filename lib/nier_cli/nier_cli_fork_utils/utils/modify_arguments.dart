extension ModifyArguments on List<String> {
  static const String enemyList =
      "[em1030],[em1040],[em1074],[em1100, em1101],[em1000],[em3000],[em7000, em7001],[em4000, em4010],[em0120],[em8000, em8001, em8801],[em8010],[em8020],[em8002],[em2100, em2101],[em6000, em5100, em6200, em5300],[em5400, em5000, em5002, em5200, em5401, em5500],[em0110, em0111, emb0110, emb111],[em1010, em8802, em8800],[emb054],[emb002],[emb051],[emb010],[emb061],[emb041],[emb014],[em4100, em4110],[em3010],[em8030],[em6400],[em5600],[em0112],[em560d],[em004d],[em002d],[em9000, em9001, em9002, em9003],[em9010, em9011],[emb004],[emb012],[emb052],[emb056],[emb110],[em200d],[em1050],[em1060],[em1070],[em1061],[em0065],[em1074],[em1020],[emb080],[emb060],[em0006],[em0106],[em0056],[em0016],[em0066],[em0069],[em0026],[em0046],[em0096],[em0086],[em2006],[em005a],[em2007],[em0005],[em000e],[em000d],[em0055],[em0015],[em0068],[em0004],[em0054],[em0014],[em0064],[em0067],[em0094],[em0003],[em0053],[em0013],[emb05a],[emb015],[em0002],[em0052],[em0012],[em0042],[em0000],[em0100],[em0050],[em0010],[emb016],[em0060],[em0061],[em0020],[em0040],[emb05d],[em0090],[em0080],[em005c],[em001c],[em2001],[em2002],[em0007],[em0057],[em0017],[em9000],[ema001],[ema002],[ema010],[ema011],[emb014],[em0030],[em0032],[em0033],[em0034],[em0035],[em0036],[emb031]";

  void modifyArgumentsForForcedEnemyList() {
    int enemyIndex = indexWhere((arg) => arg.startsWith('--enemies'));
    if (enemyIndex != -1 &&
        enemyIndex + 1 < length &&
        this[enemyIndex + 1].toLowerCase() == 'none') {
      this[enemyIndex + 1] = enemyList;
    }
  }
}
