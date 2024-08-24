import 'package:NAER/naer_ui/setup/left_side_selection.dart';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectorySelection extends ConsumerWidget {
  const DirectorySelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeftSideSelection(),
          SizedBox(width: 16),
          Expanded(child: LogOutput()),
        ],
      ),
    );
  }
}
