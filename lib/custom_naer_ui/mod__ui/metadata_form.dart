// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
import 'package:file_picker/file_picker.dart';
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
  String? _selectedDirectory;
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(18),
                  child: Title(
                      color: const Color.fromARGB(255, 0, 0, 255),
                      child: const Text(
                        "Add custom mods to the mod list.",
                        style: TextStyle(fontSize: 24),
                      ))),
              _buildTextFormField(
                controller: _idController,
                label: 'ID',
                validator: _validateId,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: _nameController,
                label: 'Name',
                validator: (value) => _validateText(value, fieldName: 'Name'),
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: _versionController,
                label: 'Version',
                validator: _validateVersion,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: _authorController,
                label: 'Author',
                validator: (value) => _validateText(value, fieldName: 'Author'),
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                validator: (value) =>
                    _validateText(value, fieldName: 'Description'),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImagePath!),
                          width: 100, // Thumbnail size
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[800],
                          size: 50,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .primaryColor, // Use the primary theme color
                    ),
                    child: Text(_selectedImagePath == null
                        ? 'Select Image'
                        : 'Change Image'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                  alignment: Alignment.center,
                  child: ButtonTheme(
                      minWidth: 100,
                      child: ElevatedButton(
                        onPressed: _addFileField,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text(
                          'Add Modfolder',
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ))),
              _buildDirectoryStructure(),
              const SizedBox(height: 10),
              Align(
                  alignment: Alignment.center,
                  child: ButtonTheme(
                    minWidth: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        if ((_formKey.currentState?.validate() ?? false) &&
                            (_directoryContentsInfo.isNotEmpty)) {
                          _saveMetadata();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please add a mod folder before saving.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 12, 109, 15),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text('Save Metadata'),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryStructure() {
    if (_selectedDirectory == null) {
      return Container();
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

      final newMod = {
        "id": modId,
        "name": _nameController.text.trim(),
        "imagePath": _selectedImagePath,
        "version": _versionController.text.trim(),
        "author": _authorController.text.trim(),
        "description": _descriptionController.text.trim(),
        "files": filesMetadata,
      };

      print(newMod);
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

  String? _validateId(String? value) {
    final RegExp idRegExp = RegExp(r'^[a-z0-9_]+$');
    if (value == null || value.isEmpty || !idRegExp.hasMatch(value)) {
      return 'Please enter a valid ID (lowercase, numbers, underscore only)';
    }
    return null;
  }

  String? _validateText(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    final RegExp textRegExp = RegExp(r'^[^{}\[\]]+$');
    if (!textRegExp.hasMatch(value)) {
      return 'Invalid characters in $fieldName';
    }
    return null;
  }

  String? _validateVersion(String? value) {
    final RegExp versionRegExp = RegExp(r'^\d+\.\d+\.\d+$');
    if (value == null || value.isEmpty || !versionRegExp.hasMatch(value)) {
      return 'Please enter a valid version (e.g., 1.0.0)';
    }
    return null;
  }
}
