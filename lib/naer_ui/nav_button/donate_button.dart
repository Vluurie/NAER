// donate_button.dart

import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateButton extends ConsumerStatefulWidget {
  final String url;

  const DonateButton({super.key, required this.url});

  @override
  DonateButtonState createState() => DonateButtonState();
}

class DonateButtonState extends ConsumerState<DonateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onEnter(PointerEvent details) {
    _controller.forward();
  }

  void _onExit(PointerEvent details) {
    _controller.reverse();
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(widget.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: _launchURL,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AutomatoThemeColors.darkBrown(ref),
                  AutomatoThemeColors.darkBrown(ref)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: AutomatoThemeColors.brown25(ref),
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite,
                    color: AutomatoThemeColors.dangerZone(ref)),
                const SizedBox(width: 8.0),
                Text(
                  'Donate Coffee!',
                  style: TextStyle(
                    color: AutomatoThemeColors.primaryColor(ref),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
