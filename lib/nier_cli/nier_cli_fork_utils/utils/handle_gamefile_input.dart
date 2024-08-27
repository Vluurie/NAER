import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_extract.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_repack.dart';
import 'package:flutter/foundation.dart';

const List<
    Future<bool> Function(String, String?, CliOptions, ListQueue<String>,
        Set<String>, List<String>, SendPort sendPort,
        {required bool isFile,
        required bool isDirectory,
        required bool? isManagerFile})> _handlers = [
  handleSingleDatExtract,
  handleDatRepack,
  handlePakRepack,
  handleXmlToYax,
];

Future<void> handleInput(
    final String input,
    final String? output,
    final CliOptions args,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<String> enemyList,
    final List<String> activeOptions,
    final SendPort sendPort,
    {required final bool? isManagerFile}) async {
  bool isFile = await FileSystemEntity.isFile(input);
  bool isDirectory = await FileSystemEntity.isDirectory(input);
  if (!isFile && !isDirectory) {
    throw FileHandlingException(
        "Input file or directory does not exist ($input)");
  }
  await handleSingleCpkExtract(input, output, args, pendingFiles,
      processedFiles, enemyList, activeOptions, sendPort,
      isFile: isFile, isDirectory: isDirectory, isManagerFile: isManagerFile);
  for (var handler in _handlers) {
    String? currentOutput = output;
    if (handler == handleDatRepack && args.specialDatOutputPath != null) {
      currentOutput = args.specialDatOutputPath;
      debugPrint(
          "Using special output path for .dat repacking: $currentOutput");
    }

    if (await handler(input, currentOutput, args, pendingFiles, processedFiles,
        activeOptions, sendPort,
        isFile: isFile,
        isDirectory: isDirectory,
        isManagerFile: isManagerFile)) {
      return;
    }
  }
  if (!args.autoExtractChildren && !args.recursiveMode && !args.folderMode ||
      pendingFiles.isEmpty && processedFiles.isEmpty) {
    throw const FileHandlingException("Unknown file type");
  }
}
