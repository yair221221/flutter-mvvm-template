import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = Tween<double>(begin: 0, end: widget.score.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _glowColor(double s) {
    if (s >= 85) return AppColors.green;
    if (s >= 70) return AppColors.cyanDim;
    if (s >= 55) return AppColors.cyan;
    if (s >= 40) return AppColors.orange;
    return const Color(0xFFFF4560);
  }

  @override
  Widget build(BuildContext context) {
    final glow  = _glowColor(widget.score.score);
    final grade = widget.score.grade;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final pct = widget.score.score > 0 ? (_anim.value / (widget.score.score / 100)) : 0.0;
        final displayScore = (widget.score.score * pct).round();
        return SizedBox(
          width: 220, height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: glow.withOpacity(0.08), blurRadius: 60, spreadRadius: 20)],
                ),
              ),
              CustomPaint(size: const Size(220, 220),
                  painter: _NeonRingPainter(progress: _anim.value, color: glow)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$displayScore',
                      style: GoogleFonts.sora(
                        fontSize: 56, fontWeight: FontWeight.w800, color: glow, letterSpacing: -2,
                        shadows: [Shadow(color: glow.withOpacity(0.8), blurRadius: 20),
                                  Shadow(color: glow.withOpacity(0.4), blurRadius: 40)],
                      )),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: glow.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: glow.withOpacity(0.4)),
                      boxShadow: [BoxShadow(color: glow.withOpacity(0.25), blurRadius: 12)],
                    ),
                    child: Text(grade.label,
                        style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700,
                            color: glow, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 6),
                  Text(grade.message, textAlign: TextAlign.center,
                      style: GoogleFonts.hankenGrotesk(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _NeonRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeWidth = 12.0;
    final radius = (size.width / 2) - strokeWidth / 2 - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, 0, 2 * pi, false,
        Paint()..color = color.withOpacity(0.08)..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    if (progress <= 0) return;

    for (final entry in [(strokeWidth + 18, 0.06), (strokeWidth + 10, 0.12), (strokeWidth + 4, 0.20)]) {
      canvas.drawArc(rect, startAngle, sweepAngle, false,
          Paint()..color = color.withOpacity(entry.$2)..strokeWidth = entry.$1
            ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }

    canvas.drawArc(rect, startAngle, sweepAngle, false,
        Paint()..color = color..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    if (progress > 0.02) {
      final tipX = cx + radius * cos(startAngle + sweepAngle);
      final tipY = cy + radius * sin(startAngle + sweepAngle);
      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2 + 2,
          Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_NeonRingPainter old) => old.progress != progress;
}
