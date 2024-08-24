import 'dart:async';
import 'package:NAER/naer_mod_manager/ui/mod_list.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:path/path.dart' as p;
import 'mod_service.dart';
import 'notification_manager.dart';

class ModStateManager extends ChangeNotifier {
  Set<String> _installedModsIds = {};
  List<Mod> _mods = [];
  List<Mod> get mods => _mods;
  List<String> affectedModsInfo = [];
  String affectedModName = "";
  List<String> currentModfiles = [];
  Timer? verificationTimer;
  bool _isVerifying = false;
  bool _isVerificationInProgress = false;

  bool get isVerifying => _isVerifying;

  final ModService modService;
  final ModInstallHandler modInstallHandler;
  bool _isDisposed = false;

  ModStateManager(this.modService, this.modInstallHandler) {
    _loadInstalledMods();
  }

  @override
  void dispose() {
    _isDisposed = true;
    verificationTimer?.cancel();
    super.dispose();
  }

  bool get isDisposed => _isDisposed;

  void clearAffectedModsInfo() {
    affectedModsInfo = [];
    affectedModName = "";
    currentModfiles = [];
    notifyListeners();
  }

  Future<void> _loadInstalledMods() async {
    _installedModsIds = await modService.loadInstalledMods();
    notifyListeners();
  }

  Future<void> _saveInstalledMods() async {
    await modService.saveInstalledMods(_installedModsIds.toList());
  }

  void toggleVerification() {
    if (_isVerifying) {
      _stopVerification();
    } else {
      _startVerification();
    }
    notifyListeners();
    globalLog(isVerifying
        ? "Mod verification started"
        : "Mod verification stopped, finishing any running verification....");
  }

  void _startVerification() {
    _isVerifying = true;
    notifyListeners();
    globalLog(
        "Verifying mods in process... A check will occur every 3 seconds.");

    // Schedule periodic checks every 3 seconds
    verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!_isVerificationInProgress) {
        _isVerificationInProgress = true;
        await _verifyInstalledMods();
        _isVerificationInProgress = false;
      }
    });
  }

  void _stopVerification() {
    verificationTimer?.cancel();
    _isVerifying = false;
    notifyListeners();
    globalLog("Verification process stopped.");
  }

  Future<void> _verifyInstalledMods() async {
    bool changed = false;
    List<String> allFilePathsToUnignore = [];

    for (String modId in _installedModsIds.toList()) {
      List<String> affectedFiles =
          await modInstallHandler.verifyModFiles(modId);
      if (affectedFiles.isNotEmpty) {
        String modName = mods
            .firstWhere((mod) => mod.id == modId,
                orElse: () => Mod(
                    id: modId,
                    name: 'Unknown Mod',
                    version: '1.0.0',
                    author: 'Unknown',
                    description: '',
                    files: []))
            .name;

        allFilePathsToUnignore
            .addAll(affectedFiles.map((file) => p.basename(file)).toList());
        affectedModsInfo.add("$modName: (${affectedFiles.join(', ')})");
        affectedModName = modName;

        await modInstallHandler.removeModFiles(modId, allFilePathsToUnignore);

        Mod currentMod = mods.firstWhere((mod) => mod.id == modId,
            orElse: () => Mod(
                id: modId,
                name: 'Unknown Mod',
                version: '1.0.0',
                author: 'Unknown',
                description: '',
                files: []));
        List<String> filenamesToRemove = currentMod.files
            .map((fileMap) => fileMap['path'] ?? '')
            .where((path) => path.isNotEmpty)
            .map((path) => p.basename(path))
            .toList();
        await FileChange.removeIgnoreFiles(filenamesToRemove);

        _installedModsIds.remove(modId);
        changed = true;

        globalLog(
            "Changes found in mod: $modName. Affected files: ${affectedFiles.join(', ')}");
      }
    }

    if (changed) {
      globalLog(
          "Re-checked mods, changes detected. Updating installed mods list...");
      if (_isDisposed) {
        return;
      }
      await _saveInstalledMods();
      notifyListeners();
      String notificationMessage = "Affected mods have been handled";
      globalLog("$notificationMessage: ${affectedModsInfo.join('; ')}");
      NotificationManager.notify(notificationMessage);
    } else {
      LogState().clearLogs();
      globalLog("Re-checked mods, no issues found.");
    }
  }

  Future<List<String>> getModFilePaths(String modId) async {
    Mod targetMod = mods.firstWhere(
      (mod) => mod.id == modId,
      orElse: () => Mod(
        id: 'default',
        name: 'Unknown Mod',
        version: '0',
        author: 'Unknown',
        description: 'No description available',
        files: [],
      ),
    );

    return targetMod.files.isNotEmpty
        ? targetMod.files.map((fileMap) => fileMap['path'] ?? '').toList()
        : [];
  }

  // Method to install a mod
  void installMod(String modId) async {
    _installedModsIds.add(modId);
    await _saveInstalledMods();
    notifyListeners();
  }

  // Method to uninstall a mod
  void uninstallMod(String modId) async {
    _installedModsIds.remove(modId);
    await _saveInstalledMods();
    notifyListeners();
  }

  bool isModInstalled(String modId) {
    return _installedModsIds.contains(modId);
  }

  Future<void> fetchAndUpdateModsList() async {
    _mods = await modService.fetchMods();
    notifyListeners();
  }
}
