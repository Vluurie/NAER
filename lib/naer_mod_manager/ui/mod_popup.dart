import 'package:flutter/material.dart';

class ModPopup extends StatelessWidget {
  final List<String> currentlyIgnored;
  final List<String> affectedModsInfo;
  final VoidCallback onDismiss;

  const ModPopup({
    super.key,
    required this.currentlyIgnored,
    required this.affectedModsInfo,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 35, 34, 34),
      title: const Text(
        '🔧 Mod Update Heads-up!',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.white),
            children: <TextSpan>[
              const TextSpan(
                  text:
                      "Hey there! NAER noticed a few mods might need your attention. Nothing too scary, but here’s the gist:\n\n",
                  style: TextStyle(color: Colors.lightBlueAccent)),
              const TextSpan(
                  text:
                      "🚀 One mod might have gotten a bit too excited and replaced another mod's files.\n",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(
                  text:
                      "🧹 Maybe some files were accidentally swept away from the installation path.\n",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      "🚫 And there’s a chance that some files didn’t make it to the installation path due to our 'ignore files' setting:\nFiles that were in the installation path: $currentlyIgnored \n\n",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(
                  text: "Affected mod files of the mod: ",
                  style: TextStyle(color: Colors.greenAccent)),
              TextSpan(
                  text: "${affectedModsInfo.join('; ')}.\n\n",
                  style: const TextStyle(fontStyle: FontStyle.italic)),
              const TextSpan(
                  text:
                      "Could you take a peek at your randomization settings? Just to make sure everything’s shipshape.",
                  style: TextStyle(color: Colors.white)),
              const TextSpan(
                  text:
                      "\n\nThe affected mod got uninstalled automatically for you 🧹. ",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onDismiss,
          child: const Text('Got it!',
              style: TextStyle(color: Colors.lightBlueAccent)),
        ),
      ],
    );
  }
}
