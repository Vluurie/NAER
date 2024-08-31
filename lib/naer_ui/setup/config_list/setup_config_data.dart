import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_ui/setup/config_list/config_data_container.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckboxStateNotifier extends StateNotifier<bool> {
  CheckboxStateNotifier() : super(false);

  void toggle({required final bool shouldToggle}) {
    state = shouldToggle;
  }
}

final checkboxStateProvider =
    StateNotifierProvider<CheckboxStateNotifier, bool>(
  (final ref) => CheckboxStateNotifier(),
);

class SetupConfigData implements ConfigDataContainer {
  @override
  final String id;
  @override
  final String imageUrl;
  @override
  final String title;
  @override
  final String description;
  @override
  bool isSelected;

  @override
  final String level;
  @override
  final String stats;

  @override
  final List<String> arguments;

  final bool showCheckbox;
  final bool? isAddition;
  final String? checkboxText;
  final bool? doesUseDlc;
  final ValueChanged<bool>? onCheckboxChanged;
  final StateNotifierProvider<CheckboxStateNotifier, bool>
      checkboxStateProvider;

  SetupConfigData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.level,
    required this.stats,
    this.isSelected = false,
    required this.arguments,
    this.showCheckbox = false,
    this.checkboxText,
    this.doesUseDlc,
    this.isAddition,
    this.onCheckboxChanged,
  }) : checkboxStateProvider =
            StateNotifierProvider<CheckboxStateNotifier, bool>(
          (final ref) => CheckboxStateNotifier(),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'level': level,
      'stats': stats,
      'arguments': arguments,
      'isSelected': isSelected,
      'showCheckbox': showCheckbox,
      'checkboxText': checkboxText,
      'doesUseDlc': doesUseDlc
    };
  }

  static SetupConfigData fromJson(final Map<String, dynamic> json) {
    return SetupConfigData(
        id: json['id'],
        imageUrl: json['imageUrl'],
        title: json['title'],
        description: json['description'],
        level: json['level'],
        stats: json['stats'],
        arguments: List<String>.from(json['arguments']),
        isSelected: json['isSelected'],
        showCheckbox: json['showCheckbox'] ?? false,
        checkboxText: json['checkboxText'],
        doesUseDlc: json['doesUseDlc'] ?? false);
  }

  @override
  void toggleSelection() {
    isSelected = !isSelected;
  }

  void updateGroundArgument(final String enemyId,
      {required final bool isChecked}) {
    final groundIndex =
        arguments.indexWhere((final arg) => arg.startsWith('--Ground='));
    if (groundIndex != -1) {
      final currentGroundList = arguments[groundIndex]
          .substring('--Ground=['.length, arguments[groundIndex].length - 1)
          .split(',')
          .map((final e) => e.replaceAll('"', ''))
          .toList();

      arguments[groundIndex] = generateGroundGroupArgument(
          currentGroundList, enemyId,
          isChecked: isChecked);
    } else {
      // If --Ground doesn't exist, add it
      arguments
          .add(generateGroundGroupArgument([], enemyId, isChecked: isChecked));
    }
  }

  List<String> generateArguments(final WidgetRef ref) {
    final globalState = ref.read(globalStateProvider);
    return arguments
        .map((final arg) {
          if (arg == '{input}') {
            return globalState.input;
          } else if (arg == '{output}') {
            return globalState.specialDatOutputPath;
          } else if (arg == '{ignore}') {
            if (globalState.ignoredModFiles.isNotEmpty) {
              return "--ignore=${globalState.ignoredModFiles.join(',')}";
            } else {
              return '';
            }
          }
          return arg;
        })
        .where((final arg) => arg.isNotEmpty && arg != '{ignore}')
        .toList();
  }
}
