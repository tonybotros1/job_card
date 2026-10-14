import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firestore_rest.dart';
import '../models/web_job_card.dart';

/// One list (new or finished cards) for the web portal.
///
/// Fast path: the first page is a live query of [pageSize] documents, later
/// pages are fetched on scroll.
///
/// Search runs on a light copy of the whole list (search fields only, no
/// photo links, see [FirestoreRest.searchIndex]). On the web it is fetched in
/// the background once the first page shows, and kept in the browser so the
/// next visit can search at once while a fresh copy loads. Full cards are then
/// read only for the results on screen.
///
/// The first page is also read over plain HTTPS ([FirestoreRest]) at the same
/// time, so the list shows whatever the live channel is doing; the live query
/// keeps running and takes over (with real-time updates) once it answers.
class WebCardsController extends GetxController {
  WebCardsController({required this.open});

  /// `true` = new cards (status true), `false` = finished cards.
  final bool open;

  static const pageSize = 48;
  static const _searchDebounce = Duration(milliseconds: 250);
  static const _countInterval = Duration(seconds: 45);
  static const _hydrateBatch = 48;

  final cards = <WebJobCard>[].obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;
  final total = RxnInt();
  final error = RxnString();

  /// What happened while loading, for the "still loading" hint.
  final diag = ''.obs;

  final query = ''.obs;
  final searching = false.obs;
  final results = <WebJobCard>[].obs;

  final gridView = true.obs;

  String _userId = '';
  List<DocumentSnapshot<Map<String, dynamic>>> _firstPage = const [];
  List<WebJobCard> _restPage = const [];
  final List<DocumentSnapshot<Map<String, dynamic>>> _more = [];
  List<WebJobCard>? _index;
  bool _indexFresh = false;
  Future<List<WebJobCard>>? _indexLoading;
  Future<List<WebJobCard>>? _refreshing;
  bool _prefetchStarted = false;
  final Map<String, WebJobCard> _full = {};
  final Set<String> _gone = {};
  int _hydrateLimit = _hydrateBatch;
  bool _hydrating = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  Timer? _debounce;
  Timer? _countTimer;
  int _run = 0;
  bool _firstSnapshot = true;
  DateTime? _startedAt;

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
    super.onClose();
  }

  Query<Map<String, dynamic>> get _base => FirebaseFirestore.instance
      .collection('car_card')
      .where('user_id', isEqualTo: _userId)
      .where('status', isEqualTo: open)
      .orderBy('timestamp', descending: true);

  int get _elapsedMs =>
      _startedAt == null ? 0 : DateTime.now().difference(_startedAt!).inMilliseconds;

  void _note(String what) {
    final t = (_elapsedMs / 1000).toStringAsFixed(1);
    diag.value = diag.value.isEmpty ? '$what at ${t}s' : '${diag.value} · $what at ${t}s';
  }

  Future<void> _start() async {
    final run = ++_run;
    _startedAt = DateTime.now();
    diag.value = '';
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    if (_userId.isEmpty) {
      loading.value = false;
      error.value = 'Not signed in';
      return;
    }
    // Plain HTTPS read of the first page, started together with the live
    // query: whichever answers first fills the list. In some browsers the
    // live channel's first answer takes very long, the HTTPS read does not.
    _readFirstPageOverHttps(run);

    // `?stall=1` in the address skips the live query, to test the HTTPS path.
    final stall = Uri.base.queryParameters['stall'] == '1';
    if (!stall) {
      _sub = _base.limit(pageSize).snapshots().listen((snap) {
        if (run != _run) return;
        if (_firstSnapshot) _note('live page (${snap.docs.length})');
        _firstPage = snap.docs;
        _restPage = const [];
        if (!_firstSnapshot && snap.docChanges.isNotEmpty) {
          // Something changed server-side: the cached full list is stale, and
          // so is the total.
          _indexFresh = false;
          _full.clear();
          _gone.clear();
          if (query.value.isNotEmpty) _refreshIndexQuietly();
          refreshCount();
        }
        _firstSnapshot = false;
        if (snap.docs.length < pageSize) hasMore.value = false;
        _publish();
        loading.value = false;
        _prefetchSearch();
      }, onError: (e) {
        if (run != _run) return;
        _note('live error ${e is FirebaseException ? e.code : e.runtimeType}');
        if (_restPage.isEmpty) {
          loading.value = false;
          error.value = 'Could not load cards';
        }
      });
      _note('live started');
    } else {
      _note('live skipped (stall=1)');
    }
    refreshCount();
    // Cards finished or reopened further down the list do not show up in the
    // first page, so the total is also re-read periodically.
    _countTimer?.cancel();
    _countTimer = Timer.periodic(_countInterval, (_) => refreshCount());
  }

  Future<void> _readFirstPageOverHttps(int run) async {
    _note('https started');
    try {
      final page = await FirestoreRest.firstPage(userId: _userId, open: open, limit: pageSize);
      if (run != _run) return;
      _note('https page (${page.length})');
      if (_firstPage.isNotEmpty) return; // the live page is already shown
      _restPage = page;
      if (page.length < pageSize) hasMore.value = false;
      _publish();
      loading.value = false;
      _prefetchSearch();
    } catch (e) {
      if (run != _run) return;
      _note('https failed ($e)');
    }
  }

  /// Pull-to-refresh / "Try again": restart from the first page and drop
  /// cached pages.
  Future<void> reload() async {
    await _sub?.cancel();
    _sub = null;
    _firstPage = const [];
    _restPage = const [];
    _more.clear();
    _indexFresh = false;
    _full.clear();
    _gone.clear();
    _firstSnapshot = true;
    hasMore.value = true;
    loading.value = true;
    await _start();
  }

  Future<void> refreshCount() async {
    try {
      final agg = await _base.count().get();
      total.value = agg.count;
      if (_startedAt != null && _elapsedMs < 60000 && !diag.value.contains('count')) {
        _note('count ${agg.count}');
      }
    } catch (_) {
      // Count is informational; the list still works without it.
    }
  }

  void _publish() {
    final seen = <String>{};
    final merged = <WebJobCard>[];
    final first = _firstPage.isNotEmpty
        ? _firstPage.map(WebJobCard.fromDoc)
        : _restPage;
    for (final card in first) {
      if (seen.add(card.id)) merged.add(card);
    }
    for (final doc in _more) {
      if (seen.add(doc.id)) merged.add(WebJobCard.fromDoc(doc));
    }
    cards.assignAll(merged);
  }

  Future<void> loadMore() async {
    if (query.value.isNotEmpty) {
      // Scrolling through search results: load the next full cards.
      _hydrateLimit += _hydrateBatch;
      _hydrateVisible();
      return;
    }
    if (loadingMore.value || !hasMore.value || _userId.isEmpty) return;
    final lastDoc = _more.isNotEmpty
        ? _more.last
        : (_firstPage.isNotEmpty ? _firstPage.last : null);
    final lastRest = _restPage.isNotEmpty ? _restPage.last : null;
    if (lastDoc == null && lastRest == null) return;
    loadingMore.value = true;
    try {
      // After the live page: continue from its last document. After the
      // HTTPS page: continue from its last timestamp.
      final q = lastDoc != null
          ? _base.startAfterDocument(lastDoc)
          : (lastRest!.timestamp == null
              ? _base.startAfter([null])
              : _base.startAfter([Timestamp.fromDate(lastRest.timestamp!)]));
      final snap = await q.limit(pageSize).get();
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
      await _ensureIndex();
      if (query.value != q) return; // superseded by a newer query
      _applyQuery(q);
    } catch (_) {
      error.value = 'Search failed';
    } finally {
      if (query.value == q) searching.value = false;
    }
  }

  /// Matches [q] against the search data and shows the results; full cards
  /// already read are used as they are, the rest are read in the background.
  void _applyQuery(String q) {
    final idx = _index;
    if (idx == null || q.isEmpty) return;
    final matched = <WebJobCard>[];
    for (final c in idx) {
      if (_gone.contains(c.id) || !c.matches(q)) continue;
      final full = _full[c.id];
      if (full != null && full.open != open) continue; // moved to the other list
      matched.add(full ?? c);
    }
    results.assignAll(matched);
    _hydrateLimit = _hydrateBatch;
    _hydrateVisible();
  }

  /// Reads the full cards (photos etc.) for the first [_hydrateLimit] results.
  Future<void> _hydrateVisible() async {
    if (_hydrating) return;
    _hydrating = true;
    try {
      while (true) {
        if (query.value.isEmpty) return;
        final ids = <String>[];
        final n = results.length < _hydrateLimit ? results.length : _hydrateLimit;
        for (var i = 0; i < n && ids.length < _hydrateBatch; i++) {
          final c = results[i];
          if (c.partial && !_full.containsKey(c.id) && !_gone.contains(c.id)) ids.add(c.id);
        }
        if (ids.isEmpty) return;
        final got = await FirestoreRest.getCards(ids);
        _full.addAll(got);
        for (final id in ids) {
          if (!got.containsKey(id)) _gone.add(id); // deleted since
        }
        final updated = <WebJobCard>[];
        for (final c in results) {
          if (_gone.contains(c.id)) continue;
          final full = _full[c.id];
          if (full != null && full.open != open) continue;
          updated.add(full ?? c);
        }
        results.assignAll(updated);
      }
    } catch (_) {
      // Rows stay as they are (no photo); opening a card still loads it.
    } finally {
      _hydrating = false;
    }
  }

  /// Starts loading the search data in the background (web only: on phones
  /// it is loaded when search is first used, to save mobile data).
  void _prefetchSearch() {
    if (!kIsWeb || _prefetchStarted || _userId.isEmpty) return;
    _prefetchStarted = true;
    _ensureIndex().then((_) {}, onError: (_) {});
  }

  /// The search data: the copy kept on this device first (instant), then a
  /// fresh copy in the background.
  Future<List<WebJobCard>> _ensureIndex() async {
    final idx = _index;
    if (idx != null) {
      if (!_indexFresh) _refreshIndexQuietly();
      return idx;
    }
    return _indexLoading ??= _loadIndex();
  }

  Future<List<WebJobCard>> _loadIndex() async {
    try {
      final cached = await _readCachedIndex();
      if (cached != null && cached.isNotEmpty) {
        _index = cached;
        _refreshIndexQuietly();
        return cached;
      }
      return await _refreshIndex();
    } finally {
      _indexLoading = null;
    }
  }

  void _refreshIndexQuietly() => _refreshIndex().then((_) {}, onError: (_) {});

  Future<List<WebJobCard>> _refreshIndex() {
    return _refreshing ??= () async {
      try {
        final fresh = await _downloadIndex();
        _index = fresh;
        _indexFresh = true;
        _saveIndex(fresh);
        if (query.value.isNotEmpty) _applyQuery(query.value);
        return fresh;
      } finally {
        _refreshing = null;
      }
    }();
  }

  Future<List<WebJobCard>> _downloadIndex() async {
    try {
      return await FirestoreRest.searchIndex(userId: _userId, open: open);
    } catch (_) {
      // HTTPS read failed: the SDK still works, it just downloads every field.
      final snap = await _base.get();
      return snap.docs.map(WebJobCard.fromDoc).toList();
    }
  }

  String get _cacheKey => 'searchIndex.v1.${open ? 'open' : 'finished'}';

  Future<List<WebJobCard>?> _readCachedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return null;
      final data = jsonDecode(raw);
      if (data is! Map || data['u'] != _userId || data['rows'] is! List) return null;
      return (data['rows'] as List)
          .map((r) => WebJobCard.fromSearchRow(r, open: open))
          .whereType<WebJobCard>()
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveIndex(List<WebJobCard> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'u': _userId,
          'rows': [for (final c in list) c.toSearchRow()],
        }),
      );
    } catch (_) {
      // Browser storage full or blocked: search still works, just not offline.
    }
  }
}
