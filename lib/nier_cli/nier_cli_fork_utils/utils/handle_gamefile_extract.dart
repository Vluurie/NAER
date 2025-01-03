import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_valid_gamefiles.dart';
import 'package:NAER/naer_utils/dynamic_library_handler.dart';
import 'package:path/path.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/cpk/cpk_extractor.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';

int conversionCounter = 0;

Future<bool> handleSingleCpkExtract(
    final String input,
    String? output,
    final CliOptions args,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<String> enemyList,
    final List<String> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!isCpkExtractionValid(input, args, enemyList, isFile: isFile)) {
    return false;
  }
  output ??= join(dirname(input), "${basename(input)}_extracted");
  globalLog("Extracting CPK to $output...");
  await Directory(output).create(recursive: true);
  var extractedFiles = await extractCpk(input, output, sendPort);

  if (args.autoExtractChildren) pendingFiles.addAll(extractedFiles);

  return true;
}

Future<bool> handleSingleDatExtract(
    final String input,
    String? output,
    final CliOptions args,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<String> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!isDatExtractionValid(input, args, activeOptions,
      isFile: isFile, isManagerFile: isManagerFile)) {
    return false;
  }

  output ??= join(dirname(input), datExtractSubDir, basename(input));

  if (isManagerFile != true) {
    await Directory(output).create(recursive: true);
  }

  var extractedFiles =
      await extractDatFiles(input, output, shouldExtractPakFiles: true);
  // sendPort.send('Extracted files from $input: ${extractedFiles.length} files.');

  if (args.autoExtractChildren) {
    pendingFiles.addAll(extractedFiles);
  }

  return true;
}
