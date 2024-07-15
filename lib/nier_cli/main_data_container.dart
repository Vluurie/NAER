import 'dart:isolate';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:args/args.dart';
import 'package:xml/xml.dart' as xml;

/// MainData contains the main configuration and arguments required for processing the game files.
///
/// This class holds the configuration details, arguments, and necessary information
/// to perform game file modifications and processes. It acts as a container for
/// the primary data required throughout the game file processing operations.
///
/// [argument]: A map of arguments and their corresponding values.
/// [sortedEnemiesPath]: The path for the sorted enemies file.
/// [options]: Parsed additional options for CLI operations.
/// [isManagerFile]: A boolean indicating if the file is from the mod manager.
/// [output]: The output path for the processed files.
/// [args]: Parsed command-line arguments.
/// [sendPort]: A SendPort for inter-isolate communication.
/// [backUp]: A boolean indicating if a backup is needed.
class MainData {
  final Map<String, dynamic> argument;
  final String? sortedEnemiesPath;
  final CliOptions options;
  final bool? isManagerFile;
  final String output;
  final ArgResults args;
  final SendPort sendPort;
  final bool? backUp;
  final bool? isBalanceMode;

  MainData({
    required this.argument,
    required this.sortedEnemiesPath,
    required this.options,
    this.isManagerFile,
    required this.output,
    required this.args,
    required this.sendPort,
    this.backUp,
    this.isBalanceMode,
  });

  @override
  String toString() {
    return 'MainData {\n'
        '  argument: $argument,\n'
        '  sortedEnemiesPath: $sortedEnemiesPath,\n'
        '  options: $options,\n'
        '  isManagerFile: $isManagerFile,\n'
        '  output: $output,\n'
        '  args: ${args.arguments},\n'
        '  sendPort: $sendPort,\n'
        '  backUp: $backUp\n'
        '  isBalanceMode: $isBalanceMode\n'
        '}';
  }
}

class NierCliArgs {
  final List<String> arguments;
  final bool? isManagerFile;
  final SendPort sendPort;
  final bool? backUp;
  final bool? isBalanceMode;

  NierCliArgs({
    required this.arguments,
    this.isManagerFile,
    required this.sendPort,
    this.backUp,
    this.isBalanceMode,
  });

  @override
  String toString() {
    return 'NierCliArgs {\n'
        '  argument: $arguments,\n'
        '  isManagerFile: $isManagerFile,\n'
        '  sendPort: $sendPort,\n'
        '  backUp: $backUp\n'
        '  isBalanceMode: $isBalanceMode\n'
        '}';
  }
}

/// Data class for handling enemy entity object parameters
class EnemyEntityObjectAction {
  final xml.XmlElement objIdElement;
  final Map<String, List<String>> userSelectedEnemyData;
  final String enemyLevel;
  final bool isSpawnActionTooSmall;
  final bool handleLevels;
  final bool randomizeAndSetValues;

  EnemyEntityObjectAction({
    required this.objIdElement,
    required this.userSelectedEnemyData,
    required this.enemyLevel,
    required this.isSpawnActionTooSmall,
    this.handleLevels = false,
    this.randomizeAndSetValues = false,
  });

  @override
  String toString() {
    return 'EnemyEntityObjectAction {\n'
        '  objIdElement: ${objIdElement.toXmlString(pretty: true)},\n'
        '  userSelectedEnemyData: $userSelectedEnemyData,\n'
        '  enemyLevel: $enemyLevel,\n'
        '  isSpawnActionTooSmall: $isSpawnActionTooSmall,\n'
        '  handleLevels: $handleLevels,\n'
        '  randomizeAndSetValues: $randomizeAndSetValues\n'
        '}';
  }
}
