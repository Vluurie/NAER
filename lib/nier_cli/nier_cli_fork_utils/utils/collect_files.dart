import 'dart:io';

import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/nier_cli/main_data_container.dart';
import 'package:path/path.dart' as path;

/// Searches the [currentDir] for files and directories
/// with extensions (.yax, .pak, .dat) and categorizes them into lists.
/// Additionally, it searches for data%%%.cpk_extracted and categorizes them.
ExtractedFiles collectExtractedGameFiles(
    final String currentDir, final ExtractedFiles extractedFiles) {
  ExtractedFiles yax = collectYaxFiles(currentDir, extractedFiles);
  ExtractedFiles xml = collectXmlFiles(currentDir, extractedFiles);
  ExtractedFiles pak = collectPakFolders(currentDir, extractedFiles);
  ExtractedFiles dat = collectDatFolders(currentDir, extractedFiles);
  ExtractedFiles cpk = collectCpkExtractedFolders(currentDir, extractedFiles);

  return extractedFiles.copyWith(
      cpkExtractedFolders: cpk.cpkExtractedFolders,
      datFolders: dat.datFolders,
      pakFolders: pak.pakFolders,
      yaxFiles: yax.yaxFiles,
      xmlFiles: xml.xmlFiles);
}

ExtractedFiles collectYaxFiles(
    final String currentDir, final ExtractedFiles extractedFiles) {
  List<YaxFile> yaxFiles = [];
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.yax')) {
      yaxFiles.add(YaxFile(path: entity.path));
    }
  }
  return extractedFiles.copyWith(yaxFiles: yaxFiles);
}

ExtractedFiles collectXmlFiles(
    final String currentDir, final ExtractedFiles extractedFiles) {
  List<XmlFile> xmlFiles = [];
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.xml')) {
      xmlFiles.add(XmlFile(path: entity.path));
    }
  }
  return extractedFiles.copyWith(xmlFiles: xmlFiles);
}

ExtractedFiles collectPakFolders(
    final String currentDir, final ExtractedFiles extractedFiles) {
  List<PakFolder> pakFolders = [];
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is Directory && entity.path.endsWith('.pak')) {
      pakFolders.add(PakFolder(path: entity.path));
    }
  }
  return extractedFiles.copyWith(pakFolders: pakFolders);
}

Future<ExtractedFiles> copyWithFilesToBeProcessed(
    final String currentDir, final ExtractedFiles extractedFiles) async {
  // Helper function to filter any file type based on `datFolder` paths
  List<T> filterByDatFolder<T>(final List<T> files, final String Function(T) getPath) {
    return files.where((final file) {
      final filePath = getPath(file);
      return extractedFiles.datFolders.any((final datFolder) =>
          filePath.startsWith(datFolder.path));
    }).toList();
  }

  // Filter all file types
  final filteredPakFolders =
      filterByDatFolder<PakFolder>(extractedFiles.pakFolders, (final pak) => pak.path);

  final filteredYaxFiles =
      filterByDatFolder<YaxFile>(extractedFiles.yaxFiles, (final yax) => yax.path);

  final filteredXmlFiles =
      filterByDatFolder<XmlFile>(extractedFiles.xmlFiles, (final xml) => xml.path);

  return extractedFiles.copyWith(
    pakFolders: filteredPakFolders,
    yaxFiles: filteredYaxFiles,
    xmlFiles: filteredXmlFiles,
  );
}



ExtractedFiles collectDatFolders(
    final String currentDir, final ExtractedFiles extractedFiles) {
  List<DatFolder> datFolders = [];
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is Directory && entity.path.endsWith('.dat')) {
      datFolders.add((DatFolder(path: entity.path)));
    }
  }
  return extractedFiles.copyWith(datFolders: datFolders);
}

ExtractedFiles collectCpkExtractedFolders(
    final String currentDir, final ExtractedFiles extractedFiles) {
  List<CpkExtractedFolder> cpkExtractedFolders = [];
  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is Directory &&
        RegExp(r'data\d{3}\.cpk_extracted$').hasMatch(entity.path)) {
      cpkExtractedFolders.add(CpkExtractedFolder(path: (entity.path)));
    }
  }
  return extractedFiles.copyWith(cpkExtractedFolders: cpkExtractedFolders);
}

/// Takes the map of collected game files and an input directory,
/// then copies the contents of the collected `.cpk_extracted` folders to three
/// target directories: `naer_onlylevel`, `naer_randomized`, and `naer_randomized_and_level`.
///
/// While:
/// onlylevel = Extracted Files that only get modified for the level.
/// randomized = Extracted Files that only get modified for the default randomization without level change.
/// randomized and level = Extracted Files that only get modified for the default randomization and level change.
Future<void> copyCollectedGameFiles(
    final List<CpkExtractedFolder> collectedFiles,
    final String inputDir) async {
  final outputDir = path.dirname(inputDir);

  final onlyLevelDir = Directory(path.join(outputDir, 'naer_onlylevel'));
  final randomizedDir = Directory(path.join(outputDir, 'naer_randomized'));
  final randomizedAndLevelDir =
      Directory(path.join(outputDir, 'naer_randomized_and_level'));

  await onlyLevelDir.create(recursive: true);
  await randomizedDir.create(recursive: true);
  await randomizedAndLevelDir.create(recursive: true);

  for (var folder in collectedFiles) {
    final folderName = path.basename(folder.path);
    final onlyLevelDest = path.join(onlyLevelDir.path, folderName);
    final randomizedDest = path.join(randomizedDir.path, folderName);
    final randomizedAndLevelDest =
        path.join(randomizedAndLevelDir.path, folderName);

    try {
      await copyDirectory(Directory(folder.path), Directory(onlyLevelDest));
      await copyDirectory(Directory(folder.path), Directory(randomizedDest));
      await copyDirectory(
          Directory(folder.path), Directory(randomizedAndLevelDest));
    } catch (e, stackTrace) {
      ExceptionHandler().handle(
        e,
        stackTrace,
        extraMessage: '''
Error occurred while copying collected game files:
- Source Folder: ${folder.path}
- Destination Folders:
  - Only Level: $onlyLevelDest
  - Randomized: $randomizedDest
  - Randomized and Level: $randomizedAndLevelDest
''',
      );
    }
  }
}

/// Copies a directory and its contents to a new location.
///
/// [source] is the directory to copy from.
/// [destination] is the directory to copy to.
///
Future<void> copyDirectory(
    final Directory source, final Directory destination) async {
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (var entity in source.list()) {
    if (entity is Directory) {
      var newDirectory =
          Directory(path.join(destination.path, path.basename(entity.path)));
      await copyDirectory(entity, newDirectory);
    } else if (entity is File) {
      await entity
          .copy(path.join(destination.path, path.basename(entity.path)));
    }
  }
}

Future<ExtractedFiles> copyWithFilteredDatFiles(
    final ExtractedFiles datFilesToFilter,
    final List<DatFolder> activeOptions) async {
  final activeOptionBasenames =
      activeOptions.map((final option) => path.basename(option.path)).toSet();

  final filteredDatFiles = datFilesToFilter.datFolders.where((final dat) {
    final datBasename = path.basename(dat.path);
    return activeOptionBasenames.contains(datBasename);
  }).toList();

  return datFilesToFilter.copyWith(datFolders: filteredDatFiles);
}

