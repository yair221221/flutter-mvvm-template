import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/wellness_score.dart';

abstract class WellnessRepository {
  /// Fetch the wellness score for [date] (defaults to today).
  Future<Either<Failure, WellnessScore>> getWellnessScore(DateTime date);

  /// Whether the app has usage stats permission (Android).
  Future<bool> hasUsagePermission();

  /// Open system settings to grant usage stats permission.
  Future<void> requestUsagePermission();
}
