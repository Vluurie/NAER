// naer_app_bar.dart

import 'package:NAER/naer_ui/nav_button/donate_button.dart';
import 'package:flutter/material.dart';
import 'package:NAER/naer_ui/appbar/appbar_icon.dart';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final AnimationController blinkController;
  final VoidCallback scrollToSetup;
  final GlobalKey setupLogOutputKey;
  final AutomatoButton button;

  const NaerAppBar({
    super.key,
    required this.blinkController,
    required this.scrollToSetup,
    required this.setupLogOutputKey,
    required this.button,
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
                  children: <Widget>[
                    logoPadding(isLargeScreen),
                    Flexible(
                      fit: FlexFit.loose,
                      child: SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            logoText(isLargeScreen, context, ref),
                            DonateButton(url: dotenv.env['DONATE_URL']!),
                            AppIcons.informationIcon(context, ref),
                            AppIcons.logIcon(
                                blinkController, scrollToSetup, ref),
                            Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: button,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding logoPadding(bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.only(right: isLargeScreen ? 20.0 : 10.0),
      child: Image.asset(
        'assets/naer_icons/icon.png',
        fit: BoxFit.cover,
        width: isLargeScreen ? 70.0 : 50.0,
      ),
    );
  }

  Text logoText(bool isLargeScreen, BuildContext context, WidgetRef ref) {
    return Text(
      'NAER v3.5a',
      style: TextStyle(
        fontSize: isLargeScreen ? 48.0 : 24.0,
        color: AutomatoThemeColors.darkBrown(ref),
        fontWeight: FontWeight.w700,
        shadows: [
          Shadow(
              offset: const Offset(5.0, 5),
              color: AutomatoThemeColors.hoverBrown(ref).withOpacity(0.5)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
