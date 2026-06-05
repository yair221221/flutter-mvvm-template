import 'package:equatable/equatable.dart';
import 'app_category.dart';

/// A single app's usage record for one day.
class AppUsageRecord extends Equatable {
  final String packageName;
  final String appName;
  final Duration usageDuration;
  final AppCategory category;
  final DateTime date;

  const AppUsageRecord({
    required this.packageName,
    required this.appName,
    required this.usageDuration,
    required this.category,
    required this.date,
  });

  int get usageMinutes => usageDuration.inMinutes;

  /// Raw point contribution (negative = penalty, positive = bonus).
  double get pointContribution =>
      (usageMinutes / 10.0) * category.pointsPer10Min;

  @override
  List<Object?> get props =>
      [packageName, usageDuration, category, date];
}
