// arg_descriptions.dart

// Concise descriptions for each argument used in the batch command,
// optimized for clarity and command prompt readability.

const List<String> argDescriptions = [
  // Argument 1: Input Directory
  'Input directory for .cpk or .dat files. Any folder with these files can be used.',

  // Argument 2: Output Parameter
  'Defines the type of output for the process.',

  // Argument 3: Output Directory
  'Destination for modified .dat files, not limited to the game folder.',

  // Argument 4: Enemy Selection
  'Select enemies from sorted_enemy list. Creates a temporary file for random looping.',

  // Argument 5: Bosses Parameter
  'Selects specific bosses for modifications.',

  // Argument 6: Selected Bosses
  'Modify ExpInfo.csv for chosen bosses with bossStats argument.',

  // Argument 7: Boss Stats Parameter
  'Multiplier for boss stats in ExpInfo.csv, max limit is 5.',

  // Argument 8: ExpInfo Multiplier
  'Sets multiplier for ExpInfo.csv, max 5. High values may cause unbeatable enemies.',

  // Argument 9: Enemy Level Modification
  'Sets enemy levels post-modification. Options: all, only bosses, sorted enemies.',

  // Argument 10: Category Parameter --allquests
  '--allquests: Includes all quest (.dat) files, skips if not used.',

  // Argument 11: Category Parameter --allphases
  '--allphases: Includes all phase files (p100, etc.), skips if not used.',

  // Argument 12: Category Parameter --allmaps
  '--allmaps: Includes all map (.dat) files, skips if not used.',

  // Argument 13: Category Parameter --ignoredlc
  '--ignoredlc: Ignores files in data100.cpk.',

  // Argument 14: Level Change Option Parameter
  '--category options: default (no change), onlybosses, onlyselectedenemies, allenemies.',
];

String asciiArt2B = '''
... ⠄⠄⠄⠄⢠⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣯⢻⣿⣿⣿⣿⣆⠄⠄⠄
⠄⠄⣼⢀⣿⣿⣿⣿⣏⡏⠄⠹⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⡆⠄⠄
⠄⠄⡟⣼⣿⣿⣿⣿⣿⠄⠄⠄⠈⠻⣿⣿⣿⣿⣿⣿⣿⣇⢻⣿⣿⣿⣿⠄⠄
⠄⢰⠃⣿⣿⠿⣿⣿⣿⠄⠄⠄⠄⠄⠄⠙⠿⣿⣿⣿⣿⣿⠄⢿⣿⣿⣿⡄⠄
⠄⢸⢠⣿⣿⣧⡙⣿⣿⡆⠄⠄⠄⠄⠄⠄⠄⠈⠛⢿⣿⣿⡇⠸⣿⡿⣸⡇⠄
⠄⠈⡆⣿⣿⣿⣿⣦⡙⠳⠄⠄⠄⠄⠄⠄⢀⣠⣤⣀⣈⠙⠃⠄⠿⢇⣿⡇⠄
⠄⠄⡇⢿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠄⣠⣶⣿⣿⣿⣿⣿⣿⣷⣆⡀⣼⣿⡇⠄
⠄⠄⢹⡘⣿⣿⣿⢿⣷⡀⠄⢀⣴⣾⣟⠉⠉⠉⠉⣽⣿⣿⣿⣿⠇⢹⣿⠃⠄
⠄⠄⠄⢷⡘⢿⣿⣎⢻⣷⠰⣿⣿⣿⣿⣦⣀⣀⣴⣿⣿⣿⠟⢫⡾⢸⡟⠄.
⠄⠄⠄⠄⠻⣦⡙⠿⣧⠙⢷⠙⠻⠿⢿⡿⠿⠿⠛⠋⠉⠄⠂⠘⠁⠞⠄⠄⠄
⠄⠄⠄⠄⠄⠈⠙⠑⣠⣤⣴⡖⠄⠿⣋⣉⣉⡁⠄⢾⣦⠄⠄⠄⠄⠄⠄⠄⠄ ...
''';
