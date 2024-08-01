import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

void showInformationDialog(BuildContext context, WidgetRef ref) {
  AutomatoDialogManager().showInfoDialog(
    context: context,
    ref: ref,
    title: "Information",
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Thank you for using this tool! It is provided free of charge and developed in my personal time."
          "\n\nIf you encounter any issues or have questions, feel free to ask in the Nier Modding community!"
          "\n\nSpecial thanks to RaiderB with his NieR CLI and the entire mod community for making this possible.",
          style: TextStyle(
              color: AutomatoThemeColors.textDialogColor(ref), fontSize: 20),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      AutomatoThemeColors.darkBrown(ref))),
              onPressed: () => _launchURL(dotenv.env['NAER_GITHUB_URL']!),
              child: Text('NAER - Github',
                  style:
                      TextStyle(color: AutomatoThemeColors.primaryColor(ref))),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      AutomatoThemeColors.darkBrown(ref))),
              onPressed: () => _launchURL(dotenv.env['NIER_CLI_URL']!),
              child: Text('NieR Cli - RaiderB',
                  style:
                      TextStyle(color: AutomatoThemeColors.primaryColor(ref))),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      AutomatoThemeColors.darkBrown(ref))),
              onPressed: () => _launchURL(dotenv.env['AUTOMATO_THEME_URL']!),
              child: Text('Automato Theme - Github',
                  style:
                      TextStyle(color: AutomatoThemeColors.primaryColor(ref))),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      AutomatoThemeColors.darkBrown(ref))),
              onPressed: () => _launchURL(dotenv.env['DISCORD_INVITE_LINK']!),
              child: Text('Modding Discord',
                  style:
                      TextStyle(color: AutomatoThemeColors.primaryColor(ref))),
            ),
          ],
        ),
      ],
    ),
    onOkPressed: () => Navigator.of(context).pop(),
    okLabel: 'Close',
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
