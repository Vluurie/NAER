import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NAER/custom_naer_ui/mod__ui/mod_list.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/handle_mod_install.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class ModStateManager extends ChangeNotifier {
  Set<String> _installedModsIds = {};
  List<Mod> _mods = [];
  List<Mod> get mods => _mods;
  List<String> affectedModsInfo = [];
  String affectedModName = "";
  List<String> currentModfiles = [];

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
        currentModfiles = await getModFilePaths(modId);
        _installedModsIds.remove(modId);
        changed = true;
      }
    }

    if (changed) {
      if (_isDisposed) return;
      await _saveInstalledMods();
      notifyListeners();
      await FileChange.removeIgnoreFiles(allFilePathsToUnignore);
      String notificationMessage = "Affected mods have been handled";
      NotificationManager.notify(notificationMessage);
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

  showStyledPopup(BuildContext context) {
    List<String> currentlyIgnored = FileChange.ignoredFiles;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 35, 34, 34),
          title: const Text(
            '🔧 Mod Update Heads-up!',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.white),
                children: <TextSpan>[
                  const TextSpan(
                      text:
                          "Hey there! NAER noticed a few mods might need your attention. Nothing too scary, but here’s the gist:\n\n",
                      style: TextStyle(color: Colors.lightBlueAccent)),
                  const TextSpan(
                      text:
                          "🚀 One mod might have gotten a bit too excited and replaced another mod's files.\n",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          "🧹 Maybe some files were accidentally swept away from the installation path.\n",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          "🚫 And there’s a chance that some files didn’t make it to the installation path due to our 'ignore files' setting:\nFiles that where in installation path: $currentlyIgnored \n\n",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: "Modfiles of the mod: $affectedModName: ",
                      style: const TextStyle(color: Colors.greenAccent)),
                  TextSpan(
                      text: " $currentModfiles.\n\n",
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const TextSpan(
                      text: "Affected mod files of the mod: ",
                      style: TextStyle(color: Colors.greenAccent)),
                  TextSpan(
                      text: "${affectedModsInfo.join('; ')}.\n\n",
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const TextSpan(
                      text:
                          "Could you take a peek at your randomization settings? Just to make sure everything’s shipshape. Oh, and if you spot ",
                      style: TextStyle(color: Colors.white)),
                  const TextSpan(
                      text: "“em” dat files",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.yellowAccent)),
                  const TextSpan(
                      text: " being affected, maybe give ",
                      style: TextStyle(color: Colors.white)),
                  const TextSpan(
                      text: "“Change boss stats” ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellowAccent)),
                  const TextSpan(
                      text:
                          "a try? If it's not selected, it does not install em files during randomization only.",
                      style: TextStyle(color: Colors.white)),
                  const TextSpan(
                      text:
                          "\n\nThe affected mod got uninstalled automatically for you 🧹. ",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!',
                  style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () {
                affectedModsInfo = [];
                affectedModName = "";
                currentModfiles = [];
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
