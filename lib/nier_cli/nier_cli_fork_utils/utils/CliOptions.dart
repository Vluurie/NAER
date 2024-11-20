class CliOptions {
  final String? output;
  final bool folderMode;
  final bool recursiveMode;
  final bool autoExtractChildren;
  final String? wwiseCliPath;
  final bool isCpk;
  final bool isDat;
  final bool isPak;
  final bool isYax;
  final bool fileTypeIsKnown;
  final String? specialDatOutputPath;

  CliOptions({
    required this.output,
    required this.folderMode,
    required this.recursiveMode,
    this.wwiseCliPath,
    required this.isCpk,
    required this.isDat,
    required this.isPak,
    required this.isYax,
    required this.specialDatOutputPath,
  })  : autoExtractChildren = true,
        fileTypeIsKnown = isCpk || isDat || isPak || isYax;

  @override
  String toString() {
    return '''
CliOptions:
  Output: $output
  Folder Mode: $folderMode
  Recursive Mode: $recursiveMode
  Auto Extract Children: $autoExtractChildren
  Wwise CLI Path: ${wwiseCliPath ?? "Not Set"}
  File Type Flags:
    - CPK: $isCpk
    - DAT: $isDat
    - PAK: $isPak
    - YAX: $isYax
  File Type Is Known: $fileTypeIsKnown
  Special DAT Output Path: ${specialDatOutputPath ?? "Not Set"}
''';
  }
}
