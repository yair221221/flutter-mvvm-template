import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/app_category.dart';
import '../../../../domain/entities/wellness_score.dart';

class UsageBreakdownWidget extends StatelessWidget {
  final WellnessScore score;
  const UsageBreakdownWidget({super.key, required this.score});

  static const _glowColors = {
    AppCategory.shortVideo:   AppColors.shortVideoGlow,
    AppCategory.socialMedia:  AppColors.socialGlow,
    AppCategory.gaming:       AppColors.gamingGlow,
    AppCategory.neutral:      AppColors.neutralGlow,
    AppCategory.educational:  AppColors.educationGlow,
    AppCategory.reading:      AppColors.readingGlow,
    AppCategory.mindfulness:  AppColors.mindfulnessGlow,
    AppCategory.productivity: AppColors.productivityGlow,
  };

  @override
  Widget build(BuildContext context) {
    final byCategory = score.minutesByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();
    final totalMinutes = byCategory.values.fold(0, (s, v) => s + v);
    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Usage Breakdown', style: GoogleFonts.sora(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            const SizedBox(width: 8),
            _PulseDot(),
          ]),
          const SizedBox(height: 16),
          ...sorted.map((e) {
            final pct   = totalMinutes > 0 ? e.value / totalMinutes : 0.0;
            final color = _glowColors[e.key] ?? AppColors.neutralGlow;
            final h = e.value ~/ 60; final m = e.value % 60;
            final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
            return _NeonBar(label: '${e.key.emoji}  ${e.key.label}',
                time: timeStr, progress: pct.clamp(0.0, 1.0), color: color);
          }),
        ],
      ),
    );
  }
}

class _NeonBar extends StatefulWidget {
  final String label, time;
  final double progress;
  final Color color;
  const _NeonBar({required this.label, required this.time,
      required this.progress, required this.color});
  @override State<_NeonBar> createState() => _NeonBarState();
}

class _NeonBarState extends State<_NeonBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.label, style: GoogleFonts.hankenGrotesk(
              fontSize: 13, color: AppColors.onSurface, fontWeight: FontWeight.w500)),
          Text(widget.time, style: GoogleFonts.jetBrainsMono(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
        ]),
        const SizedBox(height: 6),
        AnimatedBuilder(animation: _anim,
            builder: (_, __) => _GlowBar(progress: _anim.value, color: widget.color)),
      ]),
    );
  }
}

class _GlowBar extends StatelessWidget {
  final double progress; final Color color;
  const _GlowBar({required this.progress, required this.color});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Stack(children: [
        Container(height: 6,
            decoration: BoxDecoration(color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100))),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                ],
              )),
        ),
      ]),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override State<_PulseDot> createState() => _PulseDotState();
}
class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _ctrl, builder: (_, __) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan,
          boxShadow: [BoxShadow(
              color: AppColors.cyan.withOpacity(0.3 + 0.4 * _ctrl.value),
              blurRadius: 4 + 8 * _ctrl.value, spreadRadius: _ctrl.value * 3)]),
    ));
  }
}
