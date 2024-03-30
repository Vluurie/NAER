import 'dart:io';

extension StringExtensions on String {
  /// Validates an ID string.
  ///
  /// Returns an error message if the [value] is null, empty, or contains invalid characters.
  /// Otherwise, returns null.
  String? validateId(String? value) {
    final RegExp idRegExp = RegExp(r'^[a-z0-9_]+$');
    if (value == null || value.isEmpty || !idRegExp.hasMatch(value)) {
      return 'Please enter a valid ID (lowercase, numbers, underscore only)';
    }
    return null;
  }

  /// Validates a text string.
  ///
  /// Returns an error message if the [value] is null, empty, or contains invalid characters.
  /// Otherwise, returns null.
  String? validateText(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    final RegExp textRegExp = RegExp(r'^[^{}\[\]]+$');
    if (!textRegExp.hasMatch(value)) {
      return 'Invalid characters in $fieldName';
    }
    return null;
  }

  /// Validates a version string.
  ///
  /// Returns an error message if the [value] is null, empty, or does not match the format "x.x.x".
  /// Otherwise, returns null.
  String? validateVersion(String? value) {
    final RegExp versionRegExp = RegExp(r'^\d+\.\d+\.\d+$');
    if (value == null || value.isEmpty || !versionRegExp.hasMatch(value)) {
      return 'Please enter a valid version (e.g., 1.0.0)';
    }
    return null;
  }

  /// Validates a hexadecimal string.
  ///
  /// Returns an error message if the string is not a valid hexadecimal value.
  /// Otherwise, returns null.
  String? validateHexValue() {
    final RegExp hexRegExp = RegExp(r'^0x[a-fA-F0-9]+$');
    if (isEmpty || !hexRegExp.hasMatch(this)) {
      return 'Please enter a valid hexadecimal value (e.g., 0x864ec3e4)';
    }
    return null;
  }

  /// Converts a path to a format that can be used in a command line argument for any platform.
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
}
