import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';

import 'dart:io';

class ErrorLogViewer extends ConsumerWidget {
  const ErrorLogViewer({super.key});

  Future<void> _deleteLogs(
      final BuildContext context, final WidgetRef ref) async {
    final logFilePath = 'logs.json';
    final file = File(logFilePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.invalidate(logsProvider);
    final logsAsyncValue = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AutomatoThemeColors.primaryColor(ref),
        title: const Text(
          "ERROR LOG VIEWER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: AutomatoThemeColors.dangerZone(ref),
            icon: const Icon(Icons.delete),
            tooltip: "Delete Logs",
            onPressed: () => _deleteLogs(context, ref),
          ),
          SizedBox(
            width: 100,
          )
        ],
      ),
      body: Stack(
        children: [
          AutomatoBackground(
            ref: ref,
            showRepeatingBorders: false,
            gradientColor: AutomatoThemeColors.gradient(ref),
            linesConfig: LinesConfig(
              lineColor: AutomatoThemeColors.bright(ref),
              strokeWidth: 2.5,
              spacing: 5.0,
              flickerDuration: const Duration(milliseconds: 5000),
              enableFlicker: false,
              drawHorizontalLines: true,
              drawVerticalLines: true,
            ),
          ),
          logsAsyncValue.when(
            data: (final logs) {
              if (logs.isEmpty) {
                return const Center(
                  child: Text(
                    "No logs found.",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: logs.length,
                itemBuilder: (final context, final index) {
                  final log = logs[index];
                  return LogCard(log: log, ref: ref);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (final error, final stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Error reading logs: $error",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AutomatoThemeColors.dangerZone(ref),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final WidgetRef ref;

  const LogCard({super.key, required this.log, required this.ref});

  @override
  Widget build(final BuildContext context) {
    return Card(
      color: AutomatoThemeColors.dangerZone(ref).withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogEntry("DateTime", log["DateTime"] ?? "Unknown", ref),
            _buildLogEntry("Exception", log["Exception"] ?? "Unknown", ref),
            _buildLogEntry("Method", log["Method"] ?? "Unknown", ref),
            _buildLogEntry("File", log["File"] ?? "Unknown", ref),
            _buildLogEntry("Line", log["Line"] ?? "Unknown", ref),
            if (log.containsKey("Extra Message"))
              ExpandableSection(
                title: "Extra Message",
                content: log["Extra Message"] ?? "",
                ref: ref,
              ),
            if (log.containsKey("StackTrace"))
              ExpandableSection(
                title: "Stack Trace",
                content: log["StackTrace"] ?? "",
                ref: ref,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(
      final String key, final String value, final WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$key:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AutomatoThemeColors.textColor(ref),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: AutomatoThemeColors.textColor(ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;
  final WidgetRef ref;

  const ExpandableSection({
    required this.title,
    required this.content,
    required this.ref,
    super.key,
  });

  @override
  ExpandableSectionState createState() => ExpandableSectionState();
}

class ExpandableSectionState extends State<ExpandableSection> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12.0),
      collapsedIconColor: AutomatoThemeColors.gradient(widget.ref),
      iconColor: AutomatoThemeColors.gradientStartColor(widget.ref),
      textColor: AutomatoThemeColors.textColor(widget.ref),
      title: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AutomatoThemeColors.textColor(widget.ref),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            height: 200,
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true, // Ensure scrollbars are visible
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          widget.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: AutomatoThemeColors.textColor(widget.ref),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
