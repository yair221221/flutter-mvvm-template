import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../domain/entities/wellness_score.dart';

class ScoreRingWidget extends StatefulWidget {
  final WellnessScore score;
  const ScoreRingWidget({super.key, required this.score});

  @override
  State<ScoreRingWidget> createState() => _ScoreRingWidgetState();
}

class _ScoreRingWidgetState extends State<ScoreRingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.score.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _colorForScore(double s) {
    if (s >= 85) return const Color(0xFF4CAF50);
    if (s >= 70) return const Color(0xFF8BC34A);
    if (s >= 55) return const Color(0xFFFFC107);
    if (s >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForScore(widget.score.score);
    final grade = widget.score.grade;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ring
            CustomPaint(
              size: const Size(200, 200),
              painter: _RingPainter(
                progress: _anim.value,
                color: color,
                trackColor: color.withOpacity(0.15),
              ),
            ),
            // Score text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (widget.score.score * _anim.value / (widget.score.score / 100))
                      .round()
                      .toString(),
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grade.label,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter(
      {required this.progress,
      required this.color,
      required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeWidth = 16.0;
    final radius = (size.width / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
