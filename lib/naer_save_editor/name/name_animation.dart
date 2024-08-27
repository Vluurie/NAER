import 'dart:async';
import 'dart:math';
import 'package:automato_theme/automato_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedNameDisplay extends ConsumerStatefulWidget {
  final String ingameName;

  const AnimatedNameDisplay({super.key, required this.ingameName});

  @override
  ConsumerState<AnimatedNameDisplay> createState() =>
      _AnimatedNameDisplayState();
}

class _AnimatedNameDisplayState extends ConsumerState<AnimatedNameDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startAnimating();
  }

  void _startAnimating() {
    _animationTimer =
        Timer.periodic(Duration(seconds: Random().nextInt(5) + 5), (final _) {
      if (_controller.isAnimating) {
        _controller.reset();
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (final _, final child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
      ),
      child: Text(
        widget.ingameName.isEmpty
            ? "Loading name..."
            : "Hello ${widget.ingameName}!",
        key: ValueKey<String>(widget.ingameName),
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
          color: widget.ingameName.isEmpty
              ? Colors.grey
              : AutomatoThemeColors.darkBrown(ref),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
