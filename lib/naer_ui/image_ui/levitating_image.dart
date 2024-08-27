import 'package:flutter/material.dart';

class LevitatingImage extends StatefulWidget {
  final String imagePath;
  final bool isHovered;

  const LevitatingImage({
    super.key,
    required this.imagePath,
    required this.isHovered,
  });

  @override
  LevitatingImageState createState() => LevitatingImageState();
}

class LevitatingImageState extends State<LevitatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5, end: 4).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (final context, final child) {
            return Transform.translate(
              offset: Offset(0, -_animation.value),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (final context, final error, final stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 250,
                    color: Colors.grey,
                  );
                },
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.imagePath.split('/').last,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
