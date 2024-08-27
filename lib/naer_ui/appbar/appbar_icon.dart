import 'package:NAER/naer_ui/appbar/informationdialog.dart';
import 'package:NAER/naer_ui/dialog/input_output_file_dialog.dart';
import 'package:NAER/naer_utils/copy_cli_args.dart';
import 'package:flutter/material.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppIcons {
  static Widget informationIcon(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: "Information",
          icon: const Icon(Icons.info, size: 32.0),
          color: AutomatoThemeColors.darkBrown(ref),
          onPressed: () => showInformationDialog(context, ref),
        ),
      ],
    );
  }

  static Widget copyArguments(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            tooltip: "Copy Setup Arguments",
            icon: const Icon(Icons.copy, size: 32.0),
            color: AutomatoThemeColors.darkBrown(ref),
            onPressed: () => onCopyArgsPressed(context, ref)),
      ],
    );
  }

  static Widget searchPaths(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            tooltip: "Search for Paths",
            icon: const Icon(Icons.search, size: 32.0),
            color: AutomatoThemeColors.darkBrown(ref),
            onPressed: () =>
                InputDirectoryHandler().autoSearchInputPath(context, ref)),
      ],
    );
  }

  static Widget showIgnoredFiles(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            tooltip: "Check Ignored Files",
            icon: const Icon(Icons.manage_search, size: 32.0),
            color: AutomatoThemeColors.darkBrown(ref),
            onPressed: () => showIgnoredFilesDialog(context, ref)),
      ],
    );
  }
}
