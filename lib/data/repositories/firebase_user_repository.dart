import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final SharedPreferences _prefs;

  static const _kFirstLaunchKey = 'firebase_onboarding_complete';

  FirebaseUserRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore db,
    required SharedPreferences prefs,
  })  : _auth = auth,
        _db = db,
        _prefs = prefs;

  @override
  Future<bool> isFirstLaunch() async =>
      !(_prefs.getBool(_kFirstLaunchKey) ?? false);

  @override
  Future<UserProfile?> getCurrentUser() async {
    try {
      // Ensure we have an anonymous Firebase Auth identity
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      final uid = _auth.currentUser!.uid;

      final doc = await _db.doc('users/$uid').get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserProfile(
        uid: uid,
        displayName: data['displayName'] as String? ?? 'User',
        avatarEmoji: data['avatarEmoji'] as String? ?? '🙂',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserProfile> saveProfile({
    required String uid,
    required String displayName,
    required String avatarEmoji,
  }) async {
    await _db.doc('users/$uid').set({
      'displayName': displayName,
      'avatarEmoji': avatarEmoji,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _prefs.setBool(_kFirstLaunchKey, true);
    return UserProfile(uid: uid, displayName: displayName, avatarEmoji: avatarEmoji);
  }
}
