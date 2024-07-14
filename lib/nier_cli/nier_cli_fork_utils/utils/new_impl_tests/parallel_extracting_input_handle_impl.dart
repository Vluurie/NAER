// import 'dart:async';
// import 'dart:io';
// import 'package:NAER/naer_utils/isolate_service_extract.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/exception.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/extracted_files_on_runtime.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_extract.dart';
// import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/handle_gamefile_repack.dart';

///TODO TESTS FOR PARALLEL EXTRACTING

// const List<
//     Future<bool> Function(String, String?, CliOptions, bool, bool, List<String>,
//         Set<String>, List<String>, bool? ismanagerFile)> _handlers = [
//   handleDatRepack,
//   handlePakRepack,
//   handleXmlToYax,
// ];

// Future<void> handleInputRepack(
//     String input,
//     String? output,
//     CliOptions args,
//     List<String> pendingFiles,
//     Set<String> processedFiles,
//     List<String> bossList,
//     List<String> activeOptions,
//     bool? ismanagerFile) async {
//   bool isFile = await FileSystemEntity.isFile(input);
//   bool isDirectory = await FileSystemEntity.isDirectory(input);
//   if (!isFile && !isDirectory) {
//     throw FileHandlingException(
//         "Input file or directory does not exist ($input)");
//   }
//   await handleSingleCpkExtract(input, output, args, isFile, isDirectory,
//       pendingFiles, processedFiles, bossList, activeOptions, ismanagerFile);

//   for (var handler in _handlers) {
//     String? currentOutput = output;
//     if (handler == handleDatRepack && args.specialDatOutputPath != null) {
//       currentOutput = args.specialDatOutputPath;
//       print("Using special output path for .dat repacking: $currentOutput");
//     }

//     if (await handler(input, currentOutput, args, isFile, isDirectory,
//         pendingFiles, processedFiles, activeOptions, ismanagerFile)) {
//       return;
//     }
//   }
//   if (!args.autoExtractChildren && !args.recursiveMode && !args.folderMode ||
//       pendingFiles.isEmpty && processedFiles.isEmpty) {
//     throw const FileHandlingException("Unknown file type");
//   }
// }

// Future<void> handleInputCpkExtract(
//     String input,
//     String? output,
//     CliOptions args,
//     List<String> pendingFiles,
//     Set<String> processedFiles,
//     List<String> bossList,
//     List<String> activeOptions,
//     bool? ismanagerFile) async {
//   bool isFile = await FileSystemEntity.isFile(input);
//   bool isDirectory = await FileSystemEntity.isDirectory(input);
//   if (!isFile && !isDirectory) {
//     throw FileHandlingException(
//         "Input file or directory does not exist ($input)");
//   }
//   await handleSingleCpkExtract(input, output, args, isFile, isDirectory,
//       pendingFiles, processedFiles, bossList, activeOptions, ismanagerFile);

//   if (!args.autoExtractChildren && !args.recursiveMode && !args.folderMode ||
//       pendingFiles.isEmpty && processedFiles.isEmpty) {
//     throw const FileHandlingException("Unknown file type");
//   }
// }

// Future<void> processDatFilesInParallel(
//     String? output,
//     CliOptions args,
//     List<String> activeOptions,
//     bool? isManagerFile,
//     bool? isFirstTimeExtract) async {
//   final List<String> datFiles = GlobalRunTimeExtractedFiles.getDatFiles(
//       GlobalRunTimeExtractedFiles.extractedCpkFiles);
//   final isolateService = ExtractIsolateService();

//   // Distribute files among cores
//   final distributedFiles = isolateService.distributeFiles(datFiles);

//   // Create batched tasks to process the files
//   final tasks = <FutureOr<List<String>> Function()>[];
//   distributedFiles.forEach((coreIndex, files) {
//     tasks.add(() async {
//       final resultFiles = <String>[];
//       for (var file in files) {
//         final extractedFiles = await handleSingleDatExtract(file, output, args,
//             activeOptions, isManagerFile, isFirstTimeExtract);
//         resultFiles.addAll(extractedFiles);
//       }
//       return resultFiles;
//     });
//   });

//   // Run tasks in parallel and collect results
//   final results = await isolateService.runTasks(tasks);
//   final allExtractedFiles = results.expand((files) => files).toList();
//   await GlobalRunTimeExtractedFiles.addDatFiles(allExtractedFiles);
// }

// Future<void> processPakFilesInParallel(String? output, CliOptions args) async {
//   final List<String> pakFiles = GlobalRunTimeExtractedFiles.getPakFiles(
//       GlobalRunTimeExtractedFiles.extractedDatFiles);
//   final isolateService = ExtractIsolateService();

//   // Distribute files among cores
//   final distributedFiles = isolateService.distributeFiles(pakFiles);

//   // Create batched tasks to process the files
//   final tasks = <FutureOr<List<String>> Function()>[];
//   distributedFiles.forEach((coreIndex, files) {
//     tasks.add(() async {
//       final resultFiles = <String>[];
//       for (var file in files) {
//         final extractedFiles = await handleSinglePakExtract(file, output, args);
//         resultFiles.addAll(extractedFiles);
//       }
//       return resultFiles;
//     });
//   });

//   // Run tasks in parallel and collect results
//   final results = await isolateService.runTasks(tasks);
//   final allExtractedFiles = results.expand((files) => files).toList();
//   await GlobalRunTimeExtractedFiles.addPakFiles(allExtractedFiles);
// }
