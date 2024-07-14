import 'dart:io';
import 'dart:isolate';

import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/dat/datRepacker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/pak/pakRepacker.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils_fork/yax/xmlToYax.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

int conversionCounter = 0;

Future<bool> handleXmlToYax(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile,
    SendPort sendPort) async {
  if (args.fileTypeIsKnown && !args.isYax) return false;
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
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile,
    SendPort sendPort) async {
  if (args.fileTypeIsKnown && !args.isPak) return false;
  if (!input.endsWith(".pak")) return false;
  if (!isDirectory) return false;

  await repackPak(input, output);
  return true;
}

Future<bool> handleDatRepack(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile,
    SendPort sendPort) async {
  if (args.fileTypeIsKnown && !args.isDat) return false;
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
