import 'dart:io';

extension StringExtensions on String {
  String? validateId(final String? value) {
    final RegExp idRegExp = RegExp(r'^[a-z0-9_]+$');
    if (value == null || value.isEmpty || !idRegExp.hasMatch(value)) {
      return 'Please enter a valid ID (lowercase, numbers, underscore only)';
    }
    return null;
  }

  String? validateText(final String? value, {required final String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    final RegExp textRegExp = RegExp(r'^[^{}\[\]]+$');
    if (!textRegExp.hasMatch(value)) {
      return 'Invalid characters in $fieldName';
    }
    return null;
  }

  String? validateVersion(final String? value) {
    final RegExp versionRegExp = RegExp(r'^\d+\.\d+\.\d+$');
    if (value == null || value.isEmpty || !versionRegExp.hasMatch(value)) {
      return 'Please enter a valid version (e.g., 1.0.0)';
    }
    return null;
  }

  String? validateHexValue() {
    final RegExp hexRegExp = RegExp(r'^0x[a-fA-F0-9]+$');
    if (isEmpty || !hexRegExp.hasMatch(this)) {
      return 'Please enter a valid hexadecimal value (e.g., 0x864ec3e4)';
    }
    return null;
  }

  String convertAndEscapePath() {
    if (Platform.isMacOS || Platform.isLinux) {
      if (contains(' ') ||
          contains('(') ||
          contains(')') ||
          contains('&') ||
          contains('\\')) {
        return '"$this"';
      }
    }

    return this;
  }

  bool toBool() {
    return toLowerCase() == 'true';
  }
}
