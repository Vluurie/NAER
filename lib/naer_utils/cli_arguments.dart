class CLIArguments {
  final String input;
  final String specialDatOutputPath;
  final String tempFilePath;
  final String bossList;
  final List<String> processArgs;
  final String command;
  final List<String> fullCommand;

  CLIArguments({
    required this.input,
    required this.specialDatOutputPath,
    required this.tempFilePath,
    required this.bossList,
    required this.processArgs,
    required this.command,
    required this.fullCommand,
  });
}
