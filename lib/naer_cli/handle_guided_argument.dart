// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PathHolder {
  String? input;
  String? output;
}

Future<List<String>> guidedMode() async {
  List<String> arguments = [];
  PathHolder paths = PathHolder();

  // Clear console and print a welcoming message
  clearConsole();
  print("============================================");
  print("            WELCOME TO GUIDED MODE          ");
  print("============================================\n");

  print(
      "Please follow the instructions below to configure your modifications.\n");

  // Setup Directories
  print("+------------------------------------------+");
  print("|            SETUP DIRECTORIES             |");
  print("+------------------------------------------+\n");

  bool doPathsAlreadyExist = await defaultValuePaths(paths);

  // Input Directory (Positional argument)
  if (doPathsAlreadyExist) {
    arguments.add(paths.input!);
    arguments.add('--output');
    arguments.add(paths.output!);
  } else {
    String specifiedInputDir = promptUser(
      "Enter the input directory (e.g., D:/SteamLibrary/steamapps/common/NieRAutomata/data): ",
      isRequired: true,
    );
    arguments.add(specifiedInputDir);

    // Output Directory (Optional argument without equals sign)
    String specifiedOutputDir = promptUser(
      "Enter the output directory (default is the same as input): ",
      defaultValue: specifiedInputDir,
    );
    arguments.add('--output');
    arguments.add(specifiedOutputDir);
  }

  // Category Selection
  print("+------------------------------------------+");
  print("|          SELECT A CATEGORY               |");
  print("+------------------------------------------+");
  print("| - a: allenemies: Changes enemy levels if |");
  print("|   specified and randomizes enemies based |");
  print("|   on the sortedEnemies file or ALL.      |");
  print("| - o: onlylevel: Only changes enemy levels|");
  print("|   no enemies are randomized.             |");
  print("|   sortedEnemies is ignored.              |");
  print("| - d: default: No level changes; enemies  |");
  print("|   are randomized based on sortedEnemies. |");
  print("+------------------------------------------+\n");

  // Category (Optional argument with equals)
  String category = promptUser(
    "Select a category (a = allenemies / o = onlylevel / d = default): ",
    defaultValue: 'd',
  ).toLowerCase();

  switch (category) {
    case 'a':
      category = 'allenemies';
      break;
    case 'o':
      category = 'onlylevel';
      break;
    case 'd':
    default:
      category = 'default';
  }

  // Default settings applied regardless of category
  arguments.add('ALL');
  arguments.add('--enemies');
  arguments.add('None');
  arguments.add('--enemyStats');
  arguments.add('0.0');

  // Enemy Level (Optional argument with equals)
  String level = promptUser(
    "Enter the enemy level (e.g., 99): ",
    defaultValue: '99',
  );
  arguments.add('--level=$level');

  // Setup Options (conditional based on category)

  if (category != 'onlylevel') {
    // Sorted Enemies (Positional argument, can be 'ALL' or a specific file)
    String sortedEnemies = promptUser(
      "Specify a sorted enemies file (or type 'ALL'): ",
      defaultValue: 'ALL',
    );
    arguments.add(sortedEnemies);
    if (category != 'default') {
      // Enemies (Optional argument)
      String enemies = promptUser(
        "Enter enemies to modify stats (comma-separated, e.g., [em1074],[emb012]) or leave empty for no stats change: ",
      );
      if (enemies.isNotEmpty) {
        arguments.add('--enemies');
        arguments.add(enemies);
      }

      // Enemy Stats (Optional argument)
      String enemyStats = promptUser(
        "Enter the enemy stats multiplier (e.g., 5.0) or leave empty (must be empty if 'Modify Enemies' is empty): ",
        defaultValue: '0.0',
      );
      arguments.add('--enemyStats');
      arguments.add(enemyStats);
    }
  }

  arguments.add('--category=$category');

  // Setup Flags
  print("+------------------------------------------+");
  print("|            SETUP FLAGS                   |");
  print("+------------------------------------------+\n");

  // Balance Mode (Flag)
  if (confirmUserChoice("Do you want to enable balance mode? (y/n): ")) {
    arguments.add('--balance');
  }

  // DLC Content (Flag)
  if (confirmUserChoice("Do you want to include DLC content? (y/n): ")) {
    arguments.add('--dlc');
  }

  // Backup (Flag)
  if (confirmUserChoice(
      "Do you want to create a backup before processing? (y/n): ")) {
    arguments.add('--backUp');
  }

  // Final confirmation with enhanced review screen
  clearConsole();
  print("\n============================================");
  print("            REVIEW YOUR CONFIGURATION       ");
  print("============================================\n");
  print("The following command will be executed:");
  print("\nNAER.exe ${arguments.join(' ')}\n");

  if (!confirmUserChoice("Do you want to proceed? (y/n): ")) {
    print("Exiting guided mode.");
    exit(0);
  }

  return arguments;
}

// Helper functions
void clearConsole() {
  if (Platform.isWindows) {
    stdout.write(Process.runSync("cmd", ["/c", "cls"]).stdout);
  } else {
    stdout.write('\x1B[2J\x1B[3J\x1B[H');
  }
}

String promptUser(String message,
    {bool isRequired = false, String? defaultValue}) {
  String prompt = defaultValue != null ? " [$defaultValue]: " : ": ";
  stdout.write(message + prompt);
  String? input = stdin.readLineSync(encoding: utf8);

  if (input == null || input.isEmpty) {
    if (isRequired && defaultValue == null) {
      print("This field is required. Please enter a value.");
      return promptUser(message, isRequired: isRequired);
    }
    return defaultValue ?? '';
  }
  return input;
}

bool confirmUserChoice(String message) {
  stdout.write(message);
  String? input = stdin.readLineSync(encoding: utf8);
  return input?.toLowerCase() == 'y';
}

void defaultValueStats(List<String> arguments) {
  String defaultStat = '0.0';
  arguments.add('--enemyStats');
  arguments.add(defaultStat);
}

void defaultValueLevel(List<String> arguments) {
  String defaultLvL = '1';
  arguments.add('--level=$defaultLvL');
}

void defaultValueSelectedEnemies(List<String> arguments) {
  String sortedEnemies = 'ALL';
  arguments.add(sortedEnemies);
}

Future<bool> defaultValuePaths(PathHolder paths) async {
  bool doPathsExist = await loadPathsFromSharedPreferencesForConsole(paths);

  if (doPathsExist) {
    print('''
+-------------------------------------------------------------+
| Found paths in SharedPreferences from the GUI!              |
+-------------------------------------------------------------+
| Input Path:  ${paths.input}                                  |
| Output Path: ${paths.output}                                 |
+-------------------------------------------------------------+
''');
    return true;
  } else {
    print('''
+-------------------------------------------------------------+
| No paths found in SharedPreferences from the GUI.           |
| Please provide valid input and output paths.                |
+-------------------------------------------------------------+
''');
    return false;
  }
}

Future<bool> loadPathsFromSharedPreferencesForConsole(PathHolder paths) async {
  final prefs = await SharedPreferences.getInstance();

  String? savedInput = prefs.getString('input');
  String? savedOutput = prefs.getString('output');

  if (savedInput != null && savedOutput != null) {
    paths.input = savedInput;
    paths.output = savedOutput;
    return true;
  }
  return false;
}
