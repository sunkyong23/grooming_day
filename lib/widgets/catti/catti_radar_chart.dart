import 'dart:math';

import 'package:flutter/material.dart';

class CattiRadarChart extends StatefulWidget {
  final int socialPercent;
  final int curiosityPercent;
  final int activityPercent;
  final int emotionPercent;

  const CattiRadarChart({
    super.key,
    required this.socialPercent,
    required this.curiosityPercent,
    required this.activityPercent,
    required this.emotionPercent,
  });

  @override
  State<CattiRadarChart> createState() => _CattiRadarChartState();
}

class _CattiRadarChartState extends State<CattiRadarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant CattiRadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.socialPercent != widget.socialPercent ||
        oldWidget.curiosityPercent != widget.curiosityPercent ||
        oldWidget.activityPercent != widget.activityPercent ||
        oldWidget.emotionPercent != widget.emotionPercent) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> get _values => [
    widget.socialPercent.toDouble(),
    widget.curiosityPercent.toDouble(),
    widget.activityPercent.toDouble(),
    widget.emotionPercent.toDouble(),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) {
          return CustomPaint(
            painter: _CattiRadarChartPainter(
              values: _values,
              progress: _progress.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _CattiRadarChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;

  _CattiRadarChartPainter({required this.values, required this.progress});

  static const List<String> labels = ['사교성', '호기심', '활동성', '감정표현'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = min(size.width, size.height) * 0.34;

    final gridPaint = Paint()
      ..color = const Color(0xFFEAD3C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = const Color(0xFFEAD3C8).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final fillPaint = Paint()
      ..color = const Color(0xFFE8A58C).withValues(alpha: 0.28 * progress)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFFE8A58C).withValues(alpha: progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    final dotProgress = ((progress - 0.72) / 0.28).clamp(0.0, 1.0);

    final dotPaint = Paint()
      ..color = const Color(0xFFE8A58C).withValues(alpha: dotProgress)
      ..style = PaintingStyle.fill;

    // Grid polygons
    for (int level = 1; level <= 4; level++) {
      final levelRadius = radius * (level / 4);
      final path = _polygonPath(center, levelRadius);

      canvas.drawPath(path, gridPaint);
    }

    // Axis lines
    for (int i = 0; i < 4; i++) {
      final point = _pointForIndex(center, radius, i);
      canvas.drawLine(center, point, axisPaint);
    }

    // Labels
    for (int i = 0; i < 4; i++) {
      final labelPoint = _pointForIndex(center, radius + 28, i);
      _drawLabel(canvas, labels[i], labelPoint, i);
    }

    // Data polygon
    final dataPoints = List.generate(4, (index) {
      final valueRadius =
          radius * (values[index].clamp(0, 100) / 100) * progress;
      return _pointForIndex(center, valueRadius, index);
    });

    final dataPath = Path()..moveTo(dataPoints.first.dx, dataPoints.first.dy);
    for (int i = 1; i < dataPoints.length; i++) {
      dataPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, linePaint);

    for (final point in dataPoints) {
      canvas.drawCircle(point, 3.8 * dotProgress, dotPaint);
    }
  }

  Path _polygonPath(Offset center, double radius) {
    final points = List.generate(4, (index) {
      return _pointForIndex(center, radius, index);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    return path;
  }

  Offset _pointForIndex(Offset center, double radius, int index) {
    final angle = -pi / 2 + (2 * pi * index / 4);

    return Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset point, int index) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF6B4A3A),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = point.dx - textPainter.width / 2;
    double dy = point.dy - textPainter.height / 2;

    if (index == 0) {
      dy -= 4;
    } else if (index == 1) {
      dx += 8;
    } else if (index == 2) {
      dy += 4;
    } else if (index == 3) {
      dx -= 8;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _CattiRadarChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.values != values;
  }
}
