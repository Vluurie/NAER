import 'package:NAER/naer_ui/directory_ui/check_pathbox.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class PathCheckBoxWidget extends StatefulWidget {
  final Future<bool> loadPathsFuture;
  final GlobalState globalState;

  const PathCheckBoxWidget({
    super.key,
    required this.loadPathsFuture,
    required this.globalState,
  });

  @override
  State<PathCheckBoxWidget> createState() => _PathCheckBoxWidgetState();
}

class _PathCheckBoxWidgetState extends State<PathCheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: widget.loadPathsFuture,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Consumer<GlobalState>(
            builder: (context, globalState, child) {
              return SavePathsWidget(
                input: globalState.input,
                output: globalState.specialDatOutputPath,
                scriptPath: globalState.scriptPath,
                savePaths: globalState.savePaths,
                onCheckboxChanged: (bool value) async {
                  if (!value) {
                    await clearPathsFromSharedPreferences();
                    globalState.clearPaths();
                  }
                  globalState.savePaths = value;
                },
              );
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> clearPathsFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('input');
    await prefs.remove('output');
    await prefs.remove('scriptPath');
    await prefs.setBool('savePaths', false);
  }
}
