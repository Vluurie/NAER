import 'dart:io';
import 'package:NAER/data/sorted_data/special_enemy_entities.dart';
import 'package:NAER/naer_utils/exception_handler.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:path/path.dart' as path;
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceModeCheckBox extends ConsumerStatefulWidget {
  const BalanceModeCheckBox({super.key});

  @override
  BalanceModeCheckBoxState createState() => BalanceModeCheckBoxState();
}

class BalanceModeCheckBoxState extends ConsumerState<BalanceModeCheckBox> {
  late Future<void> _loadBalanceModeFuture;

  @override
  void initState() {
    super.initState();
    _loadBalanceModeFuture = loadBalanceMode();
  }

  Future<void> loadBalanceMode() async {
    final globalState = ref.read(globalStateProvider.notifier);
    final prefs = await SharedPreferences.getInstance();
    bool? savedValue = prefs.getBool('balance_mode');
    if (savedValue != null) {
      globalState.setBalanceModeCheckBoxValue(
          balanceModeCheckBoxValue: savedValue);
      globalState.setIsBalanceMode(
          isBalanceMode: globalState.readBalanceModeCheckBoxValue());
    }
  }

  Future<void> _saveBalanceMode(final bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('balance_mode', value);
  }

  Future<void> deleteEnemyFilesIfBalanceModeUnchecked() async {
    final globalState = ref.watch(globalStateProvider);
    if (!globalState.isBalanceMode!) {
      final directory = Directory("${globalState.specialDatOutputPath}/em");

      if (!directory.existsSync()) {
        globalLog("Directory does not exist.");
        return;
      }

      final List<FileSystemEntity> files = directory.listSync();

      for (var file in files) {
        if (file is File) {
          final fileNameWithoutExtension =
              path.basenameWithoutExtension(file.path);
          if (SpecialEntities.getDLCFilteredEnemiesToBalance(ref)
              .contains(fileNameWithoutExtension)) {
            try {
              await file.delete();
              globalLog("Deleted file: ${file.path}");
            } catch (e, stackTrace) {
              ExceptionHandler().handle(
                e,
                stackTrace,
                extraMessage:
                    "Error deleting file: ${file.path}. Caught from: deleteEnemyFilesIfBalanceModeUnchecked",
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<void>(
      future: _loadBalanceModeFuture,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading balance mode');
        } else {
          final globalState = ref.read(globalStateProvider.notifier);
          return AutomatoCheckBox(
            initialValue: globalState.readBalanceModeCheckBoxValue(),
            textColorUnchecked: AutomatoThemeColors.primaryColor(ref),
            onChanged: (final bool? newValue) async {
              setState(() {
                globalState.setBalanceModeCheckBoxValue(
                    balanceModeCheckBoxValue: newValue ?? false);
                globalState.setIsBalanceMode(
                    isBalanceMode: globalState.readBalanceModeCheckBoxValue());
                _saveBalanceMode(globalState.readBalanceModeCheckBoxValue());
              });

              if (globalState.readIsBalanceMode()!) {
                globalLog(
                    "Balance Mode enabled, file stats will be changed during modifying process.");
              }

              if (!globalState.readIsBalanceMode()!) {
                await deleteEnemyFilesIfBalanceModeUnchecked();
                globalLog(
                    "Balance Mode disabled, all existing files associated with it have been removed.");
              }
            },
            text: globalState.readBalanceModeCheckBoxValue()
                ? 'Balance Mode: Enabled'
                : 'Balance Mode: Disabled',
          );
        }
      },
    );
  }
}
