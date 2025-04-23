import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme.dart';

class WatermarkWidget extends StatelessWidget {
  final Widget child;
  final String watermarkText;
  final Color watermarkColor;
  final double opacity;

  const WatermarkWidget({
    Key? key,
    required this.child,
    this.watermarkText = 'FOOD WASTE MANAGEMENT',
    this.watermarkColor = AppColors.primary,
    this.opacity = 0.03,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          child: Positioned.fill(
            child: CustomPaint(
              painter: WatermarkPainter(
                text: watermarkText,
                color: watermarkColor.withOpacity(opacity),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WatermarkPainter extends CustomPainter {
  final String text;
  final Color color;

  WatermarkPainter({
    required this.text,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w200,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final double spacing = 250;
    final double angle = -30 * (3.141592653589793 / 180);

    for (double y = -size.height; y < size.height * 2; y += spacing) {
      for (double x = -size.width; x < size.width * 2; x += spacing) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 