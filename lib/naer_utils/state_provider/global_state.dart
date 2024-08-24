import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NAER/naer_ui/image_ui/enemy_image_grid.dart';
import 'package:NAER/data/sorted_data/nier_maps.dart';
import 'package:NAER/data/sorted_data/nier_script_phase.dart';
import 'package:NAER/data/sorted_data/nier_side_quests.dart';

final globalStateProvider =
    StateNotifierProvider<GlobalStateNotifier, GlobalState>((ref) {
  return GlobalStateNotifier();
});

class GlobalState {
  final Completer<void> completer;
  final GlobalKey setupDirectorySelectionKey;
  final GlobalKey setupImageGridKey;
  final GlobalKey setupCategorySelectionKey;
  final GlobalKey setupLogOutputKey;
  final GlobalKey<EnemyImageGridState> enemyImageGridKey;
  final List<String> selectedImages;
  final List<String> createdFiles;
  final List<String> createdDatFiles;
  final List<String> ignoredModFiles;
  final List<String> logMessages;
  final Set<String> loggedStages;
  final bool isLoading;
  final bool isButtonEnabled;
  final bool isLogIconBlinking;
  final bool hasError;
  final bool isProcessing;
  final bool selectAllQuests;
  final bool selectAllMaps;
  final bool selectAllPhases;
  final bool savePaths;
  final bool isHoveringSelectAll;
  final bool isHoveringUnselectAll;
  final bool isHoveringUndo;
  final bool isHoveringModify;
  final bool isExtractCopyEnabled;
  final bool isModManagerPageProcessing;
  final bool? isBalanceMode;
  final bool balanceModeCheckBoxValue;
  final bool hasDLC;
  final bool dlcCheckBoxValue;
  final String input;
  final String specialDatOutputPath;
  final String? lastLogProcessed;
  final bool customSelection;
  final int enemyLevel;
  final int selectedIndex;
  final double enemyStats;
  final bool checkboxValueForPaths;
  final Map<String, bool> stats;
  final Map<String, bool> categories;
  final Map<String, bool> levelMap;
  final bool isPanelVisible;

  GlobalState({
    Completer<void>? completer,
    GlobalKey? setupDirectorySelectionKey,
    GlobalKey? setupImageGridKey,
    GlobalKey? setupCategorySelectionKey,
    GlobalKey? setupLogOutputKey,
    GlobalKey<EnemyImageGridState>? enemyImageGridKey,
    List<String>? selectedImages,
    List<String>? createdFiles,
    List<String>? createdDatFiles,
    List<String>? ignoredModFiles,
    List<String>? logMessages,
    Set<String>? loggedStages,
    bool? isLoading,
    bool? isButtonEnabled,
    bool? isLogIconBlinking,
    bool? hasError,
    bool? isProcessing,
    bool? selectAllQuests,
    bool? selectAllMaps,
    bool? selectAllPhases,
    bool? savePaths,
    bool? isHoveringSelectAll,
    bool? isHoveringUnselectAll,
    bool? isHoveringUndo,
    bool? isHoveringModify,
    bool? isExtractCopyEnabled,
    bool? isModManagerPageProcessing,
    bool? isBalanceMode,
    bool? balanceModeCheckBoxValue,
    bool? hasDLC,
    bool? dlcCheckBoxValue,
    String? input,
    String? specialDatOutputPath,
    this.lastLogProcessed,
    bool? customSelection,
    int? enemyLevel,
    int? selectedIndex,
    double? enemyStats,
    bool? checkboxValueForPaths,
    Map<String, bool>? stats,
    Map<String, bool>? categories,
    Map<String, bool>? levelMap,
    bool? isPanelVisible,
  })  : completer = completer ?? Completer<void>(),
        setupDirectorySelectionKey = setupDirectorySelectionKey ?? GlobalKey(),
        setupImageGridKey = setupImageGridKey ?? GlobalKey(),
        setupCategorySelectionKey = setupCategorySelectionKey ?? GlobalKey(),
        setupLogOutputKey = setupLogOutputKey ?? GlobalKey(),
        enemyImageGridKey = enemyImageGridKey ?? GlobalKey(),
        selectedImages = selectedImages ?? const [],
        createdFiles = createdFiles ?? const [],
        createdDatFiles = createdDatFiles ?? const [],
        ignoredModFiles = ignoredModFiles ?? const [],
        logMessages = logMessages ?? const [],
        loggedStages = loggedStages ?? const {},
        isLoading = isLoading ?? false,
        isButtonEnabled = isButtonEnabled ?? true,
        isLogIconBlinking = isLogIconBlinking ?? false,
        hasError = hasError ?? false,
        isProcessing = isProcessing ?? false,
        selectAllQuests = selectAllQuests ?? true,
        selectAllMaps = selectAllMaps ?? true,
        selectAllPhases = selectAllPhases ?? true,
        savePaths = savePaths ?? false,
        isHoveringSelectAll = isHoveringSelectAll ?? false,
        isHoveringUnselectAll = isHoveringUnselectAll ?? false,
        isHoveringUndo = isHoveringUndo ?? false,
        isHoveringModify = isHoveringModify ?? false,
        isExtractCopyEnabled = isExtractCopyEnabled ?? false,
        isModManagerPageProcessing = isModManagerPageProcessing ?? false,
        isBalanceMode = isBalanceMode ?? false,
        balanceModeCheckBoxValue = balanceModeCheckBoxValue ?? false,
        hasDLC = hasDLC ?? false,
        dlcCheckBoxValue = dlcCheckBoxValue ?? false,
        input = input ?? '',
        specialDatOutputPath = specialDatOutputPath ?? '',
        customSelection = customSelection ?? false,
        enemyLevel = enemyLevel ?? 1,
        selectedIndex = selectedIndex ?? 0,
        enemyStats = enemyStats ?? 0.0,
        checkboxValueForPaths = checkboxValueForPaths ?? false,
        stats = stats ?? const {"None": true, "Select All": false},
        categories = categories ?? const {},
        isPanelVisible = isPanelVisible ?? false,
        levelMap = levelMap ??
            const {
              "All Enemies": false,
              "All Enemies without Randomization": false,
              'None': true,
            };

  GlobalState copyWith(
      {Completer<void>? completer,
      GlobalKey? setupDirectorySelectionKey,
      GlobalKey? setupImageGridKey,
      GlobalKey? setupCategorySelectionKey,
      GlobalKey? setupLogOutputKey,
      GlobalKey<EnemyImageGridState>? enemyImageGridKey,
      List<String>? selectedImages,
      List<String>? createdFiles,
      List<String>? createdDatFiles,
      List<String>? ignoredModFiles,
      List<String>? logMessages,
      Set<String>? loggedStages,
      bool? isLoading,
      bool? isButtonEnabled,
      bool? isLogIconBlinking,
      bool? hasError,
      bool? isProcessing,
      bool? selectAllQuests,
      bool? selectAllMaps,
      bool? selectAllPhases,
      bool? savePaths,
      bool? isHoveringSelectAll,
      bool? isHoveringUnselectAll,
      bool? isHoveringUndo,
      bool? isHoveringModify,
      bool? isExtractCopyEnabled,
      bool? isModManagerPageProcessing,
      bool? isBalanceMode,
      bool? balanceModeCheckBoxValue,
      bool? hasDLC,
      bool? dlcCheckBoxValue,
      String? input,
      String? specialDatOutputPath,
      String? lastLogProcessed,
      bool? customSelection,
      int? enemyLevel,
      int? selectedIndex,
      double? enemyStats,
      bool? checkboxValueForPaths,
      Map<String, bool>? stats,
      Map<String, bool>? categories,
      Map<String, bool>? levelMap,
      bool? isPanelVisible}) {
    return GlobalState(
        completer: completer ?? this.completer,
        setupDirectorySelectionKey:
            setupDirectorySelectionKey ?? this.setupDirectorySelectionKey,
        setupImageGridKey: setupImageGridKey ?? this.setupImageGridKey,
        setupCategorySelectionKey:
            setupCategorySelectionKey ?? this.setupCategorySelectionKey,
        setupLogOutputKey: setupLogOutputKey ?? this.setupLogOutputKey,
        enemyImageGridKey: enemyImageGridKey ?? this.enemyImageGridKey,
        selectedImages: selectedImages ?? this.selectedImages,
        createdFiles: createdFiles ?? this.createdFiles,
        createdDatFiles: createdDatFiles ?? this.createdDatFiles,
        ignoredModFiles: ignoredModFiles ?? this.ignoredModFiles,
        logMessages: logMessages ?? this.logMessages,
        loggedStages: loggedStages ?? this.loggedStages,
        isLoading: isLoading ?? this.isLoading,
        isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
        isLogIconBlinking: isLogIconBlinking ?? this.isLogIconBlinking,
        hasError: hasError ?? this.hasError,
        isProcessing: isProcessing ?? this.isProcessing,
        selectAllQuests: selectAllQuests ?? this.selectAllQuests,
        selectAllMaps: selectAllMaps ?? this.selectAllMaps,
        selectAllPhases: selectAllPhases ?? this.selectAllPhases,
        savePaths: savePaths ?? this.savePaths,
        isHoveringSelectAll: isHoveringSelectAll ?? this.isHoveringSelectAll,
        isHoveringUnselectAll:
            isHoveringUnselectAll ?? this.isHoveringUnselectAll,
        isHoveringUndo: isHoveringUndo ?? this.isHoveringUndo,
        isHoveringModify: isHoveringModify ?? this.isHoveringModify,
        isExtractCopyEnabled: isExtractCopyEnabled ?? this.isExtractCopyEnabled,
        isModManagerPageProcessing:
            isModManagerPageProcessing ?? this.isModManagerPageProcessing,
        isBalanceMode: isBalanceMode ?? this.isBalanceMode,
        balanceModeCheckBoxValue:
            balanceModeCheckBoxValue ?? this.balanceModeCheckBoxValue,
        hasDLC: hasDLC ?? this.hasDLC,
        dlcCheckBoxValue: dlcCheckBoxValue ?? this.dlcCheckBoxValue,
        input: input ?? this.input,
        specialDatOutputPath: specialDatOutputPath ?? this.specialDatOutputPath,
        lastLogProcessed: lastLogProcessed ?? this.lastLogProcessed,
        customSelection: customSelection ?? this.customSelection,
        enemyLevel: enemyLevel ?? this.enemyLevel,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        enemyStats: enemyStats ?? this.enemyStats,
        checkboxValueForPaths:
            checkboxValueForPaths ?? this.checkboxValueForPaths,
        stats: stats ?? this.stats,
        categories: categories ?? this.categories,
        levelMap: levelMap ?? this.levelMap,
        isPanelVisible: isPanelVisible ?? this.isPanelVisible);
  }
}

Future<void> resetGlobalState(WidgetRef ref) async {
  ref.read(globalStateProvider.notifier).resetState();
}

class GlobalStateNotifier extends StateNotifier<GlobalState> {
  GlobalStateNotifier() : super(GlobalState());

  void resetState() {
    state = GlobalState();
  }

  // READ STATE METHODS
  List<String> readSelectedImages() => state.selectedImages;
  List<String> readCreatedFiles() => state.createdFiles;
  List<String> readCreatedDatFiles() => state.createdDatFiles;
  List<String> readIgnoredModFiles() => state.ignoredModFiles;
  List<String> readLogMessages() => state.logMessages;
  Set<String> readLoggedStages() => state.loggedStages;
  bool readIsLoading() => state.isLoading;
  bool readIsButtonEnabled() => state.isButtonEnabled;
  bool readIsLogIconBlinking() => state.isLogIconBlinking;
  bool readHasError() => state.hasError;
  bool readIsProcessing() => state.isProcessing;
  bool readSelectAllQuests() => state.selectAllQuests;
  bool readSelectAllMaps() => state.selectAllMaps;
  bool readSelectAllPhases() => state.selectAllPhases;
  bool readSavePaths() => state.savePaths;
  bool readIsHoveringSelectAll() => state.isHoveringSelectAll;
  bool readIsHoveringUnselectAll() => state.isHoveringUnselectAll;
  bool readIsHoveringUndo() => state.isHoveringUndo;
  bool readIsHoveringModify() => state.isHoveringModify;
  bool readIsExtractCopyEnabled() => state.isExtractCopyEnabled;
  bool readIsModManagerPageProcessing() => state.isModManagerPageProcessing;
  bool? readIsBalanceMode() => state.isBalanceMode;
  bool readBalanceModeCheckBoxValue() => state.balanceModeCheckBoxValue;
  bool readHasDLC() => state.hasDLC;
  bool readDLCCheckBoxValue() => state.dlcCheckBoxValue;
  String readInput() => state.input;
  String readSpecialDatOutputPath() => state.specialDatOutputPath;
  String? readLastLogProcessed() => state.lastLogProcessed;
  bool readCustomSelection() => state.customSelection;
  int readEnemyLevel() => state.enemyLevel;
  int readSelectedIndex() => state.selectedIndex;
  double readEnemyStats() => state.enemyStats;
  bool readCheckboxValueForPaths() => state.checkboxValueForPaths;
  Map<String, bool> readStats() => state.stats;
  Map<String, bool> readCategories() => state.categories;
  Map<String, bool> readLevelMap() => state.levelMap;
  bool readIsPanelVisible() => state.isPanelVisible;

  // WRITE STATE METHODS
  void setSelectedImages(List<String> selectedImages) {
    state = state.copyWith(selectedImages: selectedImages);
  }

  void setCreatedFiles(List<String> createdFiles) {
    state = state.copyWith(createdFiles: createdFiles);
  }

  void setCreatedDatFiles(List<String> createdDatFiles) {
    state = state.copyWith(createdDatFiles: createdDatFiles);
  }

  void setIgnoredModFiles(List<String> ignoredModFiles) {
    state = state.copyWith(ignoredModFiles: ignoredModFiles);
  }

  void setLogMessages(List<String> logMessages) {
    state = state.copyWith(logMessages: logMessages);
  }

  void setLoggedStages(Set<String> loggedStages) {
    state = state.copyWith(loggedStages: loggedStages);
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setIsButtonEnabled(bool isButtonEnabled) {
    state = state.copyWith(isButtonEnabled: isButtonEnabled);
  }

  void setIsLogIconBlinking(bool isLogIconBlinking) {
    state = state.copyWith(isLogIconBlinking: isLogIconBlinking);
  }

  void setHasError(bool hasError) {
    state = state.copyWith(hasError: hasError);
  }

  void setIsProcessing(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }

  void setSelectAllQuests(bool selectAllQuests) {
    state = state.copyWith(selectAllQuests: selectAllQuests);
  }

  void setSelectAllMaps(bool selectAllMaps) {
    state = state.copyWith(selectAllMaps: selectAllMaps);
  }

  void setSelectAllPhases(bool selectAllPhases) {
    state = state.copyWith(selectAllPhases: selectAllPhases);
  }

  void setSavePaths(bool savePaths) {
    state = state.copyWith(savePaths: savePaths);
  }

  void setIsHoveringSelectAll(bool isHoveringSelectAll) {
    state = state.copyWith(isHoveringSelectAll: isHoveringSelectAll);
  }

  void setIsHoveringUnselectAll(bool isHoveringUnselectAll) {
    state = state.copyWith(isHoveringUnselectAll: isHoveringUnselectAll);
  }

  void setIsHoveringUndo(bool isHoveringUndo) {
    state = state.copyWith(isHoveringUndo: isHoveringUndo);
  }

  void setIsHoveringModify(bool isHoveringModify) {
    state = state.copyWith(isHoveringModify: isHoveringModify);
  }

  void setIsExtractCopyEnabled(bool isExtractCopyEnabled) {
    state = state.copyWith(isExtractCopyEnabled: isExtractCopyEnabled);
  }

  void setIsModManagerPageProcessing(bool isModManagerPageProcessing) {
    state =
        state.copyWith(isModManagerPageProcessing: isModManagerPageProcessing);
  }

  void setIsBalanceMode(bool? isBalanceMode) {
    state = state.copyWith(isBalanceMode: isBalanceMode);
  }

  void setBalanceModeCheckBoxValue(bool balanceModeCheckBoxValue) {
    state = state.copyWith(balanceModeCheckBoxValue: balanceModeCheckBoxValue);
  }

  void setHasDLC(bool hasDLC) {
    state = state.copyWith(hasDLC: hasDLC);
  }

  void setDLCCheckBoxValue(bool dlcCheckBoxValue) {
    state = state.copyWith(dlcCheckBoxValue: dlcCheckBoxValue);
  }

  void setInput(String input) {
    state = state.copyWith(input: input);
  }

  void setSpecialDatOutputPath(String specialDatOutputPath) {
    state = state.copyWith(specialDatOutputPath: specialDatOutputPath);
  }

  void setLastLogProcessed(String? lastLogProcessed) {
    state = state.copyWith(lastLogProcessed: lastLogProcessed);
  }

  void setCustomSelection(bool customSelection) {
    state = state.copyWith(customSelection: customSelection);
  }

  void setEnemyLevel(int enemyLevel) {
    state = state.copyWith(enemyLevel: enemyLevel);
  }

  void setSelectedIndex(int selectedIndex) {
    state = state.copyWith(selectedIndex: selectedIndex);
  }

  void setEnemyStats(double enemyStats) {
    state = state.copyWith(enemyStats: enemyStats);
  }

  void setCheckboxValueForPaths(bool checkboxValueForPaths) {
    state = state.copyWith(checkboxValueForPaths: checkboxValueForPaths);
  }

  void setStats(Map<String, bool> stats) {
    state = state.copyWith(stats: stats);
  }

  void setCategories(Map<String, bool> categories) {
    state = state.copyWith(categories: categories);
  }

  void setLevel(Map<String, bool> level) {
    state = state.copyWith(levelMap: level);
  }

  void setIsPanelVisible(bool isPanelVisible) {
    state = state.copyWith(isPanelVisible: isPanelVisible);
  }

  // CLEAR STATE METHODS
  void clearSelectedImages() {
    state = state.copyWith(selectedImages: []);
  }

  void clearCreatedFiles() {
    state = state.copyWith(createdFiles: []);
  }

  void clearCreatedDatFiles() {
    state = state.copyWith(createdDatFiles: []);
  }

  void clearIgnoredModFiles() {
    state = state.copyWith(ignoredModFiles: []);
  }

  void clearLogMessages() {
    state = state.copyWith(logMessages: []);
  }

  void clearLoggedStages() {
    state = state.copyWith(loggedStages: {});
  }

  void clearInput() {
    state = state.copyWith(input: '');
  }

  void clearSpecialDatOutputPath() {
    state = state.copyWith(specialDatOutputPath: '');
  }

  void clearIsLoading() {
    state = state.copyWith(isLoading: false);
  }

  void clearIsButtonEnabled() {
    state = state.copyWith(isButtonEnabled: false);
  }

  void clearIsLogIconBlinking() {
    state = state.copyWith(isLogIconBlinking: false);
  }

  void clearHasError() {
    state = state.copyWith(hasError: false);
  }

  void clearIsProcessing() {
    state = state.copyWith(isProcessing: false);
  }

  void clearSelectAllQuests() {
    state = state.copyWith(selectAllQuests: false);
  }

  void clearSelectAllMaps() {
    state = state.copyWith(selectAllMaps: false);
  }

  void clearSelectAllPhases() {
    state = state.copyWith(selectAllPhases: false);
  }

  void clearSavePaths() {
    state = state.copyWith(savePaths: false);
  }

  void clearIsHoveringSelectAll() {
    state = state.copyWith(isHoveringSelectAll: false);
  }

  void clearIsHoveringUnselectAll() {
    state = state.copyWith(isHoveringUnselectAll: false);
  }

  void clearIsHoveringUndo() {
    state = state.copyWith(isHoveringUndo: false);
  }

  void clearIsHoveringModify() {
    state = state.copyWith(isHoveringModify: false);
  }

  void clearIsExtractCopyEnabled() {
    state = state.copyWith(isExtractCopyEnabled: false);
  }

  void clearIsModManagerPageProcessing() {
    state = state.copyWith(isModManagerPageProcessing: false);
  }

  void clearIsBalanceMode() {
    state = state.copyWith(isBalanceMode: false);
  }

  void clearBalanceModeCheckBoxValue() {
    state = state.copyWith(balanceModeCheckBoxValue: false);
  }

  void clearHasDLC() {
    state = state.copyWith(hasDLC: false);
  }

  void clearDLCCheckBoxValue() {
    state = state.copyWith(dlcCheckBoxValue: false);
  }

  void clearLastLogProcessed() {
    state = state.copyWith(lastLogProcessed: null);
  }

  void clearCustomSelection() {
    state = state.copyWith(customSelection: false);
  }

  void clearEnemyLevel() {
    state = state.copyWith(enemyLevel: 0);
  }

  void clearSelectedIndex() {
    state = state.copyWith(selectedIndex: 0);
  }

  void clearEnemyStats() {
    state = state.copyWith(enemyStats: 0.0);
  }

  void clearCheckboxValueForPaths() {
    state = state.copyWith(checkboxValueForPaths: false);
  }

  void clearStats() {
    state = state.copyWith(stats: const {});
  }

  void clearCategories() {
    state = state.copyWith(categories: const {});
  }

  void clearLevel() {
    state = state.copyWith(levelMap: const {});
  }

  void clearPaths() {
    state = state.copyWith(
      input: '',
      specialDatOutputPath: '',
      savePaths: false,
    );
  }

  // Custom methods
  void toggleCustomSelection() {
    state = state.copyWith(customSelection: !state.customSelection);
  }

  void updateCategories() {
    final allItems = getAllItems();
    final newCategories = <String, bool>{};

    for (var item in allItems) {
      newCategories[item.id] = state.categories[item.id] ??
          (item.dlc == true ? state.hasDLC : false);
    }

    state = state.copyWith(categories: newCategories);
  }

  void updateDLCOption(bool value) {
    state = state.copyWith(hasDLC: value, dlcCheckBoxValue: value);
  }

  void updateEnemyStats(double newValue) {
    state = state.copyWith(enemyStats: newValue);
  }

  void updateSelectedImages(List<String> newSelectedImages) {
    state = state.copyWith(selectedImages: newSelectedImages);
  }

  void addSelectedImage(String imageName) {
    if (!state.selectedImages.contains(imageName)) {
      state = state.copyWith(
          selectedImages: List.from(state.selectedImages)..add(imageName));
    }
  }

  void selectAllImagesGrid() {
    state.enemyImageGridKey.currentState?.selectAllImages();
  }

  void unselectAllImagesGrid() {
    state.enemyImageGridKey.currentState?.unselectAllImages();
  }

  // i dont't like this
  GlobalKey<EnemyImageGridState> get enemyImageGridKey =>
      state.enemyImageGridKey;

  void removeSelectedImage(String imageName) {
    if (state.selectedImages.contains(imageName)) {
      state = state.copyWith(
          selectedImages: List.from(state.selectedImages)..remove(imageName));
    }
  }

  void selectAllImages(List<String> allImageNames) {
    state = state.copyWith(selectedImages: List.from(allImageNames));
  }

  void unselectAllImages() {
    state = state.copyWith(selectedImages: []);
  }

  void updateEnemyLevel(int newLevel) {
    state = state.copyWith(enemyLevel: newLevel);
  }

  void updateLevel(String levelKey, bool value) {
    if (value || state.levelMap.values.every((v) => !v)) {
      final newLevel = Map<String, bool>.from(state.levelMap)
        ..updateAll((key, value) => false)
        ..update(levelKey, (v) => value);
      state = state.copyWith(levelMap: newLevel);
    }
  }

  void updateSelectedCategories(Map<String, bool> newCategories) {
    state = state.copyWith(categories: newCategories);
  }

  void complete() {
    if (!state.completer.isCompleted) {
      state.completer.complete();
    }
  }

  void updateHoverState(String hoverItem, bool isHovering) {
    switch (hoverItem) {
      case 'selectAll':
        state = state.copyWith(isHoveringSelectAll: isHovering);
        break;
      case 'unselectAll':
        state = state.copyWith(isHoveringUnselectAll: isHovering);
        break;
      case 'undo':
        state = state.copyWith(isHoveringUndo: isHovering);
        break;
      case 'modify':
        state = state.copyWith(isHoveringModify: isHovering);
        break;
      default:
        return;
    }
  }

  void updateIgnoredModFiles(List<String> updatedModFiles) {
    state = state.copyWith(ignoredModFiles: updatedModFiles);
  }

  void updateInputPath(String newPath) {
    state = state.copyWith(input: newPath);
  }

  void updateOutputPath(String newPath) {
    state = state.copyWith(specialDatOutputPath: newPath);
  }

  void updateSavePaths(bool newSavePaths) {
    state = state.copyWith(savePaths: newSavePaths);
  }

  List<dynamic> getAllItems() {
    return [
      ...ScriptingPhase.scriptingPhases
          .where((item) => state.hasDLC || item.dlc != true),
      ...MapLocation.mapLocations
          .where((item) => state.hasDLC || item.dlc != true),
      ...SideQuest.sideQuests.where((item) => state.hasDLC || item.dlc != true),
    ];
  }

  void scrollToSetup() {
    final context = state.setupLogOutputKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 300));
    }
  }

  GlobalKey get setupLogOutputKey => state.setupLogOutputKey;
}

final loadPathsFromSharedPreferencesProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final globalState = ref.read(globalStateProvider.notifier);
  final prefs = await SharedPreferences.getInstance();

  String? input = prefs.getString('input');
  String? specialDatOutputPath = prefs.getString('output');
  bool savePaths = prefs.getBool('savePaths') ?? false;

  globalState.updateInputPath(input ?? '');
  globalState.updateOutputPath(specialDatOutputPath ?? '');
  globalState.updateSavePaths(savePaths);

  return input != null || specialDatOutputPath != null;
});
