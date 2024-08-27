import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_id_list.dart';
import 'package:flutter/material.dart';

class MetadataIDFormFieldWidget extends StatelessWidget {
  const MetadataIDFormFieldWidget({
    super.key,
    required this.metadata,
  });

  final MetadataProvider metadata;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
                textScaler: TextScaler.linear(1.5),
                "Extra: Advanced for ignoring enemies from modifying in this entities: (example: 0x864ec3e4)"),
          ),
          MetadataIDList(
            label: "Enemy Set Action ID",
            controllersProvider: enemySetActionControllersProvider,
          ),
          MetadataIDList(
            label: "Enemy Set Area ID",
            controllersProvider: enemySetAreaControllersProvider,
          ),
          MetadataIDList(
            label: "Enemy Generator ID",
            controllersProvider: enemyGeneratorControllersProvider,
          ),
          MetadataIDList(
            label: "Enemy Layout Action ID",
            controllersProvider: enemyLayoutActionControllersProvider,
          ),
        ],
      ),
    );
  }
}
