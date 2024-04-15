import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_mod_manager/utils/mod_state_managment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:NAER/naer_utils/extension_string.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class MetadataForm extends StatefulWidget {
  const MetadataForm(
      {super.key, required this.cliArguments, required this.modStateManager});
  final CLIArguments cliArguments;
  final ModStateManager modStateManager;

  @override
  _MetadataFormState createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _enemySetActionControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _enemySetAreaControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _enemyGeneratorControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _enemyLayoutActionControllers = [
    TextEditingController()
  ];
  String? _selectedDirectory;
  bool _showModFolderWarning = false;
  List<String> _directoryContentsInfo = [];
  String? _selectedImagePath;
  List<String> validFolderNames = [
    "ph4",
    "st5",
    "quest",
    "ph2",
    "ph3",
    "quest",
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
    "wp"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Metadata Form"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "Add custom mods to the mod list.",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: _buildTextFormField(
                        controller: _idController,
                        label: 'ID',
                        validator: (value) => value?.validateId(value))),
                const SizedBox(height: 10),
                Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: _buildTextFormField(
                        controller: _nameController,
                        label: 'Name',
                        validator: (value) => value?.validateText(
                              value,
                              fieldName: 'Name',
                            ))),
                const SizedBox(height: 10),
                Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: _buildTextFormField(
                        controller: _versionController,
                        label: 'Version',
                        validator: (value) => value?.validateVersion(value))),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: _buildTextFormField(
                    controller: _authorController,
                    label: 'Author',
                    validator: (value) =>
                        value?.validateText(value, fieldName: 'Author'),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: _buildTextFormField(
                    controller: _descriptionController,
                    label: 'Description',
                    validator: (value) =>
                        value?.validateText(value, fieldName: 'Description'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            textScaler: TextScaler.linear(1.5),
                            "Extra: Advanced for ignoring enemies from modifying in this entities: (example: 0x864ec3e4)"),
                      ),
                      _buildIdList(
                          "Enemy Set Action ID", _enemySetActionControllers,
                          () {
                        setState(() {
                          _enemySetActionControllers
                              .add(TextEditingController());
                        });
                      }),
                      _buildIdList(
                          "Enemy Set Area ID", _enemySetAreaControllers, () {
                        setState(() {
                          _enemySetAreaControllers.add(TextEditingController());
                        });
                      }),
                      _buildIdList(
                          "Enemy Generator ID", _enemyGeneratorControllers, () {
                        setState(() {
                          _enemyGeneratorControllers
                              .add(TextEditingController());
                        });
                      }),
                      _buildIdList("Enemy Layout Action ID",
                          _enemyLayoutActionControllers, () {
                        setState(() {
                          _enemyLayoutActionControllers
                              .add(TextEditingController());
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedImagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImagePath!),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 48, 46, 46),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text(_selectedImagePath == null
                              ? 'Select Image/GIF'
                              : 'Change Image/GIF'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: ButtonTheme(
                            minWidth: 300,
                            child: ElevatedButton(
                              onPressed: _addFileField,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 52, 54, 54),
                                padding: const EdgeInsets.all(20),
                              ),
                              child: const Text(
                                'Add Modfolder',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ))),
                  ],
                ),
                _buildDirectoryStructure(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            bool formIsValid =
                                _formKey.currentState?.validate() ?? false;
                            bool directoryHasContents =
                                _directoryContentsInfo.isNotEmpty;

                            if (formIsValid && directoryHasContents) {
                              _saveMetadata();
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                _showModFolderWarning = !directoryHasContents;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 12, 109, 15),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: const Text('Save Metadata'),
                        ),
                      ),
                    ),
                    if (_showModFolderWarning)
                      Visibility(
                        visible: _showModFolderWarning,
                        child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 41, 39, 39),
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 24.0,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Please add a mod folder or check your input again before saving.",
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdInputField(
      String label,
      List<TextEditingController> controllers,
      int index,
      VoidCallback onRemoved) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controllers[index],
              decoration: InputDecoration(
                labelText: "$label ${index + 1}",
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else {
                  return value.validateHexValue();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemoved,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _buildIdList(String label, List<TextEditingController> controllers,
      VoidCallback onAdded) {
    return Column(
      children: [
        ...List.generate(
            controllers.length,
            (i) => _buildIdInputField(label, controllers, i, () {
                  if (controllers.length > 1) {
                    setState(() => controllers.removeAt(i));
                  }
                })),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdded,
              tooltip: 'Add more',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectoryStructure() {
    if (_selectedDirectory == null) {
      return Container();
    }

    if (_directoryContentsInfo.isEmpty) {
      setState(() {
        _showModFolderWarning = true;
      });
    } else {
      setState(() {
        _showModFolderWarning = false;
      });
    }

    if (_directoryContentsInfo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          'No mod files found',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text('Selected Directory: $_selectedDirectory'),
        ),
        SizedBox(
          width: 1000,
          child: LimitedBox(
            maxHeight: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _directoryContentsInfo.length,
              itemBuilder: (context, index) {
                String filePath = _directoryContentsInfo[index];
                String displayPath = filePath
                    .replaceAll(_selectedDirectory!, '')
                    .replaceAll(p.separator, '/');
                return ListTile(
                  title: Text(displayPath),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      validator: validator,
    );
  }

  void _addFileField() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _loadDirectoryContents(selectedDirectory);
    } else {
      // User canceled the picker
    }
  }

  void _saveMetadata() async {
    if (_formKey.currentState!.validate() && _selectedDirectory != null) {
      final modId = _idController.text.trim();
      final List<Map<String, String>> filesMetadata =
          _directoryContentsInfo.map((filePath) {
        String relativePath = p.relative(filePath, from: _selectedDirectory!);
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
          processIds(_enemySetActionControllers);
      final List<String> enemySetAreaIds = processIds(_enemySetAreaControllers);
      final List<String> enemyGeneratorIds =
          processIds(_enemyGeneratorControllers);
      final List<String> enemyLayoutActionIds =
          processIds(_enemyLayoutActionControllers);

      final Map<String, List<String>> idsData = {
        if (enemySetActionIds.isNotEmpty) "EnemySetAction": enemySetActionIds,
        if (enemySetAreaIds.isNotEmpty) "EnemySetArea": enemySetAreaIds,
        if (enemyGeneratorIds.isNotEmpty) "EnemyGenerator": enemyGeneratorIds,
        if (enemyLayoutActionIds.isNotEmpty)
          "EnemyLayoutAction": enemyLayoutActionIds,
      };

      final newMod = {
        "id": modId,
        "name": _nameController.text.trim(),
        "imagePath": _selectedImagePath,
        "version": _versionController.text.trim(),
        "author": _authorController.text.trim(),
        "description": _descriptionController.text.trim(),
        "files": filesMetadata,
        "importantIDs": idsData,
      };

      await _updateMetadata(newMod, widget.modStateManager);
    }
  }

  void _loadDirectoryContents(String selectedDirectory) async {
    setState(() {
      _selectedDirectory = selectedDirectory;
    });

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

    setState(() {
      _directoryContentsInfo = filePaths;
    });
  }

  Future<void> _updateMetadata(
      Map<String, dynamic> newMod, ModStateManager modStateManager) async {
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

    await copyFilesToModPackage(newMod['id'], newMod['files']);
    await modStateManager.fetchAndUpdateModsList();
  }

  Future<void> copyFilesToModPackage(
      String modId, List<Map<String, String>> files) async {
    final modDirectoryPath =
        "${await FileChange.ensureSettingsDirectory()}/ModPackage/$modId";
    final modDirectory = Directory(modDirectoryPath);

    if (!await modDirectory.exists()) {
      await modDirectory.create(recursive: true);
    } else {}

    for (var fileMap in files) {
      final filePath = fileMap['path'];

      final String adjustedFilePath = filePath!.startsWith("$modId/")
          ? filePath.substring("$modId/".length)
          : filePath;
      final String fullPath = p.join(_selectedDirectory!, adjustedFilePath);
      final File sourceFile = File(fullPath);
      final String targetPath = p.join(modDirectoryPath, adjustedFilePath);

      final targetDirectory = Directory(p.dirname(targetPath));
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      if (await sourceFile.exists()) {
        await sourceFile.copy(targetPath);
      } else {}
    }
  }

  void _pickImage() async {
    final pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.files.single.path;
      });
    }
  }
}
