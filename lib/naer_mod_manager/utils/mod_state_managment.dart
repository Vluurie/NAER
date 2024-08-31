import 'dart:async';
import 'package:NAER/naer_database/handle_db_ignored_files.dart';
import 'package:NAER/naer_mod_manager/ui/mod_list.dart';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_mod_manager/utils/handle_mod_install.dart';
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
        Timer.periodic(const Duration(seconds: 3), (final timer) async {
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
            .firstWhere((final mod) => mod.id == modId,
                orElse: () => Mod(
                    id: modId,
                    name: 'Unknown Mod',
                    version: '1.0.0',
                    author: 'Unknown',
                    description: '',
                    files: []))
            .name;

        allFilePathsToUnignore.addAll(
            affectedFiles.map((final file) => p.basename(file)).toList());
        affectedModsInfo.add("$modName: (${affectedFiles.join(', ')})");
        affectedModName = modName;

        await modInstallHandler.removeModFiles(modId, allFilePathsToUnignore);

        Mod currentMod = mods.firstWhere((final mod) => mod.id == modId,
            orElse: () => Mod(
                id: modId,
                name: 'Unknown Mod',
                version: '1.0.0',
                author: 'Unknown',
                description: '',
                files: []));
        List<String> filenamesToRemove = currentMod.files
            .map((final fileMap) => fileMap['path'] ?? '')
            .where((final path) => path.isNotEmpty)
            .map((final path) => p.basename(path))
            .toList();
        await DatabaseIgnoredFilesHandler.queryAndRemoveIgnoredFiles(
            filenamesToRemove);

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
      await LogState().clearLogs();
      globalLog("Re-checked mods, no issues found.");
    }
  }

  Future<List<String>> getModFilePaths(final String modId) async {
    Mod targetMod = mods.firstWhere(
      (final mod) => mod.id == modId,
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
        ? targetMod.files.map((final fileMap) => fileMap['path'] ?? '').toList()
        : [];
  }

  void installMod(final String modId) async {
    _installedModsIds.add(modId);
    await _saveInstalledMods();
    notifyListeners();
  }

  void uninstallMod(final String modId) async {
    _installedModsIds.remove(modId);
    await _saveInstalledMods();
    notifyListeners();
  }

  bool isModInstalled(final String modId) {
    return _installedModsIds.contains(modId);
  }

  Future<void> fetchAndUpdateModsList() async {
    _mods = await modService.fetchMods();
    notifyListeners();
  }
}
