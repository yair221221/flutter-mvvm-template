import 'package:flutter/material.dart';
import '../../../../domain/entities/app_category.dart';
import '../../../../domain/entities/wellness_score.dart';

/// Horizontal bar chart showing minutes per category.
class UsageBreakdownWidget extends StatelessWidget {
  final WellnessScore score;
  const UsageBreakdownWidget({super.key, required this.score});

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
    final byCategory = score.minutesByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final totalMinutes =
        byCategory.values.fold(0, (s, v) => s + v).toDouble();

    // Sort: penalties first (worst first), then bonuses
    final sorted = byCategory.entries.toList()
      ..sort((a, b) {
        final aIsP = a.key.isPenalty ? 0 : 1;
        final bIsP = b.key.isPenalty ? 0 : 1;
        if (aIsP != bIsP) return aIsP.compareTo(bIsP);
        return b.value.compareTo(a.value);
      });

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usage Breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Stacked bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: sorted.map((e) {
                  final frac = e.value / totalMinutes;
                  return Expanded(
                    flex: (frac * 1000).round(),
                    child: Container(
                      height: 14,
                      color: _categoryColors[e.key],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: sorted.map((e) {
                final mins = e.value;
                final h = mins ~/ 60;
                final m = mins % 60;
                final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';
                return _LegendChip(
                  color: _categoryColors[e.key]!,
                  label:
                      '${e.key.emoji} ${e.key.label} · $timeStr',
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}
