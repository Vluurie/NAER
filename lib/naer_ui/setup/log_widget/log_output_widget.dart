import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:NAER/naer_ui/setup/log_widget/log_widget_utils.dart';
import 'package:NAER/naer_utils/state_provider/log_state.dart';
import 'package:automato_theme/automato_theme.dart';

class LogOutput extends ConsumerStatefulWidget {
  const LogOutput({super.key});

  @override
  LogOutputState createState() => LogOutputState();
}

class LogOutputState extends ConsumerState<LogOutput> {
  final ScrollController scrollController = ScrollController();
  final LogWidgetUtils logUtil = LogWidgetUtils();

  @override
  void initState() {
    super.initState();
    LogState().addListener(() => logUtil.scrollToBottom(scrollController));
  }

  @override
  void dispose() {
    LogState().removeListener(() => logUtil.scrollToBottom(scrollController));
    scrollController.dispose();
    super.dispose();
  }

  void clearLogMessages() {
    LogState().clearLogs();
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider.value(
      value: LogState(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AutomatoThemeColors.darkBrown(ref),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 50,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(5.0),
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    provider.Consumer<LogState>(
                      builder: (context, logState, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: logState.logs.isNotEmpty
                                    ? logUtil.buildLogMessageSpans(context)
                                    : [
                                        const TextSpan(
                                            style: TextStyle(fontSize: 20),
                                            text:
                                                "Hey there! It's quiet for now... 🤫\n\n"),
                                      ],
                              ),
                            ),
                            if (logUtil.isLastMessageProcessing())
                              Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: AutomatoLoading(
                                    color: AutomatoThemeColors.bright(ref),
                                    translateX: 200,
                                    svgString:
                                        AutomatoSvgStrings.automatoSvgStrHead,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
