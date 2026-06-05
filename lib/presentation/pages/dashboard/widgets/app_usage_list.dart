import 'package:flutter/material.dart';
import '../../../../domain/entities/app_usage_record.dart';
import '../../../../domain/entities/app_category.dart';
import '../../../../domain/entities/wellness_score.dart';

class AppUsageListWidget extends StatelessWidget {
  final WellnessScore score;
  const AppUsageListWidget({super.key, required this.score});

  static const _categoryColors = {
    AppCategory.shortVideo:   Color(0xFFF44336),
    AppCategory.socialMedia:  Color(0xFFFF7043),
    AppCategory.gaming:       Color(0xFFFF9800),
    AppCategory.neutral:      Color(0xFF90A4AE),
    AppCategory.educational:  Color(0xFF4CAF50),
    AppCategory.reading:      Color(0xFF42A5F5),
    AppCategory.mindfulness:  Color(0xFF9C27B0),
    AppCategory.productivity: Color(0xFF00BCD4),
  };

  @override
  Widget build(BuildContext context) {
    // Sort: worst penalty first, then best bonuses
    final sorted = [...score.appRecords]
      ..sort((a, b) => a.pointContribution.compareTo(b.pointContribution));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('App Details',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        ...sorted.map((r) => _AppTile(record: r,
            color: _categoryColors[r.category]!)),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppUsageRecord record;
  final Color color;
  const _AppTile({required this.record, required this.color});

  @override
  Widget build(BuildContext context) {
    final mins = record.usageMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
    final pts = record.pointContribution;
    final ptsStr = pts >= 0 ? '+${pts.toStringAsFixed(1)}' : pts.toStringAsFixed(1);
    final isBonus = pts >= 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.2))),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.2),
          child: Text(record.category.emoji, style: const TextStyle(fontSize: 16)),
        ),
        title: Text(record.appName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${record.category.label} · $timeStr',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isBonus
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ptsStr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isBonus ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
      ),
    );
  }
}
