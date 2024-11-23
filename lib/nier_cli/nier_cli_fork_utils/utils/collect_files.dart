import 'dart:io';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:path/path.dart' as path;

/// Searches the [currentDir] for files and directories
/// with extensions (.yax, .pak, .dat) and categorizes them into lists.
/// Additionally, it searches for data%%%.cpk_extracted and categorizes them.
Map<String, List<String>> collectExtractedGameFiles(final String currentDir) {
  List<String> yaxFiles = [];
  List<String> xmlFiles = [];
  List<String> pakFolders = [];
  List<String> datFolders = [];
  List<String> cpkExtractedFolders = [];

  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.yax')) {
        yaxFiles.add(entity.path);
      }
      if (entity.path.endsWith('.xml')) {
        xmlFiles.add(entity.path);
      }
    } else if (entity is Directory) {
      if (entity.path.endsWith('.pak')) {
        pakFolders.add(entity.path);
      } else if (entity.path.endsWith('.dat')) {
        datFolders.add(entity.path);
      } else if (RegExp(r'data\d{3}\.cpk_extracted$').hasMatch(entity.path)) {
        cpkExtractedFolders.add(entity.path);
      }
    }
  }

  return {
    'yaxFiles': yaxFiles,
    'xmlFiles': xmlFiles,
    'pakFolders': pakFolders,
    'datFolders': datFolders,
    'cpkExtractedFolders': cpkExtractedFolders,
  };
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
    final Map<String, List<String>> collectedFiles,
    final String inputDir) async {
  final outputDir = path.dirname(inputDir);

  final onlyLevelDir = Directory(path.join(outputDir, 'naer_onlylevel'));
  final randomizedDir = Directory(path.join(outputDir, 'naer_randomized'));
  final randomizedAndLevelDir =
      Directory(path.join(outputDir, 'naer_randomized_and_level'));

  await onlyLevelDir.create(recursive: true);
  await randomizedDir.create(recursive: true);
  await randomizedAndLevelDir.create(recursive: true);

  final cpkExtractedFolders = collectedFiles['cpkExtractedFolders'] ?? [];

  for (var folderPath in cpkExtractedFolders) {
    final folderName = path.basename(folderPath);
    final onlyLevelDest = path.join(onlyLevelDir.path, folderName);
    final randomizedDest = path.join(randomizedDir.path, folderName);
    final randomizedAndLevelDest =
        path.join(randomizedAndLevelDir.path, folderName);

    try {
      await copyDirectory(Directory(folderPath), Directory(onlyLevelDest));
      await copyDirectory(Directory(folderPath), Directory(randomizedDest));
      await copyDirectory(
          Directory(folderPath), Directory(randomizedAndLevelDest));
    } catch (e, stackTrace) {
      ExceptionHandler().handle(
        e,
        stackTrace,
        extraMessage: '''
Error occurred while copying collected game files:
- Source Folder: $folderPath
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

Future<void> filterFilesToProcess(
    final Map<String, List<String>> collectedFiles,
    final List<String> activeOptions) async {
  List<String>? datFiles = collectedFiles['datFolders'];
  
  if (datFiles != null && datFiles.isNotEmpty) {
    final activeOptionBasenames = activeOptions.map((final option) => path.basename(option)).toSet();

    datFiles.retainWhere((final dat) {
      final datBasename = path.basename(dat); 
      return activeOptionBasenames.contains(datBasename);
    });

    collectedFiles['datFolders'] = datFiles;
  }

  return;
}


