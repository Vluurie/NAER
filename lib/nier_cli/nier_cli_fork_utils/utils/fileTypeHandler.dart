import 'dart:io';

import 'package:path/path.dart';

import 'CliOptions.dart';
import 'exception.dart';
import 'package:path/path.dart' as path;
import '../fileTypeUtils/cpk/cpkExtractor.dart';
import '../fileTypeUtils/dat/datExtractor.dart';
import '../fileTypeUtils/dat/datRepacker.dart';
import '../fileTypeUtils/pak/pakExtractor.dart';
import '../fileTypeUtils/pak/pakRepacker.dart';

import '../fileTypeUtils/yax/xmlToYax.dart';
import '../fileTypeUtils/yax/yaxToXml.dart';
import 'utils.dart';

int conversionCounter = 0;

Future<bool> handleDatExtract(
    String input,
    String? output,
    CliOptions args,
    bool isFile,
    bool isDirectory,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? isManagerFile) async {
  String normalizePath(String filePath) {
    return path.normalize(filePath).toLowerCase();
  }

  String normalizedInput = normalizePath(input);
  if (isManagerFile != true) {
    // Check if the input path is in active options
    if (!activeOptions.map(normalizePath).contains(normalizedInput)) {
      return false;
    }
  } else {
    // print('isManagerFile is true, bypassing active options check.');
  }

  // Skip if the file type is known but not a DAT file
  if (args.fileTypeIsKnown && !args.isDat) {
    return false;
  }

  // Skip if the input does not end with .dat
  if (!strEndsWithDat(input)) {
    return false;
  }

  // Skip if the input is not a file
  if (!isFile) {
    return false;
  }

  output ??= join(dirname(input), datExtractSubDir, basename(input));

  if (isManagerFile != true) {
    print('Extracting DAT file: $input to $output');
    // Create the output directory if isManagerFile is not true
    await Directory(output).create(recursive: true);
  } else {
    //print('Skipping directory creation for manager file.');
  }

  // Proceed with extraction, ensuring output is non-null with `!`
  var extractedFiles = await extractDatFiles(input, output);
  print('Extracted files from $input: ${extractedFiles.length} files.');

  if (args.autoExtractChildren) {
    pendingFiles.insertAll(0, extractedFiles);
  }

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
    bool? ismanagerFile) async {
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
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile) async {
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
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile) async {
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
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  if (args.fileTypeIsKnown && !args.isYax) return false;
  if (!input.endsWith(".yax")) return false;
  if (!isFile) return false;

  output ??= "${withoutExtension(input)}.xml";

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
    Set<String> processedFiles,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  if (args.fileTypeIsKnown && !args.isYax) return false;
  if (!input.endsWith(".xml")) return false;
  if (!isFile) return false;
  if (!dirname(input).endsWith(".pak")) return false;

  output ??= "${withoutExtension(input)}.yax";

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
    Set<String> processedFiles,
    List<String> bossList,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  if (args.fileTypeIsKnown && !args.isCpk) return false;
  if (!input.endsWith(".cpk")) return false;
  if (!isFile) return false;

  var fileName = basename(input).toLowerCase();

  // Check if bossStats list is effectively empty
  bool isBossListEffectivelyEmpty = bossList.isEmpty ||
      bossList.every(
          (item) => item.trim().isEmpty || item.trim().toLowerCase() == 'none');

  // Skip extracting data006.cpk and data016.cpk if boss list is empty
  if (isBossListEffectivelyEmpty &&
      (fileName == 'data006.cpk' || fileName == 'data016.cpk')) {
    return false;
  }

  if (!(fileName == 'data002.cpk' ||
      fileName == 'data012.cpk' ||
      fileName == 'data100.cpk' ||
      fileName == 'data006.cpk' ||
      fileName == 'data016.cpk')) {
    return false;
  }

  output ??= join(dirname(input), "${basename(input)}_extracted");

  print("Extracting CPK to $output...");

  await Directory(output).create(recursive: true);
  var extractedFiles = await extractCpk(input, output);
  if (args.autoExtractChildren) pendingFiles.insertAll(0, extractedFiles);

  return true;
}

const List<
    Future<bool> Function(String, String?, CliOptions, bool, bool, List<String>,
        Set<String>, List<String>, bool? ismanagerFile)> _handlers = [
  handleDatExtract,
  handleDatRepack,
  handlePakExtract,
  handlePakRepack,
  handleYaxToXml,
  handleXmlToYax,
];
// here i added more logic for .dat to use the cli options specialDatoutput i pass from the Python Output
Future<void> handleInput(
    String input,
    String? output,
    CliOptions args,
    List<String> pendingFiles,
    Set<String> processedFiles,
    List<String> bossList,
    List<String> activeOptions,
    bool? ismanagerFile) async {
  bool isFile = await FileSystemEntity.isFile(input);
  bool isDirectory = await FileSystemEntity.isDirectory(input);
  if (!isFile && !isDirectory) {
    throw FileHandlingException(
        "Input file or directory does not exist ($input)");
  }
  await handleCpkExtract(input, output, args, isFile, isDirectory, pendingFiles,
      processedFiles, bossList, activeOptions, ismanagerFile);
  for (var handler in _handlers) {
    String? currentOutput = output;
    if (handler == handleDatRepack && args.specialDatOutputPath != null) {
      currentOutput = args.specialDatOutputPath;
      print("Using special output path for .dat repacking: $currentOutput");
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
