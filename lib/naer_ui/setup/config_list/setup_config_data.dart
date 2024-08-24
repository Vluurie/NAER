import 'package:NAER/naer_services/xml_files_randomization/nier_xml_modify_utils/handle_enemy_groups.dart';
import 'package:NAER/naer_ui/setup/config_list/config_data_container.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckboxStateNotifier extends StateNotifier<bool> {
  CheckboxStateNotifier() : super(false);

  void toggle(bool value) {
    state = value;
  }
}

final checkboxStateProvider =
    StateNotifierProvider<CheckboxStateNotifier, bool>(
  (ref) => CheckboxStateNotifier(),
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
  final String? checkboxText;
  final ValueChanged<bool>? onCheckboxChanged;

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
    this.onCheckboxChanged,
  });

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
    };
  }

  static SetupConfigData fromJson(Map<String, dynamic> json) {
    return SetupConfigData(
      id: json['id'],
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      level: json['level'],
      stats: json['stats'],
      arguments: List<String>.from(json['arguments']),
      isSelected: json['isSelected'],
    );
  }

  @override
  void toggleSelection() {
    isSelected = !isSelected;
  }

  void updateGroundArgument(bool isChecked, String enemyId) {
    final groundIndex =
        arguments.indexWhere((arg) => arg.startsWith('--Ground='));
    if (groundIndex != -1) {
      // Parse the current ground list
      final currentGroundList = arguments[groundIndex]
          .substring('--Ground=['.length, arguments[groundIndex].length - 1)
          .split(', ')
          .map((e) => e.replaceAll('"', ''))
          .toList();

      // Generate the new --Ground argument
      arguments[groundIndex] =
          generateGroundGroupArgument(currentGroundList, isChecked, enemyId);
    } else {
      // If --Ground doesn't exist, add it
      arguments.add(generateGroundGroupArgument([], isChecked, enemyId));
    }
  }

  List<String> generateArguments(WidgetRef ref) {
    final globalState = ref.read(globalStateProvider);
    return arguments
        .map((arg) {
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
        .where((arg) => arg.isNotEmpty && arg != '{ignore}')
        .toList();
  }
}
