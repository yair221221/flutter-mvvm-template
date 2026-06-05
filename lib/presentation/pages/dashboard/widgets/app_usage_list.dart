import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/app_usage_record.dart';
import '../../../../domain/entities/app_category.dart';
import '../../../../domain/entities/wellness_score.dart';

class AppUsageListWidget extends StatelessWidget {
  final WellnessScore score;
  const AppUsageListWidget({super.key, required this.score});

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
    final sorted = [...score.appRecords]
      ..sort((a, b) => a.pointContribution.compareTo(b.pointContribution));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('App Details', style: GoogleFonts.sora(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ),
        ...sorted.map((r) => _GlassAppTile(
            record: r, color: _glowColors[r.category] ?? AppColors.neutralGlow)),
      ],
    );
  }
}

class _GlassAppTile extends StatelessWidget {
  final AppUsageRecord record;
  final Color color;
  const _GlassAppTile({required this.record, required this.color});

  @override
  Widget build(BuildContext context) {
    final mins = record.usageMinutes;
    final h = mins ~/ 60; final m = mins % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
    final pts = record.pointContribution;
    final ptsStr = pts >= 0 ? '+${pts.toStringAsFixed(1)}' : pts.toStringAsFixed(1);
    final isBonus = pts >= 0;
    final badgeColor = isBonus ? AppColors.green : AppColors.shortVideoGlow;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
          ),
          child: Center(child: Text(record.category.emoji,
              style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.appName, style: GoogleFonts.hankenGrotesk(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text('${record.category.label} · $timeStr', style: GoogleFonts.jetBrainsMono(
              fontSize: 10, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: badgeColor.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: badgeColor.withOpacity(0.2), blurRadius: 8)],
          ),
          child: Text(ptsStr, style: GoogleFonts.jetBrainsMono(
              fontSize: 12, fontWeight: FontWeight.w700, color: badgeColor)),
        ),
      ]),
    );
  }
}
