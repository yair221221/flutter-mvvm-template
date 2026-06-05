import 'dart:io';
import 'package:flutter/services.dart';

/// Dart wrapper for the native [StepCounterChannel].
///
/// Reads today's step count using the Android TYPE_STEP_COUNTER sensor.
/// The native side stores a daily baseline in SharedPreferences so the
/// returned value resets to 0 at midnight each day.
///
/// Returns 0 on non-Android platforms or when ACTIVITY_RECOGNITION permission
/// has not been granted.
class StepCounterService {
  static const _channel = MethodChannel('yair.mobileApp/step_counter');

  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getStepsToday() async {
    if (!Platform.isAndroid) return 0;
    try {
      final steps = await _channel.invokeMethod<int>('getStepsToday');
      return steps ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
