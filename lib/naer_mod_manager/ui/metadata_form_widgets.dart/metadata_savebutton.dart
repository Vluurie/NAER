import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:NAER/naer_mod_manager/utils/metadata_utils.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final warningProvider = StateProvider<bool>((final ref) => false);

class SaveMetadataButton extends ConsumerWidget {
  final MetadataProvider metadata;
  final ModStateManager modStateManager;

  const SaveMetadataButton({
    super.key,
    required this.metadata,
    required this.modStateManager,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    bool warning = ref.watch(warningProvider);

    return Row(
      children: [
        Align(
          child: ButtonTheme(
            minWidth: 100,
            child: ElevatedButton(
              onPressed: () {
                bool formIsValid =
                    metadata.formKey.currentState?.validate() ?? false;
                bool directoryHasContents = ref
                    .watch(directoryContentsInfoProvider.notifier)
                    .state
                    .isNotEmpty;

                if (formIsValid && directoryHasContents) {
                  final dlcValue = ref.read(dlcControllerProvider);
                  MetadataUtils.saveMetadata(ref, modStateManager, dlcValue);
                  Navigator.of(context).pop();
                } else {
                  ref.read(warningProvider.notifier).state =
                      !directoryHasContents;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(20),
              ),
              child: const Text('Save Metadata'),
            ),
          ),
        ),
        if (warning)
          Visibility(
            visible: warning,
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Please add a mod folder or check your input again before saving.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
