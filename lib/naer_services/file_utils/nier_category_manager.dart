import 'package:NAER/data/category_data/nier_categories.dart';
import 'package:args/args.dart';

/// Manages file categorization based on command-line arguments.
///
/// The [FileCategoryManager] is responsible for determining whether specific files should
/// be processed based on the categories specified via command-line arguments. It supports
/// three categories: quests, maps, and phase logic.
class FileCategoryManager {
  /// A set of quest file names to include for processing.
  final Set<String> includeQuests;

  /// A set of map file names to include for processing.
  final Set<String> includeMaps;

  /// A set of phase logic file names to include for processing.
  final Set<String> includePhaseLogic;

  /// A set of enemy file names to include for processing.
  final Set<String> includeEnemies;

  /// Constructs a [FileCategoryManager] by extracting flags from command-line arguments.
  ///
  /// The constructor initializes the sets of included quests, maps, and phase logic files
  /// based on the provided [args].
  ///
  /// - Parameters:
  ///   - args: The command-line arguments containing the flags for each category.
  FileCategoryManager(ArgResults args)
      : includeQuests = _extractFlags(args, GameFileOptions.questOptions),
        includeMaps = _extractFlags(args, GameFileOptions.mapOptions),
        includePhaseLogic = _extractFlags(args, GameFileOptions.phaseOptions),
        includeEnemies = _extractFlags(args, GameFileOptions.enemyOptions);

  /// Extracts flags from the command-line arguments.
  ///
  /// This static method iterates over the provided [options] and checks if each option
  /// is enabled in the [args]. It returns a set of options that are enabled.
  ///
  /// - Parameters:
  ///   - args: The command-line arguments containing the flags.
  ///   - options: A list of options to check in the arguments.
  /// - Returns: A set of enabled options.
  static Set<String> _extractFlags(ArgResults args, List<String> options) {
    return options.where((option) => args[option] as bool? ?? false).toSet();
  }

  /// Determines if the file should be processed based on its base name.
  ///
  /// This method checks if the provided [baseName] is included in any of the sets
  /// (quests, maps, or phase logic) and returns true if it should be processed.
  /// If none of the sets contain the [baseName], it returns true only if all sets are empty.
  ///
  /// - Parameters:
  ///   - baseName: The base name of the file to check.
  /// - Returns: True if the file should be processed, false otherwise.
  bool shouldProcessFile(String baseName) {
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
