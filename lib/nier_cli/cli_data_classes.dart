import 'dart:isolate';

import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:args/args.dart';

class GamePackData {
  final String currentDir;
  final Map<String, List<String>> collectedFiles;
  final CliOptions options;
  final List<String> pendingFiles;
  final Set<String> processedFiles;
  final List<String> enemyList;
  final List<String> activeOptions;
  final bool? isManagerFile;
  final List<String> ignoreList;
  final String? output;
  final ArgResults args;
  final SendPort sendPort;

  GamePackData({
    required this.currentDir,
    required this.collectedFiles,
    required this.options,
    required this.pendingFiles,
    required this.processedFiles,
    required this.enemyList,
    required this.activeOptions,
    this.isManagerFile,
    required this.ignoreList,
    this.output,
    required this.args,
    required this.sendPort,
  });

  @override
  String toString() {
    return 'FileManager {\n'
        '  currentDir: $currentDir,\n'
        '  collectedFiles: $collectedFiles,\n'
        '  options: $options,\n'
        '  pendingFiles: $pendingFiles,\n'
        '  processedFiles: $processedFiles,\n'
        '  enemyList: $enemyList,\n'
        '  activeOptions: $activeOptions,\n'
        '  isManagerFile: $isManagerFile,\n'
        '  ignoreList: $ignoreList,\n'
        '  output: $output,\n'
        '  args: ${args.arguments},\n'
        '  sendPort: $sendPort\n'
        '}';
  }
}
