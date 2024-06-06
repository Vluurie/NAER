import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/CliOptions.dart';
import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;

bool isCpkExtractionValid(
    String input, bool isFile, CliOptions args, List<String> bossList) {
  if (args.fileTypeIsKnown && !args.isCpk) return false;
  if (!input.endsWith(".cpk")) return false;
  if (!isFile) return false;

  var fileName = basename(input).toLowerCase();

  bool isBossListEffectivelyEmpty = bossList.isEmpty ||
      bossList.every(
          (item) => item.trim().isEmpty || item.trim().toLowerCase() == 'none');

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

  return true;
}

bool isYaxToXmlValid(String input, bool isFile, CliOptions args) {
  if (args.fileTypeIsKnown && !args.isYax) return false;
  if (!input.endsWith(".yax")) return false;
  if (!isFile) return false;

  return true;
}

bool isPakExtractionValid(String input, bool isFile, CliOptions args) {
  if (args.fileTypeIsKnown && !args.isPak) return false;
  if (!input.endsWith(".pak")) return false;
  if (!isFile) return false;

  return true;
}

bool isDatExtractionValid(String input, bool isFile, CliOptions args,
    bool? isManagerFile, List<String> activeOptions) {
  String normalizePath(String filePath) {
    return path.normalize(filePath).toLowerCase();
  }

  String normalizedInput = normalizePath(input);
  if (isManagerFile != true) {
    if (!activeOptions.map(normalizePath).contains(normalizedInput)) {
      return false;
    }
  }

  if (args.fileTypeIsKnown && !args.isDat) {
    return false;
  }

  if (!strEndsWithDat(input)) {
    return false;
  }

  if (!isFile) {
    return false;
  }

  return true;
}
