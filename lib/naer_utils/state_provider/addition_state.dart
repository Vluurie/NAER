import 'dart:convert';
import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdditionStateNotifier extends StateNotifier<String?> {
  AdditionStateNotifier() : super(null) {
    _loadSelectedAddition();
  }

  Future<void> _loadSelectedAddition() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedAdditionId');
  }

  Future<void> _saveSelectedAddition(final String? additionId) async {
    final prefs = await SharedPreferences.getInstance();
    if (additionId == null) {
      await prefs.remove('selectedAdditionId');
    } else {
      await prefs.setString('selectedAdditionId', additionId);
    }
  }

  void selectAddition(final String? additionId) {
    state = additionId;
    _saveSelectedAddition(additionId);
  }

  void deselectAddition() {
    state = null;
    _saveSelectedAddition(null);
  }

  Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedAdditionId');
    state = null;
  }
}

final additionStateProvider =
    StateNotifierProvider<AdditionStateNotifier, String?>((final ref) {
  return AdditionStateNotifier();
});

class AdditionConfigNotifier extends StateNotifier<List<SetupConfigData>> {
  final Ref ref;

  AdditionConfigNotifier(this.ref) : super([]) {
    _loadAdditions();
  }

  Future<void> _loadAdditions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? configs = prefs.getStringList('additionConfigs');

    if (configs != null && configs.isNotEmpty) {
      state = configs.map((final config) {
        final addition = SetupConfigData.fromJson(jsonDecode(config));
        final isChecked =
            prefs.getBool('${addition.id}_checkboxState') ?? false;
        ref
            .read(addition.checkboxStateProvider.notifier)
            .toggle(shouldToggle: isChecked);
        return addition;
      }).toList();
    } else {
      state = SetupData.additions;
      await _saveAdditions();
    }
  }

  Future<void> _saveAdditions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> configs =
        state.map((final config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList('additionConfigs', configs);

    for (var addition in state) {
      final isChecked = ref.read(addition.checkboxStateProvider);
      await prefs.setBool('${addition.id}_checkboxState', isChecked);
    }
  }

  void addAddition(final SetupConfigData addition) {
    bool exists =
        state.any((final existingConfig) => existingConfig.id == addition.id);
    if (!exists) {
      state = [...state, addition];
      _saveAdditions();
    }
  }

  void removeAddition(final SetupConfigData addition) {
    state = state.where((final c) => c.id != addition.id).toList();
    _saveAdditions();
  }

  void selectAddition(final String id) {
    ref.read(additionStateProvider.notifier).selectAddition(id);
    state = state.map((final addition) {
      addition.isSelected = addition.id == id;
      return addition;
    }).toList();
    _saveAdditions();
  }

  void deselectAddition() {
    ref.read(additionStateProvider.notifier).deselectAddition();
    state = state.map((final addition) {
      addition.isSelected = false;
      return addition;
    }).toList();
    _saveAdditions();
  }

  Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('additionConfigs');
    for (var addition in state) {
      await prefs.remove('${addition.id}_checkboxState');
    }
    state = SetupData.additions;
    await _saveAdditions();

    ref.read(additionStateProvider.notifier).deselectAddition();
  }

  SetupConfigData? getCurrentSelectedAddition() {
    final selectedAdditionId = ref.read(additionStateProvider);
    try {
      return state
          .firstWhere((final addition) => addition.id == selectedAdditionId);
    } catch (e) {
      return null;
    }
  }
}

final additionConfigProvider =
    StateNotifierProvider<AdditionConfigNotifier, List<SetupConfigData>>(
        (final ref) => AdditionConfigNotifier(ref));
