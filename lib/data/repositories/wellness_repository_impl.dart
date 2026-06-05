import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/app_usage_record.dart';
import '../../domain/entities/wellness_score.dart';
import '../../domain/repositories/wellness_repository.dart';
import '../services/app_categorizer.dart';
import '../services/usage_stats_service.dart';

class WellnessRepositoryImpl implements WellnessRepository {
  WellnessRepositoryImpl();

  @override
  Future<bool> hasUsagePermission() => UsageStatsService.hasPermission();

  @override
  Future<void> requestUsagePermission() => UsageStatsService.openSettings();

  @override
  Future<Either<Failure, WellnessScore>> getWellnessScore(DateTime date) async {
    try {
      final records = Platform.isAndroid
          ? await _getRealUsage(date)
          : _getMockUsage(date);

      return Right(WellnessScore(
        date: date,
        appRecords: records,
        steps: _getMockSteps(),
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to load usage data: $e'));
    }
  }

  // ── Android: real UsageStats via MethodChannel ───────────────────────────

  Future<List<AppUsageRecord>> _getRealUsage(DateTime date) async {
    final stats = await UsageStatsService.getUsageStats(date);
    return stats
        .map((s) => AppUsageRecord(
              packageName: s.packageName,
              appName: _prettifyPackage(s.packageName),
              usageDuration: s.duration,
              category: AppCategorizer.categorize(s.packageName),
              date: date,
            ))
        .toList();
  }

  // ── iOS / Desktop: realistic mock data ───────────────────────────────────

  List<AppUsageRecord> _getMockUsage(DateTime date) => [
        _mock('com.zhiliaoapp.musically',    'TikTok',         45, date),
        _mock('com.instagram',               'Instagram',      30, date),
        _mock('com.twitter.android',         'Twitter / X',    20, date),
        _mock('com.reddit.frontpage',        'Reddit',         15, date),
        _mock('com.supercell.clashofclans',  'Clash of Clans', 25, date),
        _mock('com.duolingo',                'Duolingo',       15, date),
        _mock('com.amazon.kindle',           'Kindle',         20, date),
        _mock('com.calm.android',            'Calm',           10, date),
        _mock('notion.id',                   'Notion',         20, date),
        _mock('com.google.android.apps.maps','Maps',            8, date),
        _mock('com.whatsapp',                'WhatsApp',       12, date),
        _mock('com.google.android.gm',       'Gmail',          15, date),
      ];

  AppUsageRecord _mock(String pkg, String name, int min, DateTime date) =>
      AppUsageRecord(
        packageName: pkg,
        appName: name,
        usageDuration: Duration(minutes: min),
        category: AppCategorizer.categorize(pkg),
        date: date,
      );

  int _getMockSteps() => 6800; // TODO: integrate health package

  String _prettifyPackage(String pkg) {
    final parts = pkg.split('.');
    final name = parts.last.isNotEmpty ? parts.last : parts[parts.length - 2];
    return name[0].toUpperCase() + name.substring(1);
  }
}
