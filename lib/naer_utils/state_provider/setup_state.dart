import 'dart:convert';

import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupStateNotifier extends StateNotifier<String?> {
  SetupStateNotifier() : super(null) {
    _loadSelectedSetup();
  }

  Future<void> _loadSelectedSetup() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedSetupId');
  }

  Future<void> _saveSelectedSetup(final String? setupId) async {
    final prefs = await SharedPreferences.getInstance();
    if (setupId == null) {
      await prefs.remove('selectedSetupId');
    } else {
      await prefs.setString('selectedSetupId', setupId);
    }
  }

  void selectSetup(final String? setupId) {
    state = setupId;
    _saveSelectedSetup(setupId);
  }

  void deselectSetup() {
    state = null;
    _saveSelectedSetup(null);
  }

  Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedSetupId');
    state = null;
  }
}

final setupStateProvider =
    StateNotifierProvider<SetupStateNotifier, String?>((final ref) {
  return SetupStateNotifier();
});

class SetupConfigNotifier extends StateNotifier<List<SetupConfigData>> {
  final Ref ref;

  SetupConfigNotifier(this.ref) : super([]) {
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? configs = prefs.getStringList('setupConfigs');

    if (configs != null && configs.isNotEmpty) {
      state = configs.map((final config) {
        final setup = SetupConfigData.fromJson(jsonDecode(config));
        final isChecked = prefs.getBool('${setup.id}_checkboxState') ?? false;
        ref
            .read(setup.checkboxStateProvider.notifier)
            .toggle(shouldToggle: isChecked);
        return setup;
      }).toList();
    } else {
      state = SetupData.setups;
      await _saveConfigs();
    }
  }

  Future<void> _saveConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> configs =
        state.map((final config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList('setupConfigs', configs);

    for (var setup in state) {
      final isChecked = ref.read(setup.checkboxStateProvider);
      await prefs.setBool('${setup.id}_checkboxState', isChecked);
    }
  }

  void addConfig(final SetupConfigData config) {
    bool exists =
        state.any((final existingConfig) => existingConfig.id == config.id);
    if (!exists) {
      state = [...state, config];
      _saveConfigs();
    }
  }

  void removeConfig(final SetupConfigData config) {
    state = state.where((final c) => c.id != config.id).toList();
    _saveConfigs();
  }

  void selectSetup(final String id) {
    ref.read(setupStateProvider.notifier).selectSetup(id);
    state = state.map((final setup) {
      setup.isSelected = setup.id == id;
      return setup;
    }).toList();
    _saveConfigs();
  }

  Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('setupConfigs');
    for (var setup in state) {
      await prefs.remove('${setup.id}_checkboxState');
    }

    state = SetupData.setups;
    await _saveConfigs();

    ref.read(setupStateProvider.notifier).deselectSetup();
  }

  SetupConfigData? getCurrentSelectedSetup() {
    final selectedSetupId = ref.read(setupStateProvider);
    try {
      return state.firstWhere((final setup) => setup.id == selectedSetupId);
    } catch (e) {
      return null;
    }
  }
}

final setupConfigProvider =
    StateNotifierProvider<SetupConfigNotifier, List<SetupConfigData>>(
        (final ref) => SetupConfigNotifier(ref));
