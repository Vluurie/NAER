// ignore_for_file: avoid_print

import 'package:args/args.dart';

void displayHelp(ArgParser argParser, [String? option]) {
  if (option == null) {
    print(argParser.usage);
  } else {
    final helpMessage = _detailedHelpMessages()[option];
    if (helpMessage != null) {
      print('''
+-------------------------------------------------------------+
| Help for --$option:                                         |
+-------------------------------------------------------------+
$helpMessage
+-------------------------------------------------------------+
''');
    } else {
      print('''
+-------------------------------------------------------------+
| No detailed help available for --$option.                   |
+-------------------------------------------------------------+
| You can use the --help flag without any option to see the   |
| general usage of the tool.                                  |
+-------------------------------------------------------------+
''');
    }
  }
}

Map<String, String> _detailedHelpMessages() {
  return {
    "input": '''
+-------------------------------------------------------------+
| The input absolute path for the game files:                 |
| argument[0]                                                 |
|                                                             |
| Needs to be always /data:                                   |
|                                                             |
| D:/SteamLibrary/steamapps/common/NieRAutomata/data          |
+-------------------------------------------------------------+
''',
    "sortedEnemies": '''
+-------------------------------------------------------------+
| Specifies a file that contains the sorted enemy data.       |
|                                                             |
| If the file doesn't exist, you can create it automatically  |
| by using the --create_temp option. This will generate a     |
| template in the NAER_Settings/temp_sorted_enemies.dart file.|
|                                                             |
| You can then customize this file to specify different enemy |
| groups like "Ground", "Fly", and "Delete".                  |
|                                                             |
| Example:                                                    |
| --sortedEnemies=../NAER_Settings/temp_sorted_enemies.dart   |
|                                                             |
| To skip this step and include all enemies, simply use:      |
| --sortedEnemies=ALL                                         |
+-------------------------------------------------------------+
''',
    "gameCategoryOptions": '''
+-------------------------------------------------------------+
| The game includes four categories where enemies can exist:  |
| Quests (q), Maps (r), Game Phases (p), and the Game Core    |
| File (corehap).                                             |
|                                                             |
| Possible options include:                                   |
| --p100 --p200 --p300 --p400 --corehap --r5a0 --r5a1 --r5a2  |
| --r500 --r501 --r502 --r503 --r520 --r530 --r550 --r551     |
| --r200 --r110 --r130 --r140 --r150 --r160 --r170 --r100     |
| --r120 --q020 --q031 --q032 --q040 --q070 --q071 --q072     |
| --q100 --q101 --q102 --q103 --q104 --q110 --q120 --q121     |
| --q122 --q123 --q130 --q140 --q150 --q160 --q162 --q170     |
| --q171 --q180 --q181 --q210 --q220 --q221 --q222 --q240     |
| --q250 --q290 --q291 --q292 --q300 --q330 --q340 --q360     |
| --q400 --q401 --q403 --q410 --q440 --q500 --q520 --q532     |
| --q540 --q550 --q560 --q561 --q562 --q590 --q640 --q650     |
| --q651 --q652 --q660 --q680 --q720 --q770 --q800 --q801     |
| --q802 --q900 --q920 --q085 --q090 --q091 --q092 --q095     |
+-------------------------------------------------------------+
''',
    "ignore": '''
+-------------------------------------------------------------+
| Specify files that should be ignored during the repacking   |
| process. The ignored files will not get exported so that    |
| they do not overwrite the files in the output path.         |
|                                                             |
| Example:                                                    |
| --ignore=em0111.dat,em0112.dat,em3000.dat,em3010.dat        |
| ,p100.dat,qaa0.dat,qace.dat,qaec.dat,qaed.dat,qaee.dat      |
+-------------------------------------------------------------+
''',
    "enemies": '''
+-------------------------------------------------------------+
| Specifies a list of enemies that you want to focus on for   |
| stat modifications. The enemy identifiers need to be        |
| written in []. Group them in [] if multiple identifiers     |
| share the same stats file.                                  |
|                                                             |
| Example identifiers:                                        |
| --enemies [em1030],[em1040],[em1074],[em1100, em1101]       |
| [em1000],[em3000],[em7000, em7001],[em4000, em4010]         |
| [em0120],[em8000, em8001, em8801],[em8010],[em8020],[em8002]|
| [em2100, em2101],[em6000, em5100, em6200, em5300]           |
| [em5400, em5000, em5002, em5200, em5401, em5500]            |
| [em0110, em0111, emb0110, emb111]                           |
| [em1010, em8802, em8800],[emb054],[emb002],[emb051]         |
| [emb010],[emb061],[emb041],[em4100, em4110],[em3010]        |
| [em8030],[em6400],[em5600],[em0112],[em560d],[em004d]       |
| [em002d],[em9000, em9001, em9002, em9003]                   |
| [em9010, em9011],[emb004],[emb012],[emb052],[emb056]        |
| [emb110],[em200d],[em1050],[em1060],[em1070],[em1061]       |
| [em0065],[em1074],[em1020],[emb080],[emb060],[em0006]       |
| [em0106],[em0056],[em0016],[em0066],[em0069],[em0026]       |
| [em0046],[em0096],[em0086],[em2006],[em005a],[em2007]       |
| [em0005],[em000e],[em000d],[em0055],[em0015],[em0068]       |
| [em0004],[em0054],[em0014],[em0064],[em0067],[em0094]       |
| [em0003],[em0053],[em0013],[emb05a],[emb015],[em0002]       |
| [em0052],[em0012],[em0042],[em0000],[em0100],[em0050]       |
| [em0010],[emb016],[em0060],[em0061],[em0020],[em0040]       |
| [em0090],[em0080],[em005c],[em001c],[em2001],[em2002]       |
| [em0007],[em0057],[em0017],[em9000],[ema001],[ema002]       |
| [ema010],[ema011],[emb014],[em0030],[em0032],[em0033]       |
| [em0034],[em0035],[em0036],[emb031],[em3004]                |
+-------------------------------------------------------------+
''',
    "enemyStats": '''
+-------------------------------------------------------------+
| Enemy Stats multiplier when --enemies is used. Both need    |
| to be written together or it will take no effect, exporting |
| unmodified em files.                                        |
|                                                             |
| Example:                                                    |
| --enemyStats 5.0                                            |
|                                                             |
| Min-Max: [0.1-5.0]                                          |
+-------------------------------------------------------------+
''',
    "level": '''
+-------------------------------------------------------------+
| Specifies the level for all enemies that are being modified.|
|                                                             |
| Example:                                                    |
| --level=99                                                  |
|                                                             |
| Possible: [1 - 99]                                          |
+-------------------------------------------------------------+
''',
    "category": '''
+-------------------------------------------------------------+
| --category=allenemies                                       |
| All Enemies: Selecting this option modifies the level of    |
| every enemy in the chosen categories to the specified level.|
|                                                             |
| --category=onlylevel                                        |
| All Enemies Without Randomization: When enabled, this       |
| option maintains the current status of all enemies, even if |
| some were previously selected for randomization, and only   |
| modifies their level.                                       |
|                                                             |
| --category=default                                          |
| Default: No enemy level gets modified.                      |
+-------------------------------------------------------------+
''',
    "specialDatOutput": '''
+-------------------------------------------------------------+
| The output absolute path for the exported modified files:   |
| argument[1]                                                 |
|                                                             |
| Example:                                                    |
| D:/SteamLibrary/steamapps/common/NieRAutomata/data          |
+-------------------------------------------------------------+
''',
    "balance": '''
+-------------------------------------------------------------+
| Enables Balance Mode, which adjusts the stats of            |
| particularly tough enemies to make the game more balanced.  |
| This mode reduces the health and defense of these enemies,  |
| making them less of a roadblock and ensuring a smoother     |
| progression through the game.                               |
|                                                             |
| --balance                                                   |
+-------------------------------------------------------------+
''',
    "dlc": '''
+-------------------------------------------------------------+
| Includes DLC content in the randomization and modification  |
| process. If you have the game's DLC installed, this option  |
| allows the tool to modify and randomize content from those  |
| additional packs, integrating them seamlessly with the base |
| game modifications.                                         |
|                                                             |
| --dlc                                                       |
+-------------------------------------------------------------+
''',
    "backUp": '''
+-------------------------------------------------------------+
| Creates a backup of the original files before making any    |
| modifications. This is highly recommended to prevent data   |
| loss or to allow you to revert to the original game state if|
| needed. The backup will include all files that are subject  |
| to change, ensuring that you have a safe restore point.     |
|                                                             |
| --backUp                                                    |
+-------------------------------------------------------------+
'''
  };
}
