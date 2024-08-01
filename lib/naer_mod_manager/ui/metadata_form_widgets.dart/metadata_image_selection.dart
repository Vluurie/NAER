import 'dart:io';

import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Column buildMetadataImageSelection(
    String? selectedImagePath, WidgetRef ref, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (selectedImagePath != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(selectedImagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AutomatoThemeColors.darkBrown(ref),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image,
                color: AutomatoThemeColors.primaryColor(ref),
                size: 50,
              ),
            ),
          ),
        ),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => pickImage(ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(selectedImagePath == null
                ? 'Select Image/GIF'
                : 'Change Image/GIF'),
          ),
        ),
      ),
    ],
  );
}

void pickImage(WidgetRef ref) async {
  final pickedFile = await FilePicker.platform.pickFiles(type: FileType.image);
  if (pickedFile != null) {
    ref
        .read(selectedImagePathProvider.notifier)
        .setImagePath(pickedFile.files.single.path);
  }
}
