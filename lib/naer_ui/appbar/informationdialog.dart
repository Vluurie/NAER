import 'package:NAER/naer_utils/change_tracker.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

void showInformationDialog(BuildContext context, WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "Important Information",
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thank you for choosing this tool! This application is offered as a free service, developed with care and dedication over the past year to support the NieR community.",
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "If you encounter any issues, have questions, or just want to connect with other enthusiasts, the NieR Modding community is here to help. Your feedback and contributions are always appreciated!",
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AutomatoThemeColors.primaryColor(ref),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _launchURL(dotenv.env['DISCORD_INVITE_LINK']!),
              icon: Icon(Icons.discord,
                  color: AutomatoThemeColors.textDialogColor(ref)),
              label: Text(
                'Join the Modding Discord',
                style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "This tool was built using Dart and Flutter, where Dart powers not only the user interface but also handles modifications and other tasks through parallel computing using isolates. Rust was used for the extraction process, increasing the speed to extract by alot.",
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flutter_dash,
                    color: AutomatoThemeColors.darkBrown(ref),
                    size: 24), // Flutter icon
                const SizedBox(width: 8),
                Text(
                  "Built with Dart, Flutter, and Rust",
                  style: TextStyle(
                    color: AutomatoThemeColors.textDialogColor(ref),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "A special shoutout goes to RaiderB for his incredible work on both NieR CLI and the Scripting Tool (F-Servo), which were essential for creating and debugging the modifications. He also helped on the code for repacking/extracting at the very beginning. Alsothe contributions from the entire modding community have made this tool possible.",
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AutomatoThemeColors.textDialogColor(ref)),
          const SizedBox(height: 8),
          Text(
            "Explore More:",
            style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLinkButton(
                ref,
                label: 'NAER - GitHub',
                url: dotenv.env['NAER_GITHUB_URL']!,
                icon: Icons.code, // GitHub icon for NAER
              ),
              _buildLinkButton(
                ref,
                label: 'NieR CLI - RaiderB',
                url: dotenv.env['NIER_CLI_URL']!,
                icon: Icons.code, // GitHub icon for RaiderB's CLI
              ),
              _buildLinkButton(
                ref,
                label: 'Automato Theme - GitHub',
                url: dotenv.env['AUTOMATO_THEME_URL']!,
                icon: Icons.code, // GitHub icon for Automato Theme
              ),
            ],
          ),
        ],
      ),
    ),
    onOkPressed: () => Navigator.of(context).pop(),
    okLabel: 'Close',
  );
}

Widget _buildLinkButton(WidgetRef ref,
    {required String label, required String url, required IconData icon}) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: AutomatoThemeColors.darkBrown(ref),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    onPressed: () => _launchURL(url),
    icon: Icon(icon, color: AutomatoThemeColors.primaryColor(ref)),
    label: Text(
      label,
      style: TextStyle(
        color: AutomatoThemeColors.primaryColor(ref),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Future<void> _launchURL(String urlStr) async {
  final Uri url = Uri.parse(urlStr);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.inAppWebView);
  } else {
    throw 'Could not launch $url';
  }
}

void showIgnoredFilesDialog(BuildContext context, WidgetRef ref) async {
  final globalStateNotifier = ref.read(globalStateProvider.notifier);

  // Load ignored files from SharedPreferences
  List<String> ignoredFiles = await FileChange.loadIgnoredFiles();

  // Update the global state with the loaded ignored files
  globalStateNotifier.updateIgnoredModFiles(ignoredFiles);

  if (context.mounted) {
    await AutomatoDialogManager().showInfoDialog(
      context: context,
      ref: ref,
      title: "Ignored Files",
      content: ignoredFiles.isEmpty
          ? Center(
              child: Text(
                "No files are currently ignored.",
                style: TextStyle(
                  color: AutomatoThemeColors.textDialogColor(ref),
                  fontSize: 24,
                ),
              ),
            )
          : StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height:
                          300, // Set a fixed height to make the list scrollable
                      child: ListView.builder(
                        itemCount: ignoredFiles.length,
                        itemBuilder: (context, index) {
                          String file = ignoredFiles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            color: AutomatoThemeColors.darkBrown(ref)
                                .withOpacity(0.1),
                            child: ListTile(
                              leading: Icon(
                                Icons.file_present,
                                color: AutomatoThemeColors.darkBrown(ref),
                              ),
                              title: Text(
                                file,
                                style: TextStyle(
                                  color:
                                      AutomatoThemeColors.textDialogColor(ref),
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: AutomatoThemeColors.primaryColor(ref),
                                ),
                                onPressed: () async {
                                  // Remove the file from the ignored list and update the state
                                  setState(() {
                                    ignoredFiles.removeAt(index);
                                    globalStateNotifier.updateIgnoredModFiles(
                                        List.from(ignoredFiles));
                                  });
                                  await FileChange.removeIgnoreFiles(
                                      [file]); // Update SharedPreferences
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AutomatoThemeColors.darkBrown(ref),
                      ),
                      onPressed: () async {
                        // Make a copy of the ignored files before clearing
                        List<String> filesToRemove = List.from(ignoredFiles);

                        // Remove all files from the list
                        setState(() {
                          ignoredFiles.clear();
                          globalStateNotifier.updateIgnoredModFiles([]);
                        });

                        // Update SharedPreferences after clearing the list
                        await FileChange.removeIgnoreFiles(
                            filesToRemove); // Update SharedPreferences
                      },
                      icon: Icon(
                        Icons.delete_sweep,
                        color: AutomatoThemeColors.primaryColor(ref),
                      ),
                      label: Text(
                        'Remove All',
                        style: TextStyle(
                          color: AutomatoThemeColors.primaryColor(ref),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      onOkPressed: () {
        Navigator.of(context).pop();
      },
      okLabel: "OK",
    );
  }
}
