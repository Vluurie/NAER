import 'package:NAER/naer_save_editor/exp/experience_widget.dart';
import 'package:NAER/naer_save_editor/money/money_widget.dart';
import 'package:NAER/naer_save_editor/name/name_widget.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SaveEditor extends ConsumerStatefulWidget {
  const SaveEditor({super.key});

  @override
  SaveEditorState createState() => SaveEditorState();
}

class SaveEditorState extends ConsumerState<SaveEditor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;
  final PageController _pageController = PageController();
  String directoryPath = "";
  List<File> slotDataFiles = [];
  File? selectedFile;

  @override
  void initState() {
    super.initState();
    _getDirectoryPath();
  }

  Future<void> _getDirectoryPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final nierAutomataPath = '${directory.path}\\My Games\\NieR_Automata';

      final dir = Directory(nierAutomataPath);

      if (await dir.exists()) {
        setState(() {
          directoryPath = nierAutomataPath;
        });

        final backupDir = Directory('$nierAutomataPath\\original_slotdata');

        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
          snackBar("Backup of original SlotData files created.");
        }

        // List SlotData_0 to SlotData_2 files and create backup
        for (int i = 0; i <= 2; i++) {
          final file = File('$nierAutomataPath\\SlotData_$i.dat');
          if (await file.exists()) {
            setState(() {
              slotDataFiles.add(file);
            });
            final backupFile = File('${backupDir.path}\\SlotData_$i.dat');
            if (!await backupFile.exists()) {
              await file.copy(backupFile.path);
              snackBar("Backup of original SlotData_$i.dat file created.");
            }
          }
        }
      } else {
        setState(() {
          directoryPath = "Directory does not exist";
        });
      }
    } catch (e) {
      setState(() {
        directoryPath = "Error accessing directory: $e";
      });
    }
  }

  void _onFileSelected(final File? file) async {
    if (file != null) {
      var fileSize = await file.length();
      if (fileSize == 235980) {
        setState(() {
          selectedFile = file;
          directoryPath = file.path;
        });
      } else {
        snackBar("File size is invalid.");
      }
    }
  }

  Future<void> _resetToOriginalSlotData() async {
    try {
      final backupDir = Directory('$directoryPath\\original_slotdata');
      if (await backupDir.exists()) {
        for (int i = 0; i <= 2; i++) {
          final backupFile = File('${backupDir.path}\\SlotData_$i.dat');
          if (await backupFile.exists()) {
            final originalFile = File('$directoryPath\\SlotData_$i.dat');
            if (await originalFile.exists()) {
              await originalFile.delete();
            }
            await backupFile.copy(originalFile.path);
          }
        }
        snackBar("SlotData files have been reset to their original state.");
      } else {
        snackBar("No backup directory found.");
      }
    } catch (e) {
      snackBar("Error resetting SlotData files: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var fileSize = await file.length();
      if (fileSize == 235980) {
        setState(() {
          selectedFile = file;
        });

        final nierAutomataPath = Directory(file.parent.path);
        final backupDir =
            Directory('${nierAutomataPath.path}\\original_slotdata');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        final backupFile =
            File('${backupDir.path}\\${file.path.split('\\').last}');
        if (await backupFile.exists()) {
          await backupFile.delete();
        }
        await file.copy(backupFile.path);
      } else {
        snackBar("File size is invalid.");
      }
    }
  }

  void snackBar(final String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AutomatoThemeColors.primaryColor(ref),
        title: directoryPath.isNotEmpty && selectedFile != null
            ? SaveFileName(filePath: selectedFile!.path)
            : Text(
                'SAVE FILE EDITOR',
                style: TextStyle(
                  fontSize: 48.0,
                  color: AutomatoThemeColors.darkBrown(ref),
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                        offset: const Offset(5.0, 5),
                        color: AutomatoThemeColors.hoverBrown(ref)
                            .withOpacity(0.5)),
                  ],
                ),
              ),
      ),
      body: Stack(
        children: [
          AutomatoBackground(
            ref: ref,
            showRepeatingBorders: false,
            gradientColor: AutomatoThemeColors.gradient(ref),
            linesConfig: LinesConfig(
                lineColor: AutomatoThemeColors.bright(ref),
                strokeWidth: 2.5,
                spacing: 5.0,
                flickerDuration: const Duration(milliseconds: 5000),
                enableFlicker: false,
                drawHorizontalLines: true,
                drawVerticalLines: true),
          ),
          selectedFile != null
              ? PageView(
                  controller: _pageController,
                  onPageChanged: (final index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ExperienceWidget(
                                      filePath: selectedFile!.path),
                                ),
                                Expanded(
                                  child:
                                      MoneyWidget(filePath: selectedFile!.path),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AutomatoThemeColors.darkBrown(ref),
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(5, 5),
                            blurRadius: 2,
                            color: AutomatoThemeColors.textDialogColor(ref)),
                      ],
                    ),
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Please select a SlotData to begin.",
                            style: TextStyle(
                              color: AutomatoThemeColors.textColor(ref),
                              fontSize: 20,
                            ),
                          ),
                        ),
                        if (slotDataFiles.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButton<File>(
                              dropdownColor: AutomatoThemeColors.darkBrown(ref),
                              hint: Text(
                                "Select SlotData file",
                                style: TextStyle(
                                  color: AutomatoThemeColors.textColor(ref),
                                ),
                              ),
                              items: slotDataFiles.map((final File file) {
                                return DropdownMenuItem<File>(
                                  value: file,
                                  child: Text(
                                    file.path.split('\\').last,
                                    style: TextStyle(
                                      color: AutomatoThemeColors.textColor(ref),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _onFileSelected,
                              value: selectedFile,
                              style: TextStyle(
                                color: AutomatoThemeColors.textColor(ref),
                              ),
                            ),
                          )
                        else
                          Text(
                            "No SlotData files found",
                            style: TextStyle(
                              color: AutomatoThemeColors.dangerZone(ref),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          "No SlotData found?",
                          style: TextStyle(
                            color: AutomatoThemeColors.textColor(ref),
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Search for it in: C:\\Users\\{name}\\Documents\\My Games\\NieR_Automata",
                            style: TextStyle(
                              color: AutomatoThemeColors.textColor(ref),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.search),
                          label: const Text("Browse Files"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AutomatoThemeColors.darkBrown(ref),
                            backgroundColor:
                                AutomatoThemeColors.primaryColor(ref),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _resetToOriginalSlotData,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Reset to Original SlotData"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AutomatoThemeColors.darkBrown(ref),
                            backgroundColor:
                                AutomatoThemeColors.primaryColor(ref),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
