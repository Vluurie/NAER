import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_id_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetadataIDList extends ConsumerWidget {
  const MetadataIDList({
    super.key,
    required this.label,
    required this.controllersProvider,
  });

  final String label;
  final StateNotifierProvider<ControllerNotifier, List<TextEditingController>>
      controllersProvider;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final controllers = ref.watch(controllersProvider);

    return Column(
      children: [
        ...List.generate(
          controllers.length,
          (final i) => MetaDataIDField(
            label: label,
            controllers: controllers,
            index: i,
            onRemoved: () {
              ref.read(controllersProvider.notifier).removeController(i);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                ref.read(controllersProvider.notifier).addController();
              },
              tooltip: 'Add more',
            ),
          ),
        ),
      ],
    );
  }
}
