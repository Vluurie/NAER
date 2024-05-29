import 'dart:io';

/// Collects files from the specified directory.
///
/// This function recursively searches the [currentDir] for files and directories
/// for extensions (.yax, .pak, .dat) and categorizes them into lists.
/// It returns a map containing these lists.
///
/// [currentDir] is the directory to search for files and directories.
///
/// Returns a [Map] with the following keys and corresponding lists:
/// - `'yaxFiles'`: List of paths to .yax files.
/// - `'pakFolders'`: List of paths to directories ending with .pak.
/// - `'datFolders'`: List of paths to directories ending with .dat.
///
Map<String, List<String>> collectExtractedGameFiles(String currentDir) {
  List<String> yaxFiles = [];
  List<String> pakFolders = [];
  List<String> datFolders = [];

  for (var entity in Directory(currentDir).listSync(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.yax')) {
        yaxFiles.add(entity.path);
      }
    } else if (entity is Directory) {
      if (entity.path.endsWith('.pak')) {
        pakFolders.add(entity.path);
      } else if (entity.path.endsWith('.dat')) {
        datFolders.add(entity.path);
      }
    }
  }

  return {
    'yaxFiles': yaxFiles,
    'pakFolders': pakFolders,
    'datFolders': datFolders,
  };
}
