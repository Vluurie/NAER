import 'package:NAER/naer_mod_manager/ui/metadata_form_widgets.dart/metadata_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_utils/extension_string.dart';

class MetaDataFormFields extends StatelessWidget {
  final WidgetRef ref;
  final TextEditingController idController;
  final TextEditingController nameController;
  final TextEditingController versionController;
  final TextEditingController authorController;
  final TextEditingController descriptionController;

  const MetaDataFormFields({
    super.key,
    required this.ref,
    required this.idController,
    required this.nameController,
    required this.versionController,
    required this.authorController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: MetaDataTextFormField(
            ref: ref,
            controller: idController,
            label: 'ID',
            validator: (value) => value?.validateId(value),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: MetaDataTextFormField(
            ref: ref,
            controller: nameController,
            label: 'Name',
            validator: (value) => value?.validateText(value, fieldName: 'Name'),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: MetaDataTextFormField(
            ref: ref,
            controller: versionController,
            label: 'Version',
            validator: (value) => value?.validateVersion(value),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: MetaDataTextFormField(
            ref: ref,
            controller: authorController,
            label: 'Author',
            validator: (value) =>
                value?.validateText(value, fieldName: 'Author'),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: MetaDataTextFormField(
            ref: ref,
            controller: descriptionController,
            label: 'Description',
            validator: (value) =>
                value?.validateText(value, fieldName: 'Description'),
          ),
        ),
      ],
    );
  }
}
