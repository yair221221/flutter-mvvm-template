import 'package:equatable/equatable.dart';
import 'app_category.dart';
import 'app_usage_record.dart';

/// The computed daily wellness score with full breakdown.
class WellnessScore extends Equatable {
  final DateTime date;
  final List<AppUsageRecord> appRecords;
  final int steps;

  const WellnessScore({
    required this.date,
    required this.appRecords,
    required this.steps,
  });

  // ── Penalty breakdown ──────────────────────────────────────────────────

  List<AppUsageRecord> get penaltyRecords =>
      appRecords.where((r) => r.category.isPenalty).toList()
        ..sort((a, b) => a.pointContribution.compareTo(b.pointContribution));

  List<AppUsageRecord> get bonusRecords =>
      appRecords.where((r) => r.category.isBonus).toList()
        ..sort((a, b) => b.pointContribution.compareTo(a.pointContribution));

  double get totalPenalty {
    final raw = penaltyRecords.fold(0.0, (s, r) => s + r.pointContribution);
    return raw.abs().clamp(0.0, 80.0); // cap max deduction at 80
  }

  double get appBonus {
    final raw = bonusRecords.fold(0.0, (s, r) => s + r.pointContribution);
    return raw.clamp(0.0, 30.0); // cap max app bonus at 30
  }

  /// +1 per 2000 steps, max +10
  double get stepBonus => (steps / 2000.0).clamp(0.0, 10.0);

  double get totalBonus => (appBonus + stepBonus).clamp(0.0, 30.0);

  /// Final score 0–100.
  double get score =>
      (100.0 - totalPenalty + totalBonus).clamp(0.0, 100.0);

  int get scoreInt => score.round();

  ScoreGrade get grade {
    final s = scoreInt;
    if (s >= 95) return ScoreGrade.aPlus;
    if (s >= 85) return ScoreGrade.a;
    if (s >= 70) return ScoreGrade.b;
    if (s >= 55) return ScoreGrade.c;
    if (s >= 40) return ScoreGrade.d;
    return ScoreGrade.f;
  }

  /// Total screen time across ALL apps.
  Duration get totalScreenTime => appRecords.fold(
        Duration.zero,
        (sum, r) => sum + r.usageDuration,
      );

  /// Minutes per category, used for breakdown chart.
  Map<AppCategory, int> get minutesByCategory {
    final map = <AppCategory, int>{};
    for (final r in appRecords) {
      map[r.category] = (map[r.category] ?? 0) + r.usageMinutes;
    }
    return map;
  }

  @override
  List<Object?> get props => [date, appRecords, steps];
}

enum ScoreGrade { aPlus, a, b, c, d, f }

extension ScoreGradeX on ScoreGrade {
  String get label {
    return switch (this) {
      ScoreGrade.aPlus => 'A+',
      ScoreGrade.a     => 'A',
      ScoreGrade.b     => 'B',
      ScoreGrade.c     => 'C',
      ScoreGrade.d     => 'D',
      ScoreGrade.f     => 'F',
    };
  }

  String get message {
    return switch (this) {
      ScoreGrade.aPlus => 'Excellent! You\'re thriving 🌟',
      ScoreGrade.a     => 'Great digital wellness! 🎉',
      ScoreGrade.b     => 'Good balance, keep it up 👍',
      ScoreGrade.c     => 'Fair — try more mindful usage 🤔',
      ScoreGrade.d     => 'Needs improvement 📉',
      ScoreGrade.f     => 'High screen time detected ⚠️',
    };
  }
}
