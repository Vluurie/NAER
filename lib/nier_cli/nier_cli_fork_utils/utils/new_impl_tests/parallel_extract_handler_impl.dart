// import 'dart:async';
// import 'dart:io';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/check_valid_gamefiles.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/extracted_files_on_runtime.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
// import 'package:path/path.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/cpk/cpkExtractor.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/dat/datExtractor.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/pak/pakExtractor.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/fileTypeUtils/yax/yaxToXml.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils.dart';

///TODO TESTS FOR PARALLEL COMPUTING

// int conversionCounter = 0;

// Future<bool> handleSingleCpkExtract(
//     String input,
//     String? output,
//     CliOptions args,
//     bool isFile,
//     bool isDirectory,
//     List<String> pendingFiles,
//     Set<String> processedFiles,
//     List<String> bossList,
//     List<String> activeOptions,
//     bool? isManagerFile) async {
//   if (!isCpkExtractionValid(input, isFile, args, bossList)) return false;
//   output ??= join(dirname(input), "${basename(input)}_extracted");
//   logAndPrint("Extracting CPK to $output...");
//   await Directory(output).create(recursive: true);
//   var extractedFiles = await extractCpk(input, output);

//   if (args.autoExtractChildren) {
//     GlobalRunTimeExtractedFiles.extractedCpkFiles.insertAll(0, extractedFiles);
//   }

//   return true;
// }

// Future<bool> handleSingleYaxToXml(
//     String input,
//     String? output,
//     CliOptions args,
//     bool isFile,
//     bool isDirectory,
//     List<String> pendingFiles,
//     Set<String> processedFiles,
//     List<String> activeOptions,
//     bool? isManagerFile) async {
//   if (!isYaxToXmlValid(input, isFile, args)) return false;
//   output ??= "${withoutExtension(input)}.xml";
//   conversionCounter++;
//   await yaxFileToXmlFile(input, output);
//   return true;
// }

// Future<List<String>> handleSinglePakExtract(
//     String input, String? output, CliOptions args) async {
//   if (!isPakExtractionValid(input, args)) return [];

//   output ??= join(dirname(input), pakExtractSubDir, basename(input));
//   await Directory(output).create(recursive: true);
//   var extractedFiles = await extractPakFiles(input, output);

//   if (args.autoExtractChildren) {
//     return extractedFiles;
//   }

//   return [];
// }

// Future<List<String>> handleSingleDatExtract(
//     String input,
//     String? output,
//     CliOptions args,
//     List<String> activeOptions,
//     bool? isManagerFile,
//     bool? isFirstTimeExtract) async {
//   if (isFirstTimeExtract != null) {
//     if (!isFirstTimeExtract) {
//       if (isDatExtractionValid(input, args, isManagerFile, activeOptions)) {
//         return [];
//       }
//     }
//   }

//   output ??= join(dirname(input), datExtractSubDir, basename(input));

//   if (isManagerFile != true) {
//     await Directory(output).create(recursive: true);
//   }

//   var extractedFiles = await extractDatFiles(input, output);
//   logAndPrint('Extracted files from $input: ${extractedFiles.length} files.');

//   if (args.autoExtractChildren) {
//     return extractedFiles;
//   }

//   return [];
// }
