import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automato_theme/automato_theme.dart';

class HoverTextIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color textColor;

  const HoverTextIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.textColor,
  });

  @override
  HoverTextIconState createState() => HoverTextIconState();
}

class HoverTextIconState extends ConsumerState<HoverTextIcon> {
  bool _isHovered = false;

  @override
  Widget build(final BuildContext context) {
    return MouseRegion(
      onEnter: (final _) => setState(() => _isHovered = true),
      onExit: (final _) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          color: _isHovered
              ? AutomatoThemeColors.darkBrown(ref)
              : Colors.transparent,
          child: ListTile(
            leading: Icon(
              widget.icon,
              color: _isHovered
                  ? AutomatoThemeColors.bright(ref)
                  : widget.textColor,
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                color: _isHovered
                    ? AutomatoThemeColors.primaryColor(ref)
                    : widget.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void changeAppThemePopup(final BuildContext context, final WidgetRef ref) {
  final textColor = AutomatoThemeColors.textDialogColor(ref);

  AutomatoDialogManager().showInfoDialog(
      context: context,
      ref: ref,
      title: 'Change App Theme',
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'NieR Theme (Default)',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToDefaultTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Angel Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToAngelTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Cyberpunk Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToCyberpunkTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Danger Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToDangerTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Desert Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToDesertTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Floral Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToFloralTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Futuristic Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToFuturisticTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Ice Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToIceTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Lava Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToLavaTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Neon Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToNeonTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Nightmare Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToNightmareTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Pastel Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToPastelTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Retro Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToRetroTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Steampunk Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToSteampunkTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
              HoverTextIcon(
                icon: Icons.color_lens_outlined,
                title: 'Sunset Theme',
                onTap: () {
                  ref
                      .read(automatoThemeNotifierProvider.notifier)
                      .switchToSunsetTheme();
                  Navigator.of(context).pop();
                },
                textColor: textColor,
              ),
            ],
          ),
        ),
      ),
      onOkPressed: () {
        Navigator.of(context).pop();
      },
      okLabel: "Close");
}
