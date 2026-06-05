import 'dart:io';
import 'package:flutter/services.dart';

/// Dart wrapper around the native UsageStatsChannel (Android only).
/// On iOS / other platforms all methods are no-ops / return empty data.
class UsageStatsService {
  static const _channel = MethodChannel('yair.mobileApp/usage_stats');

  /// Returns true if the app has "Usage Access" permission on Android.
  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
  }

  /// Opens Android Settings > Usage Access so the user can grant permission.
  static Future<void> openSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openUsageSettings');
  }

  /// Returns raw usage stats for [date] (midnight → midnight).
  /// Each entry: { packageName: String, totalTimeMs: int }
  static Future<List<_AppUsageStat>> getUsageStats(DateTime date) async {
    if (!Platform.isAndroid) return [];

    final start = DateTime(date.year, date.month, date.day);
    final end   = start.add(const Duration(days: 1));

    final raw = await _channel.invokeMethod<List<dynamic>>('getUsageStats', {
      'startMs': start.millisecondsSinceEpoch,
      'endMs':   end.millisecondsSinceEpoch,
    });

    if (raw == null) return [];

    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((m) => _AppUsageStat(
              packageName: m['packageName'] as String,
              totalTimeMs: (m['totalTimeMs'] as num).toInt(),
            ))
        .where((s) => s.totalTimeMs > 60000) // ignore < 1 minute
        .toList();
  }
}

class _AppUsageStat {
  final String packageName;
  final int totalTimeMs;
  const _AppUsageStat({required this.packageName, required this.totalTimeMs});

  Duration get duration => Duration(milliseconds: totalTimeMs);
}
