import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for form key and text controllers
final formKeyProvider =
    Provider<GlobalKey<FormState>>((final ref) => GlobalKey<FormState>());

final idControllerProvider =
    Provider<TextEditingController>((final ref) => TextEditingController());
final nameControllerProvider =
    Provider<TextEditingController>((final ref) => TextEditingController());
final versionControllerProvider =
    Provider<TextEditingController>((final ref) => TextEditingController());
final authorControllerProvider =
    Provider<TextEditingController>((final ref) => TextEditingController());
final descriptionControllerProvider =
    Provider<TextEditingController>((final ref) => TextEditingController());
final dlcControllerProvider = StateProvider<String?>((final ref) => 'false');

final enemySetActionControllersProvider =
    StateNotifierProvider<ControllerNotifier, List<TextEditingController>>(
        (final ref) {
  return ControllerNotifier();
});

final enemySetAreaControllersProvider =
    StateNotifierProvider<ControllerNotifier, List<TextEditingController>>(
        (final ref) {
  return ControllerNotifier();
});

final enemyGeneratorControllersProvider =
    StateNotifierProvider<ControllerNotifier, List<TextEditingController>>(
        (final ref) {
  return ControllerNotifier();
});

final enemyLayoutActionControllersProvider =
    StateNotifierProvider<ControllerNotifier, List<TextEditingController>>(
        (final ref) {
  return ControllerNotifier();
});

// Providers for state variables
final selectedDirectoryProvider = StateProvider<String?>((final ref) => null);
final showModFolderWarningProvider = StateProvider<bool>((final ref) => false);
final directoryContentsInfoProvider =
    StateProvider<List<String>>((final ref) => []);
final selectedImagePathProvider =
    StateNotifierProvider<SelectedImagePathNotifier, String?>(
        (final ref) => SelectedImagePathNotifier());

final validFolderNamesProvider = Provider<List<String>>((final ref) => [
      "ph4",
      "st5",
      "wd5",
      "quest",
      "ph2",
      "ph3",
      "st1",
      "st2",
      "st5",
      "core",
      "ph1",
      "st1",
      "em",
      "ba",
      "bg",
      "bh",
      "em",
      "et",
      "it",
      "pl",
      "ui",
      "um",
      "wp",
      "misctex",
      "effect",
      "dat",
      "dtt"
    ]);

class MetadataProvider {
  final GlobalKey<FormState> formKey;
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController versionController;
  final TextEditingController authorController;
  final TextEditingController descriptionController;
  final List<TextEditingController> enemySetActionControllers;
  final List<TextEditingController> enemySetAreaControllers;
  final List<TextEditingController> enemyGeneratorControllers;
  final List<TextEditingController> enemyLayoutActionControllers;
  final bool showModFolderWarning;
  final List<String> directoryContentsInfo;
  final String? selectedImagePath;
  final String? selectedDirectory;
  final String? dlcValue;

  MetadataProvider(final WidgetRef ref)
      : formKey = ref.read(formKeyProvider),
        idController = ref.read(idControllerProvider),
        nameController = ref.read(nameControllerProvider),
        versionController = ref.read(versionControllerProvider),
        authorController = ref.read(authorControllerProvider),
        descriptionController = ref.read(descriptionControllerProvider),
        enemySetActionControllers = ref.read(enemySetActionControllersProvider),
        enemySetAreaControllers = ref.read(enemySetAreaControllersProvider),
        enemyGeneratorControllers = ref.read(enemyGeneratorControllersProvider),
        enemyLayoutActionControllers =
            ref.read(enemyLayoutActionControllersProvider),
        showModFolderWarning = ref.watch(showModFolderWarningProvider),
        directoryContentsInfo = ref.watch(directoryContentsInfoProvider),
        selectedImagePath = ref.watch(selectedImagePathProvider),
        selectedDirectory = ref.watch(selectedDirectoryProvider),
        dlcValue = ref.watch(dlcControllerProvider);
}

class SelectedImagePathNotifier extends StateNotifier<String?> {
  SelectedImagePathNotifier() : super(null);

  void setImagePath(final String? path) {
    state = path;
  }
}

class ControllerNotifier extends StateNotifier<List<TextEditingController>> {
  ControllerNotifier() : super([TextEditingController()]);

  void addController() {
    state = [...state, TextEditingController()];
  }

  void removeController(final int index) {
    if (state.length > 1) {
      state.removeAt(index);
      state = [...state];
    }
  }
}

final controllerProvider =
    StateNotifierProvider<ControllerNotifier, List<TextEditingController>>(
        (final ref) {
  return ControllerNotifier();
});
