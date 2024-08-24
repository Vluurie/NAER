import 'dart:convert';

import 'package:NAER/data/setup_data/setup_data.dart';
import 'package:NAER/naer_ui/setup/config_list/setup_config_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StateNotifier to manage the selected setup's state
class SetupStateNotifier extends StateNotifier<String?> {
  SetupStateNotifier() : super(null) {
    _loadSelectedSetup();
  }

  // Load the saved setup ID from shared preferences
  Future<void> _loadSelectedSetup() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedSetupId');
  }

  // Save the selected setup ID to shared preferences
  Future<void> _saveSelectedSetup(String? setupId) async {
    final prefs = await SharedPreferences.getInstance();
    if (setupId == null) {
      await prefs.remove('selectedSetupId');
    } else {
      await prefs.setString('selectedSetupId', setupId);
    }
  }

  // Select a new setup and persist it
  void selectSetup(String? setupId) {
    state = setupId;
    _saveSelectedSetup(setupId);
  }

  // Deselect the current setup
  void deselectSetup() {
    state = null;
    _saveSelectedSetup(null);
  }
}

// Provider for the SetupStateNotifier
final setupStateProvider =
    StateNotifierProvider<SetupStateNotifier, String?>((ref) {
  return SetupStateNotifier();
});

class SetupConfigNotifier extends StateNotifier<List<SetupConfigData>> {
  final Ref ref; // Declare a private ref variable

  SetupConfigNotifier(this.ref) : super([]) {
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? configs = prefs.getStringList('setupConfigs');

    if (configs != null && configs.isNotEmpty) {
      state = configs
          .map((config) => SetupConfigData.fromJson(jsonDecode(config)))
          .toList();
    } else {
      state = SetupData.setups;
      _saveConfigs();
    }
  }

  void addConfig(SetupConfigData config) {
    bool exists = state.any((existingConfig) => existingConfig.id == config.id);
    if (!exists) {
      state = [...state, config];
      _saveConfigs();
    }
  }

  void removeConfig(SetupConfigData config) {
    state = state.where((c) => c.id != config.id).toList();
    _saveConfigs();
  }

  void selectSetup(String id) {
    ref.read(setupStateProvider.notifier).selectSetup(id);
    state = state.map((setup) {
      setup.isSelected = setup.id == id;
      return setup;
    }).toList();
    _saveConfigs();
  }

  SetupConfigData? getCurrentSelectedSetup() {
    final selectedSetupId = ref.read(setupStateProvider);
    try {
      return state.firstWhere((setup) => setup.id == selectedSetupId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> configs =
        state.map((config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList('setupConfigs', configs);
  }
}

final setupConfigProvider =
    StateNotifierProvider<SetupConfigNotifier, List<SetupConfigData>>(
        (ref) => SetupConfigNotifier(ref));
