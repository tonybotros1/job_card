import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

/// A photo in Storage that no card references any more.
class OrphanPhoto {
  OrphanPhoto({required this.path, required this.name, required this.date, required this.folder});

  /// Storage path, e.g. `car_pictures/1791875661752.jpg`.
  final String path;
  final String name;

  /// Top-level folder: `car_pictures`, `customers_signatures` or `car_videos`.
  final String folder;

  bool get isVideo => folder == 'car_videos' || name.toLowerCase().endsWith('.mp4');
  bool get isSignature => folder == 'customers_signatures';

  /// Day the photo was taken, from the millisecond timestamp the app names
  /// photos with; null when the name is not a timestamp.
  final DateTime? date;

  String get dayKey => date == null
      ? ''
      : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';

  /// Thumbnail path the extension / app would have created for it (photos only).
  String? get thumbPath {
    if (folder != 'car_pictures') return null;
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    return 'car_pictures/thumbnails/${stem}_600x600.jpg';
  }
}

/// Finds photos in `car_pictures/` that are not referenced by any card
/// ("old data" left behind when cards were deleted) and deletes the ones the
/// user selects. Scanning only reads; nothing is removed without [deleteSelected].
class WebOrphansController extends GetxController {
  /// Every folder the app writes files to.
  static const folders = ['car_pictures', 'customers_signatures', 'car_videos'];
  static const _pageSize = 1000;

  /// Photos newer than this are not listed: they may belong to a card that is
  /// still being filled in on a phone.
  static const recentGrace = Duration(hours: 24);

  final scanning = false.obs;
  final progress = ''.obs;
  final error = RxnString();
  final scannedAt = Rxn<DateTime>();

  final totalFiles = 0.obs;
  final referencedCount = 0.obs;
  final recentCount = 0.obs;
  final orphans = <OrphanPhoto>[].obs;

  /// Day key -> orphans of that day, newest day first.
  final groups = <MapEntry<String, List<OrphanPhoto>>>[].obs;

  final selected = <String>{}.obs;
  final deleting = false.obs;
  final deletedCount = 0.obs;

  Set<String> _referenced = {};

  Future<void> scan() async {
    if (scanning.value) return;
    scanning.value = true;
    error.value = null;
    selected.clear();
    try {
      progress.value = 'Reading the cards…';
      _referenced = await _loadReferencedPaths();

      progress.value = 'Listing photos in Storage…';
      final found = <OrphanPhoto>[];
      var total = 0;
      var skippedRecent = 0;
      final cutoff = DateTime.now().subtract(recentGrace);
      for (final folder in folders) {
        String? token;
        final root = FirebaseStorage.instance.ref(folder);
        do {
          final ListResult page;
          try {
            page = await root.list(ListOptions(maxResults: _pageSize, pageToken: token));
          } on FirebaseException catch (e) {
            if (e.code == 'object-not-found') break; // folder does not exist
            rethrow;
          }
          for (final item in page.items) {
            total += 1;
            if (_referenced.contains(item.fullPath)) continue;
            final date = _dateFromName(item.name);
            if (date != null && date.isAfter(cutoff)) {
              skippedRecent += 1;
              continue;
            }
            found.add(OrphanPhoto(path: item.fullPath, name: item.name, date: date, folder: folder));
          }
          token = page.nextPageToken;
          progress.value = 'Listing $folder… $total files checked, ${found.length} without a card';
        } while (token != null);
      }

      found.sort((a, b) => (b.date?.millisecondsSinceEpoch ?? 0).compareTo(a.date?.millisecondsSinceEpoch ?? 0));
      totalFiles.value = total;
      referencedCount.value = total - found.length - skippedRecent;
      recentCount.value = skippedRecent;
      orphans.assignAll(found);
      _rebuildGroups();
      scannedAt.value = DateTime.now();
      progress.value = '';
    } on FirebaseException catch (e) {
      error.value = e.code == 'unauthorized' || e.code == 'permission-denied'
          ? 'Storage rules do not allow listing the folders. Add "allow list: if request.auth != null;" to the rules.'
          : 'Scan failed (${e.code})';
    } catch (_) {
      error.value = 'Scan failed';
    } finally {
      scanning.value = false;
    }
  }

  /// Every Storage path referenced by any card (photos and signatures).
  Future<Set<String>> _loadReferencedPaths() async {
    final paths = <String>{};
    final snap = await FirebaseFirestore.instance.collection('car_card').get();
    for (final doc in snap.docs) {
      final d = doc.data();
      final images = d['car_images'];
      if (images is List) {
        for (final url in images) {
          final p = _pathFromUrl(url.toString());
          if (p != null) paths.add(p);
        }
      }
      final sig = d['customer_signature'];
      if (sig is String && sig.isNotEmpty) {
        final p = _pathFromUrl(sig);
        if (p != null) paths.add(p);
      }
    }
    return paths;
  }

  static String? _pathFromUrl(String url) {
    if (url.isEmpty) return null;
    try {
      return FirebaseStorage.instance.refFromURL(url).fullPath;
    } catch (_) {
      return null;
    }
  }

  static DateTime? _dateFromName(String name) {
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final ms = int.tryParse(stem);
    if (ms == null || ms < 1000000000000 || ms > 4102444800000) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _rebuildGroups() {
    final map = <String, List<OrphanPhoto>>{};
    for (final o in orphans) {
      map.putIfAbsent(o.dayKey, () => []).add(o);
    }
    final entries = map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    groups.assignAll(entries);
  }

  void toggle(String path) {
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
  }

  void selectDay(String dayKey, bool select) {
    final paths = orphans.where((o) => o.dayKey == dayKey).map((o) => o.path);
    if (select) {
      selected.addAll(paths);
    } else {
      selected.removeAll(paths);
    }
  }

  void clearSelection() => selected.clear();

  /// Deletes the selected orphans (and their thumbnails) from Storage.
  /// Returns how many originals were deleted.
  Future<int> deleteSelected() async {
    if (deleting.value || selected.isEmpty) return 0;
    deleting.value = true;
    var done = 0;
    final failures = <String>[];
    try {
      final targets = orphans.where((o) => selected.contains(o.path)).toList();
      for (final o in targets) {
        // Belt and braces: never touch a path a card references.
        if (_referenced.contains(o.path)) continue;
        try {
          await FirebaseStorage.instance.ref(o.path).delete();
          done += 1;
          final thumb = o.thumbPath;
          if (thumb != null) {
            try {
              await FirebaseStorage.instance.ref(thumb).delete();
            } catch (_) {
              // No thumbnail for this photo: fine.
            }
          }
          orphans.remove(o);
          selected.remove(o.path);
        } catch (_) {
          failures.add(o.name);
        }
      }
      _rebuildGroups();
      deletedCount.value += done;
      if (failures.isNotEmpty) {
        error.value = '${failures.length} photo(s) could not be deleted';
      }
    } finally {
      deleting.value = false;
    }
    return done;
  }
}
