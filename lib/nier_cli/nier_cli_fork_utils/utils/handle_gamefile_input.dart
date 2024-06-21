import 'dart:io';

import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_extract.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_repack.dart';
import 'package:flutter/foundation.dart';

const List<
    Future<bool> Function(String, String?, CliOptions, bool, bool, List<String>,
        Set<String>, List<String>, bool? ismanagerFile)> _handlers = [
  handleSingleDatExtract,
  handleDatRepack,
  handleSinglePakExtract,
  handlePakRepack,
  handleSingleYaxToXml,
  handleXmlToYax,
];

Future<void> handleInput(
    String input,
    String? output,
    CliOptions args,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> enemyList,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  bool isFile = await FileSystemEntity.isFile(input);
  bool isDirectory = await FileSystemEntity.isDirectory(input);
  if (!isFile && !isDirectory) {
    throw FileHandlingException(
        "Input file or directory does not exist ($input)");
  }
  await handleSingleCpkExtract(input, output, args, isFile, isDirectory,
      pendingFiles, processedFiles, enemyList, activeOptions, ismanagerFile);
  for (var handler in _handlers) {
    String? currentOutput = output;
    if (handler == handleDatRepack && args.specialDatOutputPath != null) {
      currentOutput = args.specialDatOutputPath;
      debugPrint(
          "Using special output path for .dat repacking: $currentOutput");
    }

    if (await handler(input, currentOutput, args, isFile, isDirectory,
        pendingFiles, processedFiles, activeOptions, ismanagerFile)) {
      return;
    }
  }
  if (!args.autoExtractChildren && !args.recursiveMode && !args.folderMode ||
      pendingFiles.isEmpty && processedFiles.isEmpty) {
    throw const FileHandlingException("Unknown file type");
  }
}
