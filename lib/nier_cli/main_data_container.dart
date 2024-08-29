import 'dart:isolate';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:args/args.dart';
import 'package:xml/xml.dart' as xml;

/// MainData contains the main configuration and arguments required for processing the game files.
class MainData {
  final Map<String, dynamic> argument;
  final String? sortedEnemyGroupsIdentifierMap;
  final CliOptions options;
  final bool? isManagerFile;
  final String output;
  final ArgResults args;
  final SendPort sendPort;
  final bool? backUp;
  final bool? isBalanceMode;
  final bool? hasDLC;
  final bool isAddition;

  MainData(
      {required this.argument,
      required this.sortedEnemyGroupsIdentifierMap,
      required this.options,
      this.isManagerFile,
      required this.output,
      required this.args,
      required this.sendPort,
      this.backUp,
      this.isBalanceMode,
      required this.hasDLC,
      required this.isAddition});

  @override
  String toString() {
    return 'MainData {\n'
        '  argument: $argument,\n'
        '  sortedEnemiesPath: $sortedEnemyGroupsIdentifierMap,\n'
        '  options: $options,\n'
        '  isManagerFile: $isManagerFile,\n'
        '  output: $output,\n'
        '  args: ${args.arguments},\n'
        '  sendPort: $sendPort,\n'
        '  backUp: $backUp\n'
        '  isBalanceMode: $isBalanceMode\n'
        '  hasDLC: $hasDLC\n'
        '}';
  }
}

class NierCliArgs {
  final List<String> arguments;
  final bool? isManagerFile;
  final SendPort sendPort;
  final bool? backUp;
  final bool? isBalanceMode;
  final bool? hasDLC;
  final bool isAddition;

  NierCliArgs(
      {required this.arguments,
      this.isManagerFile,
      required this.sendPort,
      this.backUp,
      this.isBalanceMode,
      this.hasDLC,
      required this.isAddition});

  @override
  String toString() {
    return 'NierCliArgs {\n'
        '  argument: $arguments,\n'
        '  isManagerFile: $isManagerFile,\n'
        '  sendPort: $sendPort,\n'
        '  backUp: $backUp\n'
        '  isBalanceMode: $isBalanceMode\n'
        '  hasDLC: $hasDLC\n'
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
