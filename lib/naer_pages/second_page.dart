// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:NAER/custom_naer_ui/mod__ui/log_output_widget.dart';
import 'package:NAER/main.dart';
import 'package:NAER/naer_services/randomize_utils/shared_logs.dart';
import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/handle_mod_install.dart';
import 'package:flutter/material.dart';
import 'package:NAER/custom_naer_ui/mod__ui/metadata_form.dart';
import 'package:NAER/naer_utils/mod_state_managment.dart';
import 'package:provider/provider.dart';
import 'package:NAER/custom_naer_ui/drag_n_drop.dart';
import 'package:NAER/custom_naer_ui/mod__ui/mod_loader_widget.dart';
import 'package:NAER/naer_utils/cli_arguments.dart';
import 'package:url_launcher/url_launcher.dart';

class SecondPage extends StatefulWidget {
  final CLIArguments cliArguments;

  const SecondPage({super.key, required this.cliArguments});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double modLoaderWidgetOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        modLoaderWidgetOpacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMetadataFormPopup() {
    final modStateManager =
        Provider.of<ModStateManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: MetadataForm(
            cliArguments: widget.cliArguments,
            modStateManager: modStateManager,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final modStateManager =
        Provider.of<ModStateManager>(context, listen: false);
    final outputPath = widget.cliArguments.specialDatOutputPath;
    final inputPath = widget.cliArguments.input;

    final actionButtons = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 50),
        child: TextButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Refresh all settings."),
          onPressed: () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Are you sure?'),
                  content: const Text(
                      'This will reset the app and clear all data of the local app settings. Do you want to proceed?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              final ModInstallHandler modInstallHandler = ModInstallHandler(
                cliArguments: widget.cliArguments,
                modStateManager: modStateManager,
              );
              await modInstallHandler.deleteAllSharedPreferences();
              final logState = Provider.of<LogState>(context, listen: false);
              logState.clearLogs();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => EnemyRandomizerApp()),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 50),
        child: TextButton.icon(
          icon: const Icon(Icons.clear_all),
          label: const Text("Clear Logs"),
          onPressed: () async {
            setState(() {
              final logState = Provider.of<LogState>(context, listen: false);
              logState.clearLogs();
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 0, 0),
          ),
        ),
      ),
      TextButton.icon(
        icon: const Icon(Icons.input),
        label: const Text("Open Input Path"),
        onPressed: () async {
          await openPaths(inputPath);
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 217, 255),
        ),
      ),
      TextButton.icon(
        icon: const Icon(Icons.output),
        label: const Text("Open Output Path"),
        onPressed: () async {
          await openPaths(outputPath);
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 217, 255),
        ),
      ),
      TextButton.icon(
        icon: const Icon(Icons.settings),
        label: const Text("Settings"),
        onPressed: () async {
          await openSettings();
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 217, 255),
        ),
      ),
      TextButton.icon(
        icon: const Icon(Icons.discord),
        label: const Text("Help"),
        onPressed: () async {
          final Uri url = Uri.parse('https://discord.gg/RTax46x94J');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 0, 217, 255),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Features'),
        backgroundColor: const Color.fromARGB(255, 49, 50, 51),
        elevation: 0,
        leading:
            canPop ? null : (actionButtons.isNotEmpty ? Container() : null),
        actions: canPop ? actionButtons : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ModLoaderWidget(
                  cliArguments: widget.cliArguments,
                  modStateManager: modStateManager,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DragDropWidget(cliArguments: widget.cliArguments),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LogoutOutWidget(cliArguments: widget.cliArguments),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMetadataFormPopup,
        tooltip: 'Add Metadata',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> openPaths(String path) async {
    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Path is empty')),
      );
      return;
    }
    if (Platform.isWindows) {
      await Process.run('explorer', [path]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Opening paths is not supported on this platform.')),
      );
    }
  }

  Future<void> openSettings() async {
    String settingsDirectoryPath = await FileChange.ensureSettingsDirectory();

    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', settingsDirectoryPath]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Opening settings path is not supported on this platform.'),
        ),
      );
    }
  }
}
