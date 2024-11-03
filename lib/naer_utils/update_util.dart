import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NAER/naer_utils/global_log.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

class UpdateService {
  final String currentVersion = dotenv.env['CURRENT_VERSION']!;
  final String repoOwner = dotenv.env['REPO_OWNER']!;
  final String repoName = dotenv.env['REPO_NAME']!;

  Future<Map<String, String>?> getLatestRelease() async {
    final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final version = data['tag_name'] as String?;
      final description = data['body'] as String?;
      final installerUrl = data['assets']?.firstWhere((final asset) =>
          (asset['name'] as String)
              .contains('.exe'))['browser_download_url'] as String?;

      if (version != null && description != null && installerUrl != null) {
        return {
          'version': version,
          'description': description,
          'installerUrl': installerUrl,
        };
      }
    } else {
      throw Exception('Failed to fetch latest release from GitHub');
    }
    return null;
  }

  bool isUpdateAvailable(final String latestVersion) {
    return latestVersion.compareTo(currentVersion) > 0;
  }

  Future<void> showLoadingDialog(
      final BuildContext context, final WidgetRef ref) async {
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (final BuildContext context) {
        return Center(
          child: AutomatoLoading(
            color: AutomatoThemeColors.bright(ref),
            translateX: 0,
            svgString: AutomatoSvgStrings.automatoSvgStrHead,
          ),
        );
      },
    ));
  }

  void showUpdateDialog(
      final BuildContext context,
      final WidgetRef ref,
      final String latestVersion,
      final String description,
      final String installerUrl) {
    AutomatoDialogManager().showInfoDialog(
      context: context,
      titleColor: AutomatoThemeColors.textDialogColor(ref),
      title: "✨ New Version Available! ✨",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AutomatoThemeColors.textDialogColor(ref),
                fontSize: 18,
              ),
              children: [
                TextSpan(
                  text: "Version ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AutomatoThemeColors.textDialogColor(ref)),
                ),
                TextSpan(
                  text: "$latestVersion ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AutomatoThemeColors.saveZone(ref),
                      fontSize: 20),
                ),
                TextSpan(
                  text: "is now available! 🚀\n\n",
                  style: TextStyle(
                      fontSize: 20,
                      color: AutomatoThemeColors.textDialogColor(ref)),
                ),
                TextSpan(
                  text: "Release Notes:\n",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AutomatoThemeColors.textDialogColor(ref)),
                ),
              ],
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1.0,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                  minHeight: 50,
                ),
                padding: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(5, 5),
                      blurRadius: 2,
                      color: AutomatoThemeColors.brown25(ref),
                    ),
                  ],
                  color: AutomatoThemeColors.darkBrown(ref),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: AutomatoThemeColors.bright(ref),
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      onOkPressed: () async {
        Navigator.of(context).pop();
        await _downloadAndRunInstaller(context, ref, installerUrl);
      },
      okLabel: "Update Now",
      ref: ref,
    );
  }

  Future<void> _downloadAndRunInstaller(final BuildContext context,
      final WidgetRef ref, final String urlStr) async {
    await showLoadingDialog(context, ref);

    final Uri url = Uri.parse(urlStr);
    final String installerFileName = path.basename(url.path);
    final Directory tempDir = Directory.systemTemp;
    final String installerFilePath = path.join(tempDir.path, installerFileName);

    final http.Client client = http.Client();
    final http.Request request = http.Request('GET', url);
    final http.StreamedResponse response = await client.send(request);

    if (response.statusCode == 200) {
      final File file = File(installerFilePath);
      final IOSink sink = file.openWrite();
      await response.stream.pipe(sink);
      await sink.flush();
      await sink.close();
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (await file.exists()) {
        await Process.start(installerFilePath, []).then((final process) {
          process.exitCode.then((final exitCode) {
            if (exitCode == 0) {
              print("Installer executed successfully.");
            } else {
              print("Installer execution failed with exit code $exitCode.");
            }
          });
        });
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      throw Exception('Failed to download the installer.');
    }
  }

  Future<void> checkForUpdates(
      final BuildContext context, final WidgetRef ref) async {
    await showLoadingDialog(context, ref);

    try {
      final latestRelease = await getLatestRelease();
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (latestRelease != null) {
        final latestVersion = latestRelease['version']!;
        final description = latestRelease['description']!;
        final installerUrl = latestRelease['installerUrl']!;

        if (isUpdateAvailable(latestVersion)) {
          if (context.mounted) {
            showUpdateDialog(
                context, ref, latestVersion, description, installerUrl);
          }
        } else {
          print('No update available.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      print('Error checking for updates: $e');
    }
  }

  static Future<void> checkForUpdateAndHandleResponse(
      final BuildContext context, final WidgetRef ref) async {
    final updateService = UpdateService();

    try {
      await updateService.showLoadingDialog(context, ref);

      final latestRelease = await updateService.getLatestRelease();

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        if (latestRelease != null &&
            updateService.isUpdateAvailable(latestRelease['version']!)) {
          updateService.showUpdateDialog(
            context,
            ref,
            latestRelease['version']!,
            latestRelease['description']!,
            latestRelease['installerUrl']!,
          );
        } else {
          globalLog("You are on the latest Version of NAER!");
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      globalLog('Failed to check for updates: $e');
    }
  }
}
