import 'package:NAER/naer_ui/setup/left_side_selection.dart';
import 'package:NAER/naer_ui/setup/log_widget/log_output_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectorySelection extends ConsumerWidget {
  const DirectorySelection({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LeftSideSelection(),
          const SizedBox(width: 16),
          const Expanded(child: LogOutput()),
        ],
      ),
    );
  }
}
