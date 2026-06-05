import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/firebase_config.dart';
import '../../domain/entities/wellness_score.dart';

/// Writes the current user's daily wellness score to Firestore so that
/// friends can see it in real time and the user can query history later.
///
/// Document path: /wellness_daily/{uid}/scores/{YYYY-MM-DD}
///
/// Historical queries:
///   Last 7 days:
///     collection('wellness_daily/$uid/scores')
///       .where('date', isGreaterThanOrEqualTo: sevenDaysAgo)
///       .orderBy('date', descending: true)
///       .limit(7)
///
/// This method is fire-and-forget — errors are logged but never propagate
/// to the caller so wellness loading is never blocked by sync failures.
class WellnessCloudSyncService {
  static Future<void> syncScore(WellnessScore score) async {
    if (!kFirebaseEnabled) return;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final d = score.date;
      final dateKey =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      await FirebaseFirestore.instance
          .doc('wellness_daily/$uid/scores/$dateKey')
          .set({
        'score': score.score,
        'grade': score.grade,
        'totalPenalty': score.totalPenalty,
        'totalBonus': score.totalBonus,
        'steps': score.steps,
        'date': dateKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[WellnessCloudSync] Failed to sync score: $e');
    }
  }
}
