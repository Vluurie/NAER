import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NAER/custom_naer_ui/mod__ui/mod_list.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/handle_mod_install.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class ModStateManager extends ChangeNotifier {
  Set<String> _installedModsIds = {};
  List<Mod> _mods = [];
  List<Mod> get mods => _mods;

  final ModInstallHandler modInstallHandler;
  bool _isDisposed = false;

  ModStateManager(this.modInstallHandler) {
    _loadInstalledMods();
    _startVerification();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool get isDisposed => _isDisposed;

  // Load installed mod IDs from SharedPreferences
  Future<void> _loadInstalledMods() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> modIds = prefs.getStringList('installedModsIds') ?? [];
    _installedModsIds = modIds.toSet();
    notifyListeners();
  }

  // Save installed mod IDs to SharedPreferences
  Future<void> _saveInstalledMods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('installedModsIds', _installedModsIds.toList());
  }

  void _startVerification() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _verifyInstalledMods();
    });
  }

  Future<void> _verifyInstalledMods() async {
    bool changed = false;
    for (String modId in _installedModsIds.toList()) {
      List<String> invalidFiles = await modInstallHandler.verifyModFiles(modId);
      if (invalidFiles.isNotEmpty) {
        _installedModsIds.remove(modId);
        changed = true;
        await modInstallHandler.removeModFiles(modId, invalidFiles);
      }
    }
    if (changed) {
      if (_isDisposed) return;
      await _saveInstalledMods();
      notifyListeners();
      NotificationManager.notify(
          "One or more mods have missing or altered files and corresponding adjustments have been made (ㆆ _ ㆆ).");
    }
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
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final metadataPath = p.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    if (await metadataFile.exists()) {
      final String metadataContent = await metadataFile.readAsString();
      final decoded = jsonDecode(metadataContent);

      List<dynamic> modsJson = decoded['mods'];
      _mods = modsJson.map((modJson) => Mod.fromJson(modJson)).toList();

      notifyListeners();
    }
  }
}

class NotificationEvent {
  final String message;
  NotificationEvent(this.message);
}

class NotificationManager {
  static final _notificationStreamController =
      StreamController<NotificationEvent>.broadcast();
  static Stream<NotificationEvent> get notificationStream =>
      _notificationStreamController.stream;

  static void notify(String message) {
    _notificationStreamController.add(NotificationEvent(message));
  }
}
