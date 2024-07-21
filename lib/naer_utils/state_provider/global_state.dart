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
  List<String> selectedImages = [];
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

  void updateCategories() {
    final allItems = getAllItems();
    final newCategories = <String, bool>{};
    for (var item in allItems) {
      newCategories[item.id] =
          categories[item.id] ?? (item.dlc == true ? _hasDLC : false);
    }
    categories = newCategories;
    notifyListeners();
  }

  bool get hasDLC => _hasDLC;

  void updateDLCOption(bool value) {
    _hasDLC = value;
    dlcCheckBoxValue = _hasDLC;
    notifyListeners();
  }

  void updateEnemyStats(double newValue) {
    enemyStats = newValue;
    notifyListeners();
  }

  void updateSelectedImages(List<String> newSelectedImages) {
    selectedImages = newSelectedImages;
    notifyListeners();
  }

  void updateSelectedCategories(Map<String, bool> newCategories) {
    categories = newCategories;
    notifyListeners();
  }

  void addSelectedImage(String imageName) {
    if (!selectedImages.contains(imageName)) {
      selectedImages.add(imageName);
      notifyListeners();
    }
  }

  void removeSelectedImage(String imageName) {
    if (selectedImages.contains(imageName)) {
      selectedImages.remove(imageName);
      notifyListeners();
    }
  }

  void clearSelectedImages() {
    selectedImages.clear();
    notifyListeners();
  }

  void selectAllImages(List<String> allImageNames) {
    selectedImages = List.from(allImageNames);
    notifyListeners();
  }

  void unselectAllImages() {
    selectedImages.clear();
    notifyListeners();
  }

  void updateEnemyLevel(int newLevel) {
    enemyLevel = newLevel;
    notifyListeners();
  }

  void updateLevel(String levelKey, bool value) {
    if (value || level.values.every((v) => !v)) {
      level.updateAll((key, value) => false);
      level[levelKey] = value;
      notifyListeners();
    }
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
