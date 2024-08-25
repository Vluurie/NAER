import 'dart:math';

import 'package:NAER/naer_ui/image_ui/enemy_image_grid.dart';
import 'package:NAER/naer_ui/setup/category_selection_widget.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:NAER/naer_ui/setup/enemy_level_selection_widget.dart';
import 'package:NAER/naer_ui/setup/enemy_stats_selection_widget.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:NAER/naer_utils/state_provider/setup_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SetupConfigFormScreen extends ConsumerStatefulWidget {
  const SetupConfigFormScreen({super.key});

  @override
  SetupConfigFormScreenState createState() => SetupConfigFormScreenState();
}

class SetupConfigFormScreenState extends ConsumerState<SetupConfigFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final globalState = ref.watch(globalStateProvider);
    Map<String, bool> levelMap = globalState.levelMap;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADD SETUP CONFIGURATION',
          style: TextStyle(
            fontSize: 38.0,
            color: AutomatoThemeColors.primaryColor(ref),
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                  offset: const Offset(5.0, 5),
                  color: AutomatoThemeColors.hoverBrown(ref).withOpacity(0.5)),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: () => _saveConfig(context),
              child: Text(
                'Save Configuration',
                style: TextStyle(
                    fontSize: 24, color: AutomatoThemeColors.primaryColor(ref)),
              ),
            ),
          ),
        ],
        backgroundColor: AutomatoThemeColors.darkBrown(ref),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: "title",
                            decoration: const InputDecoration(
                              labelText: "Title",
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.maxLength(20),
                            ]),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: "description",
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "Description",
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.maxLength(100),
                            ]),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: "imageUrl",
                            decoration: const InputDecoration(
                              labelText: "Image URL",
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.url(),
                              FormBuilderValidators.match(
                                  RegExp(
                                      r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png|jpeg)'),
                                  errorText:
                                      'Please provide a valid image URL'),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: EnemyLevelSelection(),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Expanded(
                      child: CategorySelection(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: EnemyStatsSelection(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (levelMap['All Enemies without Randomization'] == false)
                  const EnemyImageGrid(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveConfig(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValues = _formKey.currentState!.value;
      final globalState = ref.watch(globalStateProvider);

      CLIArguments cliArgs = await getGlobalArguments(ref);
      List<String> command = cliArgs.processArgs;
      List<String> arguments = [];

      // Regex to split on spaces but keep arguments with '=' together ... :)
      RegExp exp = RegExp(r'--[^\s=]+(?:=\[[^\]]*\]|=\S+)?|[^\s]+');
      Iterable<RegExpMatch> matches = exp.allMatches(command.join(' '));

      for (var match in matches) {
        arguments.add(match.group(0)!);
      }

      // check if he got ignored files
      if (globalState.ignoredModFiles.isNotEmpty) {
        arguments.add("--ignore=${globalState.ignoredModFiles.join(',')}");
      }

      final newConfig = SetupConfigData(
        id: Random().nextInt(100000).toString(),
        imageUrl: formValues['imageUrl'],
        title: formValues['title'],
        description: formValues['description'],
        level: globalState.enemyLevel.toString(),
        stats: globalState.enemyStats.toString(),
        arguments: arguments,
        isSelected: false,
      );

      print("${newConfig.arguments}");

      // when added it also saves in shared pref
      ref.read(setupConfigProvider.notifier).addConfig(newConfig);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully!')),
        );
      }
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
