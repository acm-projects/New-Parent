import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FractionCircle extends StatefulWidget {
  const FractionCircle(
      {Key? key,
      this.primaryCircleColor,
      this.backgroundCircleColor,
      this.text,
      this.child,
      this.strokeWidth = 5,
      this.fraction = 1})
      : super(key: key);

  final Color? primaryCircleColor;
  final Color? backgroundCircleColor;
  final String? text;
  final Widget? child;
  final double strokeWidth;
  final double fraction;

  @override
  _FractionCircleState createState() => _FractionCircleState();
}

class _FractionCircleState extends State<FractionCircle> {
  @override
  Widget build(BuildContext context) {
    final Color primaryCircleColor =
        widget.primaryCircleColor ?? Theme.of(context).colorScheme.primary;
    final Color backgroundCircleColor = widget.backgroundCircleColor ??
        Theme.of(context).colorScheme.onBackground;

    return CustomPaint(
      painter: ArcPainter(
          primaryArcColor: primaryCircleColor,
          backgroundArcColor: backgroundCircleColor,
          strokeWidth: widget.strokeWidth,
          fraction: widget.fraction),
      child: Center(
        child: widget.child,
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final Color primaryArcColor;
  final Color backgroundArcColor;
  final double strokeWidth;
  final double fraction;

  ArcPainter(
      {Key? key,
      this.primaryArcColor = Colors.red,
      this.backgroundArcColor = Colors.black12,
      this.strokeWidth = 5,
      this.fraction = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final Color primaryArcColor = this.primaryArcColor;
    final Color backgroundArcColor = this.backgroundArcColor;

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    const startAngle = -math.pi / 2;
    final sweepAngle = (2 * math.pi) * fraction;
    const useCenter = false;

    final paint = Paint()
      ..color = primaryArcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final backgroundPaint = Paint()
      ..color = backgroundArcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.5;

    canvas.drawArc(rect, startAngle, 2 * math.pi, useCenter, backgroundPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
