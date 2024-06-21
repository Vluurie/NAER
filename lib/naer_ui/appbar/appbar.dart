import 'package:flutter/material.dart';
import 'package:NAER/naer_ui/appbar/appbar_icon.dart';
import 'package:flutter_automato_theme/flutter_automato_theme.dart';

class NaerAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
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
          backgroundColor: AutomatoThemeColors.transparentColor(context),
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
                            logoText(isLargeScreen, context),
                            AppIcons.informationIcon(context),
                            AppIcons.logIcon(blinkController, scrollToSetup),
                            Container(
                              height: 50, // Adjust height to match icons
                              alignment: Alignment.center, // Center alignment
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

  Text logoText(bool isLargeScreen, BuildContext context) {
    return Text(
      'NAER',
      style: TextStyle(
        fontSize: isLargeScreen ? 48.0 : 24.0,
        color: AutomatoThemeColors.darkBrown(context),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
