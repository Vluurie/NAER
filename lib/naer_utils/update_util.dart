// update_service.dart
import 'dart:convert';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  final String currentVersion = dotenv.env['CURRENT_VERSION']!;
  final String repoOwner = dotenv.env['REPO_OWNER']!;
  final String repoName = dotenv.env['REPO_NAME']!;
  final String naerNexusMods = dotenv.env['NAER_NEXUS_MOD']!;

  Future<Map<String, String>?> getLatestRelease() async {
    final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final version = data['tag_name'] as String?;
      final description = data['body'] as String?;
      if (version != null && description != null) {
        return {
          'version': version,
          'description': description,
        };
      }
    } else {
      throw Exception('Failed to fetch latest release from GitHub');
    }
    return null;
  }

  bool isUpdateAvailable(String latestVersion) {
    return latestVersion.compareTo(currentVersion) > 0;
  }

  void showUpdateDialog(BuildContext context, WidgetRef ref,
      String latestVersion, String description) {
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
            alignment: Alignment.center,
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
      onOkPressed: () {
        _launchURL(naerNexusMods);
        Navigator.of(context).pop();
      },
      okLabel: "Get it on Nexusmods",
      ref: ref,
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
}
