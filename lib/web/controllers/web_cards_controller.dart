import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/web_job_card.dart';

/// One list (new or finished cards) for the web portal.
///
/// Fast path: the first page is a live query of [pageSize] documents, later
/// pages are fetched on scroll. The full list is downloaded only once a search
/// is typed, then kept in memory so later searches are instant.
class WebCardsController extends GetxController {
  WebCardsController({required this.open});

  /// `true` = new cards (status true), `false` = finished cards.
  final bool open;

  static const pageSize = 48;
  static const _searchDebounce = Duration(milliseconds: 250);
  static const _countInterval = Duration(seconds: 45);
  static const _fallbackAfter = Duration(seconds: 6);

  final cards = <WebJobCard>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;
  final total = RxnInt();
  final error = RxnString();

  final query = ''.obs;
  final searching = false.obs;
  final results = <WebJobCard>[].obs;

  final gridView = true.obs;

  String _userId = '';
  List<DocumentSnapshot<Map<String, dynamic>>> _firstPage = const [];
  final List<DocumentSnapshot<Map<String, dynamic>>> _more = [];
  List<WebJobCard>? _all;
  Future<List<WebJobCard>>? _allLoading;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  Timer? _debounce;
  Timer? _countTimer;
  Timer? _fallback;
  bool _firstSnapshot = true;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _debounce?.cancel();
    _countTimer?.cancel();
    _fallback?.cancel();
    super.onClose();
  }

  Query<Map<String, dynamic>> get _base => FirebaseFirestore.instance
      .collection('car_card')
      .where('user_id', isEqualTo: _userId)
      .where('status', isEqualTo: open)
      .orderBy('timestamp', descending: true);

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    if (_userId.isEmpty) {
      loading.value = false;
      error.value = 'Not signed in';
      return;
    }
    _sub = _base.limit(pageSize).snapshots().listen((snap) {
      _firstPage = snap.docs;
      if (!_firstSnapshot && snap.docChanges.isNotEmpty) {
        // Something changed server-side: the cached full list is stale, and
        // so is the total.
        _all = null;
        _allLoading = null;
        if (query.value.isNotEmpty) _runSearch(query.value);
        refreshCount();
      }
      _firstSnapshot = false;
      if (snap.docs.length < pageSize) hasMore.value = false;
      _publish();
      loading.value = false;
    }, onError: (e) {
      loading.value = false;
      error.value = 'Could not load cards';
    });
    refreshCount();
    // If the live channel is blocked (proxy, extension), the first snapshot
    // never arrives: fetch the first page once so the list still shows.
    _fallback?.cancel();
    _fallback = Timer(_fallbackAfter, () async {
      if (!loading.value || _userId.isEmpty) return;
      try {
        final snap = await _base.limit(pageSize).get(const GetOptions(source: Source.server));
        if (!loading.value) return; // the live snapshot won after all
        _firstPage = snap.docs;
        if (snap.docs.length < pageSize) hasMore.value = false;
        _publish();
        loading.value = false;
      } catch (_) {
        // Keep waiting for the live snapshot.
      }
    });
    // Cards finished or reopened further down the list do not show up in the
    // first page, so the total is also re-read periodically.
    _countTimer?.cancel();
    _countTimer = Timer.periodic(_countInterval, (_) => refreshCount());
  }

  /// Pull-to-refresh: restart from the first page and drop cached pages.
  Future<void> reload() async {
    await _sub?.cancel();
    _sub = null;
    _fallback?.cancel();
    _firstPage = const [];
    _more.clear();
    _all = null;
    _allLoading = null;
    _firstSnapshot = true;
    hasMore.value = true;
    loading.value = true;
    await _start();
  }

  Future<void> refreshCount() async {
    try {
      final agg = await _base.count().get();
      total.value = agg.count;
    } catch (_) {
      // Count is informational; the list still works without it.
    }
  }

  void _publish() {
    final seen = <String>{};
    final merged = <WebJobCard>[];
    for (final doc in [..._firstPage, ..._more]) {
      if (seen.add(doc.id)) merged.add(WebJobCard.fromDoc(doc));
    }
    cards.assignAll(merged);
  }

  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || _userId.isEmpty) return;
    final lastDoc = _more.isNotEmpty
        ? _more.last
        : (_firstPage.isNotEmpty ? _firstPage.last : null);
    if (lastDoc == null) return;
    loadingMore.value = true;
    try {
      final snap = await _base.startAfterDocument(lastDoc).limit(pageSize).get();
      _more.addAll(snap.docs);
      if (snap.docs.length < pageSize) hasMore.value = false;
      _publish();
    } catch (_) {
      error.value = 'Could not load more cards';
    } finally {
      loadingMore.value = false;
    }
  }

  /// Grid is the default on every visit; the table is a per-visit choice.
  void setGridView(bool value) => gridView.value = value;

  /// Called on every keystroke; debounced.
  void onQueryChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) {
      query.value = '';
      results.clear();
      searching.value = false;
      return;
    }
    _debounce = Timer(_searchDebounce, () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    query.value = q;
    searching.value = true;
    try {
      final all = await _loadAll();
      if (query.value != q) return; // superseded by a newer query
      results.assignAll(all.where((c) => c.matches(q)));
    } catch (_) {
      error.value = 'Search failed';
    } finally {
      if (query.value == q) searching.value = false;
    }
  }

  Future<List<WebJobCard>> _loadAll() {
    if (_all != null) return Future.value(_all);
    return _allLoading ??= _base.get().then((snap) {
      _all = snap.docs.map(WebJobCard.fromDoc).toList();
      return _all!;
    });
  }
}
