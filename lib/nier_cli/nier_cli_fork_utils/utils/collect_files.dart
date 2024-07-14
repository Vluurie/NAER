import 'dart:io';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/log_print.dart';
import 'package:path/path.dart' as path;

/// Collects files and folders from the specified directory.
///
/// This function recursively searches the [currentDir] for files and directories
/// with specific extensions (.yax, .pak, .dat) and categorizes them into lists.
/// Additionally, it searches for folders matching the pattern data%%%.cpk_extracted
/// and categorizes them.
///
/// [currentDir] is the directory to search for files and directories.
///
/// Returns a [Map] with the following keys and corresponding lists:
/// - `'yaxFiles'`: List of paths to .yax files.
/// - `'pakFolders'`: List of paths to directories ending with .pak.
/// - `'datFolders'`: List of paths to directories ending with .dat.
/// - `'cpkExtractedFolders'`: List of paths to directories matching data%%%.cpk_extracted.
///
Map<String, List<String>> collectExtractedGameFiles(String currentDir) {
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

/// Copies extracted collected game files to the parent directorie of the data folder.
///
/// This function takes a map of collected game files and an input directory,
/// then copies the contents of the collected `.cpk_extracted` folders to three
/// target directories: `naer_onlylevel`, `naer_randomized`, and `naer_randomized_and_level`.
///
/// While:
/// onlylevel = Extracted Files that only get modified for the level.
/// randomized = Extracted Files that only get modified for the default randomization without level change.
/// randomized and level = Extracted Files that only get modified for the default randomization and level change.
///
/// [collectedFiles] is a map containing lists of collected file and directory paths.
/// The key `'cpkExtractedFolders'` should map to a list of directory paths to be copied.
/// [inputDir] is the initial directory used to determine the base output directory.
///
/// The function ensures that the target directories exist, and then recursively copies
/// each collected folder into these target directories, maintaining the directory structure.
///
/// If an error occurs during the copying process, the error is printed to the console.
///
/// This function relies on [copyDirectory] to perform the actual copying of directories and files.
Future<void> copyCollectedGameFiles(
    Map<String, List<String>> collectedFiles, String inputDir) async {
  final outputDir = path.dirname(inputDir);

  final onlyLevelDir = Directory(path.join(outputDir, 'naer_onlylevel'));
  final randomizedDir = Directory(path.join(outputDir, 'naer_randomized'));
  final randomizedAndLevelDir =
      Directory(path.join(outputDir, 'naer_randomized_and_level'));

  // Ensure the directories exist
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
      // Copy directory to each of the target directories
      await copyDirectory(Directory(folderPath), Directory(onlyLevelDest));
      await copyDirectory(Directory(folderPath), Directory(randomizedDest));
      await copyDirectory(
          Directory(folderPath), Directory(randomizedAndLevelDest));
    } catch (e) {
      logAndPrint('Error copying $folderPath: $e');
    }
  }
}

/// Copies a directory and its contents to a new location.
///
/// This function recursively copies the contents of the [source] directory to the
/// [destination] directory. If the [destination] directory does not exist, it is created.
/// Each file and subdirectory in the [source] directory is copied to the [destination].
///
/// [source] is the directory to copy from.
/// [destination] is the directory to copy to.
///
Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (var entity in source.list(recursive: false)) {
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
