import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/naer_utils/dynamic_library_handler.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/cpk/cpk_extractor.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_valid_gamefiles.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:path/path.dart';

int conversionCounter = 0;

Future<bool> handleSingleCpkExtract(
    final String input,
    String? output,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<String> enemyList,
    final List<DatFolder> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!isCpkExtractionValid(input, enemyList, isFile: isFile)) {
    return false;
  }
  output ??= join(dirname(input), "${basename(input)}_extracted");
  globalLog("Extracting CPK to $output...");
  await Directory(output).create(recursive: true);
  var extractedFiles = await extractCpk(input, output, sendPort);

  pendingFiles.addAll(extractedFiles);

  return true;
}

Future<bool> handleSingleDatExtract(
    final String input,
    String? output,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<DatFolder> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!isDatExtractionValid(input, activeOptions,
      isFile: isFile, isManagerFile: isManagerFile)) {
    return false;
  }

  output ??= join(dirname(input), datExtractSubDir, basename(input));

  if (isManagerFile != true) {
    await Directory(output).create(recursive: true);
  }

  var extractedFiles =
      await extractDatFiles(input, output, shouldExtractPakFiles: true);



    pendingFiles.addAll(extractedFiles);
  

  return true;
}
