import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:args/args.dart';

class FileCategoryManager {
  /// A set of quest file names to include for processing.
  final Set<String> includeQuests;

  /// A set of map file names to include for processing.
  final Set<String> includeMaps;

  /// A set of phase logic file names to include for processing.
  final Set<String> includePhaseLogic;

  /// A set of enemy file names to include for processing.
  final Set<String> includeEnemies;

  FileCategoryManager(final ArgResults args)
      : includeQuests = _extractFlags(args, GameFileOptions.questOptions),
        includeMaps = _extractFlags(args, GameFileOptions.mapOptions),
        includePhaseLogic = _extractFlags(args, GameFileOptions.phaseOptions),
        includeEnemies = _extractFlags(args, GameFileOptions.enemyOptions);

  /// Extracts flags from the command-line arguments.
  static Set<String> _extractFlags(
      final ArgResults args, final List<String> options) {
    return options
        .where((final option) => args[option] as bool? ?? false)
        .toSet();
  }

  /// Determines if the file should be processed based on its base name.
  bool shouldProcessFile(final String baseName) {
    if (includeQuests.contains(baseName)) {
      return true; // If it's a quest and it's included, process the file
    } else if (includeMaps.contains(baseName)) {
      return true; // If it's a map and it's included, process the file
    } else if (includePhaseLogic.contains(baseName)) {
      return true; // If it's a phase and it's included, process the file
    } else if (includeEnemies.contains(baseName)) {
      return true; // If it's a phase and it's included, process the file
    }

    // Process the file if all sets are empty
    return includeQuests.isEmpty &&
        includeMaps.isEmpty &&
        includePhaseLogic.isEmpty &&
        includeEnemies.isEmpty;
  }
}
