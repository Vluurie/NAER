import 'package:NAER/naer_ui/appbar/appbar_icon.dart';
import 'package:NAER/naer_ui/button/donate_button.dart';
import 'package:automato_theme/automato_theme.dart';
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

  bool isScreenLarge(double maxWidth) => maxWidth > 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              builder: (context, constraints) {
                bool isLargeScreen = isScreenLarge(constraints.maxWidth);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 8.0),
                    logoText(isLargeScreen, context, ref),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppIcons.informationIcon(context, ref),
                        const SizedBox(width: 16.0),
                        DonateButton(url: dotenv.env['DONATE_URL']!),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          leading: Padding(
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
              ),
            ),
          ),
        )
      ],
    );
  }

  Text logoText(bool isLargeScreen, BuildContext context, WidgetRef ref) {
    return Text(
      'NAER v3.6a',
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
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
