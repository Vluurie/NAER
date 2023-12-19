import 'package:NAER/utils/modFileUtils.dart';
import 'package:flutter/material.dart';

class ModFileHandler extends StatefulWidget {
  final String outputDirectory;

  ModFileHandler({Key? key, required this.outputDirectory}) : super(key: key);

  @override
  _ModFileHandlerState createState() => _ModFileHandlerState();
}

class _ModFileHandlerState extends State<ModFileHandler> {
  late List<String> modFiles;

  @override
  void initState() {
    super.initState();
    _initModFiles();
  }

  Future<void> _initModFiles() async {
    modFiles = await ModFileUtils.findModFiles(widget.outputDirectory);
    if (modFiles.isNotEmpty) {
      await ModFileUtils.showModsMessage(context, modFiles, (updatedModFiles) {
        setState(() {
          modFiles = updatedModFiles;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build method implementation, possibly listing the mod files
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod File Handler'),
      ),
      body: Center(
        child: modFiles.isEmpty
            ? const Text('No mod files detected.')
            : ListView.builder(
                itemCount: modFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(modFiles[index]),
                    subtitle: const Text('Detected mod file'),
                  );
                },
              ),
      ),
    );
  }
}
