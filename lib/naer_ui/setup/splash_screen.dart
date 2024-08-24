import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:NAER/main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // animation for the Lottie file
    _bounceAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    // animation for the text that appears after the Lottie animation
    _textOpacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.7,
          0.9,
          curve: Curves.easeIn,
        ),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const EnemyRandomizerAppState(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Lottie.asset(
                'assets/animations/splash_animation.json',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textOpacityAnimation,
              child: Column(
                children: [
                  Text(
                    'NAER',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enhancing Your Experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Created by Vluurie, RaiderB, For the Community of Mankind',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
