import 'package:flutter/material.dart';

class TabBarWithLoadingOverlay extends StatelessWidget
    implements PreferredSizeWidget {
  final TabBar tabBar;
  final bool isLoading;

  const TabBarWithLoadingOverlay({
    super.key,
    required this.tabBar,
    required this.isLoading,
  });

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        tabBar,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: isLoading,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }
}
