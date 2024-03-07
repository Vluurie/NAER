import 'package:NAER/nier_enemy_data/category_data/nier_categories.dart';
import 'package:args/args.dart';

class FileCategoryManager {
  final Set<String> includeQuests;
  final Set<String> includeMaps;
  final Set<String> includePhaseLogic;

  FileCategoryManager(ArgResults args)
      : includeQuests = _extractFlags(args, questOptions),
        includeMaps = _extractFlags(args, mapOptions),
        includePhaseLogic = _extractFlags(args, phaseOptions);

  static Set<String> _extractFlags(ArgResults args, List<String> options) {
    return options.where((option) => args[option] as bool? ?? false).toSet();
  }

  bool shouldProcessFile(String baseName) {
    if (includeQuests.contains(baseName)) {
      return true; // If it's a quest and it's included, process the file
    } else if (includeMaps.contains(baseName)) {
      return true; // If it's a map and it's included, process the file
    } else if (includePhaseLogic.contains(baseName)) {
      return true; // If it's a phase and it's included, process the file
    }

    return includeQuests.isEmpty &&
        includeMaps.isEmpty &&
        includePhaseLogic.isEmpty;
  }
}
