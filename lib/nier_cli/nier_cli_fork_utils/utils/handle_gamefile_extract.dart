import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_valid_gamefiles.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/cpk/cpkExtractor.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/dat/datExtractor.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/pak/pakExtractor.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/yax/yaxToXml.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';

int conversionCounter = 0;

Future<bool> handleSingleCpkExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> enemyList,
    List<String> activeOptions,
    bool? isManagerFile,
    SendPort sendPort) async {
  if (!isCpkExtractionValid(input, isFile, args, enemyList)) return false;
  output ??= join(dirname(input), "${basename(input)}_extracted");
  debugPrint("Extracting CPK to $output...");
  await Directory(output).create(recursive: true);
  var extractedFiles = await extractCpk(input, output, sendPort);

  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

Future<bool> handleSingleYaxToXml(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? isManagerFile,
    SendPort sendPort) async {
  if (!isYaxToXmlValid(input, isFile, args)) return false;
  output ??= "${withoutExtension(input)}.xml";
  conversionCounter++;
  await yaxFileToXmlFile(input, output, sendPort);
  return true;
}

Future<bool> handleSinglePakExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? isManagerFile,
    SendPort sendPort) async {
  if (!isPakExtractionValid(input, isFile, args)) return false;
  output ??= join(dirname(input), pakExtractSubDir, basename(input));
  await Directory(output).create(recursive: true);
  var extractedFiles = await extractPakFiles(input, output, sendPort);
  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

Future<bool> handleSingleDatExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? isManagerFile,
    SendPort sendPort) async {
  if (!isDatExtractionValid(
      input, isFile, args, isManagerFile, activeOptions)) {
    return false;
  }

  output ??= join(dirname(input), datExtractSubDir, basename(input));

  if (isManagerFile != true) {
    await Directory(output).create(recursive: true);
  }

  var extractedFiles = await extractDatFiles(input, output, sendPort);
  sendPort.send('Extracted files from $input: ${extractedFiles.length} files.');

  if (args.autoExtractChildren) {
    pendingFiles.insertAll(0, extractedFiles);
  }

  return true;
}
