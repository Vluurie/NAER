import 'package:NAER/naer_utils/extension_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetaDataIDField extends ConsumerWidget {
  const MetaDataIDField({
    super.key,
    required this.label,
    required this.controllers,
    required this.index,
    required this.onRemoved,
  });

  final String label;
  final List<TextEditingController> controllers;
  final int index;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controllers[index],
              decoration: InputDecoration(
                labelText: "$label ${index + 1}",
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else {
                  return value.validateHexValue();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemoved,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
