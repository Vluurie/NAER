import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShakeAnimationWidget extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;
  final VoidCallback onEnd;

  const ShakeAnimationWidget({
    super.key,
    required this.child,
    required this.message,
    this.duration = const Duration(milliseconds: 500),
    required this.onEnd,
  });

  @override
  ShakeAnimationWidgetState createState() => ShakeAnimationWidgetState();
}

class ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isShaking = false;

  void shake() {
    setState(() {
      _isShaking = true;
    });
    _controller.forward(from: 0.0).then((final _) => setState(() {
          _isShaking = false;
        }));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((final status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd();
        }
      });

    _animation = Tween<double>(begin: 0.0, end: 10.0).animate(_controller);
  }

  @override
  Widget build(final BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          child: widget.child,
          builder: (final context, final child) {
            return Transform.translate(
              offset: Offset(0, math.sin(_animation.value * math.pi) * 4),
              child: child,
            );
          },
        ),
        if (_isShaking)
          Positioned(
            top: 0,
            child: Container(
              alignment: const Alignment(100, 100),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
