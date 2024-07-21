import 'package:NAER/naer_mod_manager/ui/form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class DirectoryStructureWidget extends ConsumerWidget {
  const DirectoryStructureWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDirectory = ref.watch(selectedDirectoryProvider);
    final directoryContentsInfo = ref.watch(directoryContentsInfoProvider);

    if (selectedDirectory == null) {
      return Container();
    }

    Future.microtask(() {
      ref.read(showModFolderWarningProvider.notifier).state =
          directoryContentsInfo.isEmpty;
    });

    if (directoryContentsInfo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          'No mod files found',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text('Selected Directory: $selectedDirectory'),
        ),
        SizedBox(
          width: 1000,
          child: LimitedBox(
            maxHeight: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: directoryContentsInfo.length,
              itemBuilder: (context, index) {
                String filePath = directoryContentsInfo[index];
                String displayPath = filePath
                    .replaceAll(selectedDirectory, '')
                    .replaceAll(p.separator, '/');
                return ListTile(
                  title: Text(displayPath),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
