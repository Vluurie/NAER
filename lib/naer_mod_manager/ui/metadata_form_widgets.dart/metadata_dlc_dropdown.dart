import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_mod_manager/ui/form_provider.dart';

class MetadataDLCDropdown extends ConsumerWidget {
  final String? initialValue;
  final Function(String?) onChanged;

  const MetadataDLCDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final dlcValue = ref.watch(dlcControllerProvider);
    return DropdownButtonFormField<String>(
      value: initialValue ?? dlcValue,
      decoration: InputDecoration(
        labelText: 'DLC',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      items: <String>['true', 'false'].map((final String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (final String? newValue) {
        onChanged(newValue);
        ref.read(dlcControllerProvider.notifier).state = newValue;
      },
      validator: (final value) {
        if (value == null || value.isEmpty) {
          return 'Please select a value';
        }
        return null;
      },
    );
  }
}
