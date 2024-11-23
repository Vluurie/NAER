import 'package:NAER/nier_cli/nier_cli_fork_utils/utils/utils_fork.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;

bool isCpkExtractionValid(
    final String input, final List<String> enemyList,
    {required final bool isFile}) {
  if (!input.endsWith(".cpk")) return false;
  if (!isFile) return false;

  var fileName = basename(input).toLowerCase();
  if (!(fileName == 'data002.cpk' ||
      fileName == 'data012.cpk' ||
      fileName == 'data100.cpk' ||
      fileName == 'data006.cpk' ||
      fileName == 'data016.cpk')) {
    return false;
  }

  return true;
}

bool isYaxToXmlValid(final String input,
    {required final bool isFile}) {
  if (!input.endsWith(".yax")) return false;
  if (!isFile) return false;

  return true;
}

bool isPakExtractionValid(final String input,
    {required final bool isFile}) {
  if (!input.endsWith(".pak")) return false;
  if (!isFile) return false;

  return true;
}

bool isDatExtractionValid(
    final String input, final List<String> activeOptions,
    {required final bool isFile, required final bool? isManagerFile}) {
  String normalizePath(final String filePath) {
    return path.normalize(filePath).toLowerCase();
  }

  String normalizedInput = normalizePath(input);
  if (isManagerFile != true) {
    if (!activeOptions.map(normalizePath).contains(normalizedInput)) {
      return false;
    }
  }


  if (!strEndsWithDat(input)) {
    return false;
  }

  if (!isFile) {
    return false;
  }

  return true;
}
