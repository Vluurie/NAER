import 'package:NAER/naer_ui/appbar/appbar_icon.dart';
import 'package:NAER/naer_utils/start_modification_process.dart';
import 'package:NAER/naer_utils/state_provider/global_state.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final AnimationController blinkController;
  final VoidCallback scrollToSetup;
  final GlobalKey setupLogOutputKey;
  final VoidCallback onMenuPressed;

  const NaerAppBar({
    super.key,
    required this.blinkController,
    required this.scrollToSetup,
    required this.setupLogOutputKey,
    required this.onMenuPressed,
  });

  bool isScreenLarge(final double maxWidth) => maxWidth > 600;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);
    bool checkPaths = validateInputOutput(globalState);
    return Stack(
      children: [
        Positioned(
          top: -15,
          left: 0,
          right: 0,
          child: buildRepeatingBorderSVG(
            context,
            svgWidget: const AutomatoBorderSVG(
              svgString: AutomatoSvgStrings.automatoSvgStrBorder,
            ),
            height: 50,
            width: 50,
          ),
        ),
        AppBar(
          toolbarHeight: 70.0,
          backgroundColor: AutomatoThemeColors.transparentColor(ref),
          elevation: 0,
          title: SizedBox(
            height: 70,
            child: LayoutBuilder(
              builder: (final context, final constraints) {
                bool isLargeScreen = isScreenLarge(constraints.maxWidth);
                return Row(
                  children: <Widget>[
                    const SizedBox(width: 8.0),
                    logoText(context, ref, isLargeScreen: isLargeScreen),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!validateInputOutput(globalState))
                          AppIcons.searchPaths(context, ref),
                        AppIcons.showIgnoredFiles(context, ref),
                        AppIcons.copyArguments(context, ref),
                        AppIcons.informationIcon(context, ref),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          leading: checkPaths
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AutomatoThemeColors.textDialogColor(ref),
                            AutomatoThemeColors.darkBrown(ref),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: AutomatoThemeColors.brown25(ref),
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        hoverColor: AutomatoThemeColors.textDialogColor(ref),
                        highlightColor: AutomatoThemeColors.darkBrown(ref),
                        color: AutomatoThemeColors.dangerZone(ref),
                        icon: Icon(
                          Icons.menu_outlined,
                          color: AutomatoThemeColors.primaryColor(ref),
                        ),
                        onPressed: onMenuPressed,
                      )),
                )
              : const SizedBox(),
        )
      ],
    );
  }

  Widget logoText(final BuildContext context, final WidgetRef ref,
      {required final bool isLargeScreen}) {
    final String currentVersion =
        dotenv.env['CURRENT_VERSION'] ?? 'Unknown Version';

    const String buildMode = kDebugMode ? 'DEBUG BUILD' : '';

    final Text mainTitle = Text(
      'NAER',
      style: TextStyle(
        fontSize: isLargeScreen ? 48.0 : 24.0,
        color: AutomatoThemeColors.darkBrown(ref),
        fontWeight: FontWeight.w700,
        shadows: [
          Shadow(
            offset: const Offset(5.0, 5),
            color: AutomatoThemeColors.hoverBrown(ref).withOpacity(0.5),
          ),
        ],
      ),
    );

    final Text versionText = Text(
      '$currentVersion $buildMode',
      style: TextStyle(
        fontSize: isLargeScreen ? 16.0 : 20.0,
        color: AutomatoThemeColors.primaryColor(ref),
        fontWeight: FontWeight.w700,
      ),
    );

    return Row(
      children: [
        mainTitle,
        const SizedBox(width: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(3.0, 3),
                color: AutomatoThemeColors.hoverBrown(ref).withOpacity(0.5),
              )
            ],
            color: AutomatoThemeColors.darkBrown(ref),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: versionText,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
