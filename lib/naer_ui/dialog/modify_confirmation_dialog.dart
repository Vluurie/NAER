import 'package:NAER/naer_ui/dialog/details.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/handle_start_modification.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showModifyDialogAndModify(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(BuildContext, bool, List<String>, WidgetRef)
        modifyMethod) {
  List<Widget> modificationDetails = generateModificationDetails(ref);

  AutomatoDialogManager().showYesNoDialog(
    context: context,
    ref: ref,
    title: 'Confirm Modification',
    content: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AutomatoThemeColors.textDialogColor(ref)),
            color: AutomatoThemeColors.darkBrown(ref).withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to start modification? Below are the selected settings:",
                style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...modificationDetails,
            ],
          ),
        ),
      ),
    ),
    onYesPressed: () async {
      Navigator.of(context).pop();
      CLIArguments cliArgs = await getGlobalArguments(ref);
      List<String> arguments = cliArgs.processArgs;
      if (context.mounted) {
        handleStartModification(context, ref, modifyMethod, arguments);
      }
    },
    onNoPressed: () {
      Navigator.of(context).pop();
    },
    yesLabel: 'Yes, Modify',
    noLabel: 'No, I still have work to do.',
    activeHoverColorNo: AutomatoThemeColors.darkBrown(ref),
    activeHoverColorYes: AutomatoThemeColors.saveZone(ref),
    yesButtonColor: AutomatoThemeColors.darkBrown(ref),
    noButtonColor: AutomatoThemeColors.darkBrown(ref),
  );
}
