import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/app_usage_record.dart';
import '../../domain/entities/app_category.dart';
import '../../domain/entities/wellness_score.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../services/app_categorizer.dart';

// TODO(production): Replace mock data with real UsageStatsManager via
// the `app_usage` package (requires compileSdk 35 + PACKAGE_USAGE_STATS
// permission granted by the user in Android Settings).
class WellnessRepositoryImpl implements WellnessRepository {
  WellnessRepositoryImpl();

  @override
  Future<bool> hasUsagePermission() async => true; // mock always has permission

  @override
  Future<void> requestUsagePermission() async {}   // no-op for mock

  @override
  Future<Either<Failure, WellnessScore>> getWellnessScore(DateTime date) async {
    try {
      return Right(WellnessScore(
        date: date,
        appRecords: _getMockUsage(date),
        steps: _getMockSteps(),
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to load usage data: $e'));
    }
  }

  // ── Realistic mock data ───────────────────────────────────────────────────

  List<AppUsageRecord> _getMockUsage(DateTime date) {
    return [
      _mock('com.zhiliaoapp.musically',      'TikTok',         45, date),
      _mock('com.instagram',                  'Instagram',      30, date),
      _mock('com.twitter.android',            'Twitter / X',    20, date),
      _mock('com.reddit.frontpage',           'Reddit',         15, date),
      _mock('com.supercell.clashofclans',     'Clash of Clans', 25, date),
      _mock('com.duolingo',                   'Duolingo',       15, date),
      _mock('com.amazon.kindle',              'Kindle',         20, date),
      _mock('com.calm.android',               'Calm',           10, date),
      _mock('notion.id',                      'Notion',         20, date),
      _mock('com.google.android.apps.maps',   'Maps',            8, date),
      _mock('com.whatsapp',                   'WhatsApp',       12, date),
      _mock('com.google.android.gm',          'Gmail',          15, date),
    ];
  }

  AppUsageRecord _mock(String pkg, String name, int minutes, DateTime date) =>
      AppUsageRecord(
        packageName: pkg,
        appName: name,
        usageDuration: Duration(minutes: minutes),
        category: AppCategorizer.categorize(pkg),
        date: date,
      );

  int _getMockSteps() => 6800;
}
