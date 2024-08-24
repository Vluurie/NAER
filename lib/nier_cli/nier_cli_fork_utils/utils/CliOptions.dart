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
  })  : autoExtractChildren = true, // Always set to true
        fileTypeIsKnown = isCpk || isDat || isPak || isYax;
}
