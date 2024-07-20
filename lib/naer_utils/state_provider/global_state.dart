import 'dart:async';

import 'package:NAER/naer_ui/image_ui/enemy_image_grid.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalState extends ChangeNotifier {
  Completer<void> completer = Completer<void>();
  GlobalKey setupDirectorySelectionKey = GlobalKey();
  GlobalKey setupImageGridKey = GlobalKey();
  GlobalKey setupCategorySelectionKey = GlobalKey();
  GlobalKey setupLogOutputKey = GlobalKey();
  GlobalKey<EnemyImageGridState> enemyImageGridKey = GlobalKey();
  List<String> createdFiles = [];
  List<String> createdDatFiles = [];
  List<String> ignoredModFiles = [];
  List<String> logMessages = [];
  Set<String> loggedStages = {};
  bool isLoading = false;
  bool isButtonEnabled = true;
  bool isLogIconBlinking = false;
  bool hasError = false;
  bool isProcessing = false;
  bool selectAllQuests = true;
  bool selectAllMaps = true;
  bool selectAllPhases = true;
  bool savePaths = false;
  bool isHoveringSelectAll = false;
  bool isHoveringUnselectAll = false;
  bool isHoveringUndo = false;
  bool isHoveringModify = false;
  bool isExtractCopyEnabled = false;
  bool isModManagerPageProcessing = false;
  bool? isBalanceMode = false;
  bool balanceModeCheckBoxValue = false;
  bool _hasDLC = false;
  bool dlcCheckBoxValue = false;
  String input = '';
  String scriptPath = '';
  String specialDatOutputPath = '';
  String? lastLogProcessed;
  int enemyLevel = 1;
  int selectedIndex = 0;
  double enemyStats = 0.0;
  Map<String, bool> stats = {"None": true, "Select All": false};
  Map<String, bool> categories = {};
  Map<String, bool> level = {
    "All Enemies": false,
    "All Enemies without Randomization": false,
    'None': true
  };
  List<dynamic> getAllItems() {
    return [
      ...ScriptingPhase.scriptingPhases
          .where((item) => _hasDLC || item.dlc != true),
      ...MapLocation.mapLocations.where((item) => _hasDLC || item.dlc != true),
      ...SideQuest.sideQuests.where((item) => _hasDLC || item.dlc != true),
    ];
  }

  void clearPaths() {
    input = '';
    specialDatOutputPath = '';
    scriptPath = '';
    savePaths = false;
    notifyListeners();
  }

  bool get hasDLC => _hasDLC;

  void updateDLCOption(bool value) {
    _hasDLC = value;
    dlcCheckBoxValue = _hasDLC;
    notifyListeners();
  }

  void complete() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

final globalStateProvider = ChangeNotifierProvider<GlobalState>((ref) {
  return GlobalState();
});
