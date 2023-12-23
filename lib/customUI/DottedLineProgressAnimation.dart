import 'package:flutter/material.dart';

class DottedLineProgressIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double height;

  DottedLineProgressIndicator({
    this.color = const Color.fromARGB(255, 86, 94, 84),
    this.dotSize = 3.0,
    this.height = 5.0,
  });

  @override
  _DottedLineProgressIndicatorState createState() =>
      _DottedLineProgressIndicatorState();
}

class _DottedLineProgressIndicatorState
    extends State<DottedLineProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _DottedLinePainter(
            color: widget.color,
            dotSize: widget.dotSize,
            progress: _controller.value,
          ),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
          ),
        );
      },
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double? progress;

  _DottedLinePainter({
    required this.color,
    this.dotSize = 3.0,
    this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double maxDotSize = dotSize * 2; // Maximum size of the dot
    double progressWidth = size.width * (progress ?? 0.1);

    for (double i = 0.0; i < size.width; i += maxDotSize * 2) {
      // Smooth interpolation of dot size
      double fraction = (i < progressWidth) ? i / progressWidth : 0.3;
      double currentDotSize = dotSize +
          (maxDotSize - dotSize) * Curves.easeInOut.transform(fraction);

      canvas.drawCircle(Offset(i, size.height / 2), currentDotSize, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
