import 'dart:io';

import 'package:path/path.dart';

import 'CliOptions.dart';
import 'exception.dart';
import 'fileTypeUtils/cpk/cpkExtractor.dart';
import 'fileTypeUtils/dat/datExtractor.dart';
import 'fileTypeUtils/dat/datRepacker.dart';
import 'fileTypeUtils/pak/pakExtractor.dart';
import 'fileTypeUtils/pak/pakRepacker.dart';

import 'fileTypeUtils/yax/xmlToYax.dart';
import 'fileTypeUtils/yax/yaxToXml.dart';
import 'utils.dart';

int conversionCounter = 0;

Future<bool> handleDatExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (input != 'dtt') if (args.fileTypeIsKnown && !args.isDat) return false;
  if (!strEndsWithDat(input)) return false;
  if (!isFile) return false;

  output ??= join(dirname(input), datExtractSubDir, basename(input));

  await Directory(output).create(recursive: true);
  var extractedFiles = await extractDatFiles(input, output);
  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

Future<bool> handleDatRepack(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isDat) return false;
  if (!strEndsWithDat(input)) return false;
  if (!isDirectory) return false;

  if (output == null) {
    var nameExt = await getDatNameParts(input);
    if (nameExt.item1 != null)
      output = join(dirname(input), nameExt.item1! + "." + nameExt.item2);
    else
      output = withoutExtension(input) + "." + nameExt.item2;
    if (await FileSystemEntity.isDirectory(output))
      output = withoutExtension(output) + "_repacked." + nameExt.item2;
  }

  print("Repacking DAT file to $output...");

  await repackDat(input, output);

  return true;
}

Future<bool> handlePakExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isPak) return false;
  if (!input.endsWith(".pak")) return false;
  if (!isFile) return false;

  output ??= join(dirname(input), pakExtractSubDir, basename(input));

  await Directory(output).create(recursive: true);
  var extractedFiles = await extractPakFiles(input, output);
  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

Future<bool> handlePakRepack(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isPak) return false;
  if (!input.endsWith(".pak")) return false;
  if (!isDirectory) return false;

  await repackPak(input, output);
  return true;
}

Future<bool> handleYaxToXml(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isYax) return false;
  if (!input.endsWith(".yax")) return false;
  if (!isFile) return false;

  output ??= withoutExtension(input) + ".xml";

  conversionCounter++;
  stdout.write('\rConverting YAX to XML ($conversionCounter): $output     ');

  await yaxFileToXmlFile(input, output);

  return true;
}

Future<bool> handleXmlToYax(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isYax) return false;
  if (!input.endsWith(".xml")) return false;
  if (!isFile) return false;
  if (!dirname(input).endsWith(".pak")) return false;

  output ??= withoutExtension(input) + ".yax";

  conversionCounter++;
  stdout.write('\rConverting XML to YAX ($conversionCounter): $output     ');

  await xmlFileToYaxFile(input, output);

  return true;
}

Future<bool> handleCpkExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles) async {
  if (args.fileTypeIsKnown && !args.isCpk) return false;
  if (!input.endsWith(".cpk")) return false;
  if (!isFile) return false;

  var fileName = basename(input).toLowerCase();
  if (!(fileName == 'data002.cpk' ||
      fileName == 'data012.cpk' ||
      fileName == 'data100.cpk')) {
    return false; // Skip processing if it's not one of the specified files
  }

  output ??= join(dirname(input), basename(input) + "_extracted");

  print("Extracting CPK to $output...");

  await Directory(output).create(recursive: true);
  var extractedFiles = await extractCpk(input, output);
  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

const List<
        Future<bool> Function(
            String, String?, CliOptions, bool, bool, List<String>, Set<String>)>
    _handlers = [
  handleDatExtract,
  handleDatRepack,
  handlePakExtract,
  handlePakRepack,
  handleYaxToXml,
  handleXmlToYax,
  handleCpkExtract,
];
// here i added more logic for .dat to use the cli options specialDatoutput i pass from the Python Output
Future<void> handleInput(String input, String? output, CliOptions args,
    List<String> pendingFiles, Set<String> processedFiles) async {
  bool isFile = await FileSystemEntity.isFile(input);
  bool isDirectory = await FileSystemEntity.isDirectory(input);
  if (!isFile && !isDirectory)
    throw FileHandlingException(
        "Input file or directory does not exist ($input)");
  for (var handler in _handlers) {
    String? currentOutput = output;
    if (handler == handleDatRepack && args.specialDatOutputPath != null) {
      currentOutput = args.specialDatOutputPath;
      print("Using special output path for .dat repacking: $currentOutput");
    }

    if (await handler(input, currentOutput, args, isFile, isDirectory,
        pendingFiles, processedFiles)) {
      return;
    }
  }
  if (!args.autoExtractChildren && !args.recursiveMode && !args.folderMode ||
      pendingFiles.isEmpty && processedFiles.isEmpty)
    throw FileHandlingException("Unknown file type");
}
