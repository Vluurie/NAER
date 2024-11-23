import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/dat/datRepacker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/pak/pakRepacker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/yax/xmlToYax.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

int conversionCounter = 0;

Future<bool> handleXmlToYax(
    final String input,
    String? output,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<DatFolder> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!input.endsWith(".xml")) return false;
  if (!isFile) return false;
  if (!dirname(input).endsWith(".pak")) return false;

  output ??= "${withoutExtension(input)}.yax";

  conversionCounter++;
  // stdout.write('\rConverting XML to YAX ($conversionCounter): $output     ');

  await xmlFileToYaxFile(input, output);

  return true;
}

Future<bool> handlePakRepack(
    final String input,
    final String? output,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<DatFolder> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!input.endsWith(".pak")) return false;
  if (!isDirectory) return false;

  await repackPak(input, output);
  return true;
}

Future<bool> handleDatRepack(
    final String input,
    String? output,
    final ListQueue<String> pendingFiles,
    final Set<String> processedFiles,
    final List<DatFolder> activeOptions,
    final SendPort sendPort,
    {required final bool isFile,
    required final bool isDirectory,
    required final bool? isManagerFile}) async {
  if (!strEndsWithDat(input)) return false;
  if (!isDirectory) return false;

  if (output == null) {
    var nameExt = await getDatNameParts(input);
    if (nameExt.item1 != null) {
      output = join(dirname(input), "${nameExt.item1!}.${nameExt.item2}");
    } else {
      output = "${withoutExtension(input)}.${nameExt.item2}";
    }
    if (await FileSystemEntity.isDirectory(output)) {
      output = "${withoutExtension(output)}_repacked.${nameExt.item2}";
    }
  }

  debugPrint("Repacking DAT file to $output...");

  await repackDat(input, output, sendPort);

  return true;
}
