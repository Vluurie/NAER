import 'dart:convert';
import 'dart:io';

import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class MetadataUtils {
  static Future<void> saveMetadata(
      WidgetRef ref, ModStateManager modStateManager, String? dlcValue) async {
    final selectedDirectory = ref.watch(selectedDirectoryProvider);
    final formKey = ref.read(formKeyProvider);
    final idController = ref.read(idControllerProvider);
    final nameController = ref.read(nameControllerProvider);
    final versionController = ref.read(versionControllerProvider);
    final authorController = ref.read(authorControllerProvider);
    final descriptionController = ref.read(descriptionControllerProvider);

    final enemySetActionControllers =
        ref.read(enemySetActionControllersProvider);
    final enemySetAreaControllers = ref.read(enemySetAreaControllersProvider);
    final enemyGeneratorControllers =
        ref.read(enemyGeneratorControllersProvider);
    final enemyLayoutActionControllers =
        ref.read(enemyLayoutActionControllersProvider);
    final directoryContentsInfo = ref.watch(directoryContentsInfoProvider);
    final selectedImagePath = ref.watch(selectedImagePathProvider);

    if (formKey.currentState!.validate() && selectedDirectory != null) {
      final modId = idController.text.trim();
      final List<Map<String, String>> filesMetadata =
          directoryContentsInfo.map((filePath) {
        String relativePath = p.relative(filePath, from: selectedDirectory);
        String modFilePath = "$modId/${relativePath.replaceAll('\\', '/')}";
        return {"path": modFilePath};
      }).toList();

      List<String> processIds(List<TextEditingController> controllers) {
        return controllers
            .map((controller) => controller.text)
            .expand((idString) => idString.split(','))
            .where((id) => id.isNotEmpty)
            .map((id) => id.trim())
            .toList();
      }

      final List<String> enemySetActionIds =
          processIds(enemySetActionControllers);
      final List<String> enemySetAreaIds = processIds(enemySetAreaControllers);
      final List<String> enemyGeneratorIds =
          processIds(enemyGeneratorControllers);
      final List<String> enemyLayoutActionIds =
          processIds(enemyLayoutActionControllers);

      final Map<String, List<String>> idsData = {
        if (enemySetActionIds.isNotEmpty) "EnemySetAction": enemySetActionIds,
        if (enemySetAreaIds.isNotEmpty) "EnemySetArea": enemySetAreaIds,
        if (enemyGeneratorIds.isNotEmpty) "EnemyGenerator": enemyGeneratorIds,
        if (enemyLayoutActionIds.isNotEmpty)
          "EnemyLayoutAction": enemyLayoutActionIds,
      };

      final newMod = {
        "id": modId,
        "name": nameController.text.trim(),
        "imagePath": selectedImagePath,
        "version": versionController.text.trim(),
        "author": authorController.text.trim(),
        "description": descriptionController.text.trim(),
        "dlc": dlcValue,
        "files": filesMetadata,
        "importantIDs": idsData,
      };

      await updateMetadata(newMod, modStateManager, ref);
    }
  }

  static Future<void> updateMetadata(Map<String, dynamic> newMod,
      ModStateManager modStateManager, WidgetRef ref) async {
    final directoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage";
    final metadataPath = p.join(directoryPath, 'mod_metadata.json');
    final File metadataFile = File(metadataPath);

    List<dynamic> modsData = [];
    if (await metadataFile.exists()) {
      final String metadataContent = await metadataFile.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(metadataContent);
      modsData = decoded['mods'] ?? [];
    }

    modsData.add(newMod);

    final String updatedContent =
        const JsonEncoder.withIndent('  ').convert({"mods": modsData});
    await metadataFile.writeAsString(updatedContent);

    await copyFilesToModPackage(ref, newMod['id'], newMod['files']);
    await modStateManager.fetchAndUpdateModsList();
  }

  static Future<void> copyFilesToModPackage(
      WidgetRef ref, String modId, List<Map<String, String>> files) async {
    final modDirectoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage/$modId";
    final modDirectory = Directory(modDirectoryPath);
    final selectedDirectory = ref.watch(selectedDirectoryProvider);

    if (!await modDirectory.exists()) {
      await modDirectory.create(recursive: true);
    }

    for (var fileMap in files) {
      final filePath = fileMap['path'];

      final String adjustedFilePath = filePath!.startsWith("$modId/")
          ? filePath.substring("$modId/".length)
          : filePath;
      final String fullPath = p.join(selectedDirectory!, adjustedFilePath);
      final File sourceFile = File(fullPath);
      final String targetPath = p.join(modDirectoryPath, adjustedFilePath);

      final targetDirectory = Directory(p.dirname(targetPath));
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
      }
    }
  }

  static void addFileField(WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      loadDirectoryContents(ref, selectedDirectory);
    } else {
      // User canceled the picker
    }
  }

  static void loadDirectoryContents(
      WidgetRef ref, String selectedDirectory) async {
    final validFolderNames = ref.read(validFolderNamesProvider);
    ref.read(selectedDirectoryProvider.notifier).state = selectedDirectory;

    final dir = Directory(selectedDirectory);
    List<String> filePaths = [];

    await for (FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        String filePath = entity.path;
        List<String> pathComponents =
            p.split(entity.path).map((e) => e.toLowerCase()).toList();

        bool isInValidFolder = pathComponents
            .any((component) => validFolderNames.contains(component));
        bool isInExcludedDir =
            pathComponents.contains('nier2blender_extracted'.toLowerCase());

        if (isInValidFolder && !isInExcludedDir) {
          filePaths.add(filePath);
        }
      }
    }

    ref.watch(directoryContentsInfoProvider.notifier).state = filePaths;
  }
}
