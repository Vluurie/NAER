import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetaDataTextFormField extends StatelessWidget {
  const MetaDataTextFormField({
    super.key,
    required this.ref,
    required this.controller,
    required this.label,
    required this.validator,
  });

  final WidgetRef ref;
  final TextEditingController controller;
  final String label;
  final String? Function(String? p1)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AutomatoThemeColors.primaryColor(ref), width: 2.0),
        ),
      ),
      validator: validator,
    );
  }
}
