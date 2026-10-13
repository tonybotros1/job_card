import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps this device's push token in the signed-in user's `users_tokens`.
///
/// Login stores the token once, but FCM rotates tokens (reinstall, cleared
/// data, periodic refresh) and the notify function removes tokens it finds
/// dead, so a phone could silently stop receiving "new card" pushes until the
/// next login. [sync] runs at every start and re-adds the current token.
class PushToken {
  PushToken._();

  static StreamSubscription<String>? _refresh;

  static Future<void> sync() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      if (userId.isEmpty) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) await _store(userId, token, prefs);
      _refresh ??= FirebaseMessaging.instance.onTokenRefresh.listen(
        (t) => _store(userId, t, prefs),
        onError: (_) {},
      );
    } catch (_) {
      // Push is best effort; the app works without it.
    }
  }

  static Future<void> _store(String userId, String token, SharedPreferences prefs) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return;
    final doc = snap.docs.first;
    final tokens = doc.data()['users_tokens'];
    final present = tokens is List && tokens.contains(token);
    if (!present) {
      await doc.reference.update({
        'users_tokens': FieldValue.arrayUnion([token]),
      });
    }
    await prefs.setString('deviceToken', token);
    if (kDebugMode) debugPrint('PushToken: ${present ? 'already registered' : 'added'}');
  }
}
