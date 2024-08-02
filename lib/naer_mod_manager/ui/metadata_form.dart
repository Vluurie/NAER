import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_directory_structure.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_form_fields.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_id_form_widget.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_image_selection.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_savebutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:automato_theme/automato_theme.dart';

import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_mod_manager/utils/metadata_utils.dart';

class MetadataForm extends ConsumerStatefulWidget {
  const MetadataForm({
    super.key,
    required this.cliArguments,
    required this.modStateManager,
  });

  final CLIArguments cliArguments;
  final ModStateManager modStateManager;

  @override
  MetadataFormState createState() => MetadataFormState();
}

class MetadataFormState extends ConsumerState<MetadataForm> {
  late MetadataProvider metadataProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    metadataProvider = MetadataProvider(ref);
  }

  @override
  Widget build(BuildContext context) {
    final metadata = metadataProvider;
    return Scaffold(
        body: Stack(children: [
      AutomatoBackground(
        backgroundColor: AutomatoThemeColors.darkBrown(ref),
        showRepeatingBorders: false,
        gradientColor: AutomatoThemeColors.gradient(ref),
        linesConfig: LinesConfig(
            lineColor: AutomatoThemeColors.primaryColor(ref),
            strokeWidth: 1.0,
            spacing: 5.0,
            flickerDuration: const Duration(milliseconds: 10000),
            enableFlicker: false,
            drawHorizontalLines: true,
            drawVerticalLines: true),
        ref: ref,
      ),
      Scaffold(
        backgroundColor: AutomatoThemeColors.transparentColor(ref),
        appBar: AppBar(
          title: const Text("Metadata Form"),
          backgroundColor: AutomatoThemeColors.transparentColor(ref),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: metadata.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "Add custom mods to the mod list.",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AutomatoThemeColors.primaryColor(ref)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  MetaDataFormFields(
                    ref: ref,
                    idController: metadata.idController,
                    nameController: metadata.nameController,
                    versionController: metadata.versionController,
                    authorController: metadata.authorController,
                    descriptionController: metadata.descriptionController,
                  ),
                  MetadataIDFormFieldWidget(metadata: metadata),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final selectedImagePath =
                              ref.watch(selectedImagePathProvider);

                          return buildMetadataImageSelection(
                              selectedImagePath, ref, context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: ButtonTheme(
                              minWidth: 300,
                              child: ElevatedButton(
                                onPressed: () =>
                                    MetadataUtils.addFileField(ref),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AutomatoThemeColors.primaryColor(ref),
                                  padding: const EdgeInsets.all(20),
                                ),
                                child: Text(
                                  'Add Modfolder',
                                  style: TextStyle(
                                      color:
                                          AutomatoThemeColors.darkBrown(ref)),
                                ),
                              ))),
                    ],
                  ),
                  const DirectoryStructureWidget(),
                  const SizedBox(height: 10),
                  SaveMetadataButton(
                    metadata: metadata,
                    modStateManager: widget.modStateManager,
                  )
                ],
              ),
            ),
          ),
        ),
      )
    ]));
  }
}
