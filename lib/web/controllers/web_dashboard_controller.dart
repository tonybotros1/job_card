import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/web_job_card.dart';

/// Counts and the recent list for the web dashboard.
///
/// Totals come from Firestore `count()` aggregations, so no card documents are
/// downloaded for them. Every query keeps `status` in the filter so it is
/// served by the index the lists already use.
class WebDashboardController extends GetxController {
  final openCount = RxnInt();
  final finishedCount = RxnInt();
  final todayCount = RxnInt();
  final weekCount = RxnInt();
  final recent = <WebJobCard>[].obs;
  final loading = true.obs;
  final error = RxnString();
  final lastUpdated = Rxn<DateTime>();

  String _userId = '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Query<Map<String, dynamic>> _query(bool open) => FirebaseFirestore.instance
      .collection('car_card')
      .where('user_id', isEqualTo: _userId)
      .where('status', isEqualTo: open);

  /// Range on `timestamp` served by the existing (user_id, status, timestamp
  /// desc) index: without the explicit descending sort Firestore implies an
  /// ascending one and refuses the query (failed-precondition).
  Query<Map<String, dynamic>> _since(bool open, Timestamp from) => _query(open)
      .where('timestamp', isGreaterThanOrEqualTo: from)
      .orderBy('timestamp', descending: true);

  Future<int> _count(Query<Map<String, dynamic>> q) async =>
      (await q.count().get()).count ?? 0;

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      if (_userId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        _userId = prefs.getString('userId') ?? '';
      }
      if (_userId.isEmpty) {
        error.value = 'Not signed in';
        return;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final todayTs = Timestamp.fromDate(today);
      final weekTs = Timestamp.fromDate(weekStart);

      final results = await Future.wait<dynamic>([
        _count(_query(true)),
        _count(_query(false)),
        _count(_since(true, todayTs)),
        _count(_since(false, todayTs)),
        _count(_since(true, weekTs)),
        _count(_since(false, weekTs)),
        _query(true).orderBy('timestamp', descending: true).limit(8).get(),
        _query(false).orderBy('timestamp', descending: true).limit(8).get(),
      ]);

      openCount.value = results[0] as int;
      finishedCount.value = results[1] as int;
      todayCount.value = (results[2] as int) + (results[3] as int);
      weekCount.value = (results[4] as int) + (results[5] as int);

      final docs = <WebJobCard>[
        ...(results[6] as QuerySnapshot<Map<String, dynamic>>)
            .docs
            .map(WebJobCard.fromDoc),
        ...(results[7] as QuerySnapshot<Map<String, dynamic>>)
            .docs
            .map(WebJobCard.fromDoc),
      ];
      docs.sort((a, b) {
        final ta = a.timestamp?.millisecondsSinceEpoch ?? 0;
        final tb = b.timestamp?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });
      recent.assignAll(docs.take(8));
      lastUpdated.value = DateTime.now();
    } catch (_) {
      error.value = 'Could not load the dashboard';
    } finally {
      loading.value = false;
    }
  }
}
