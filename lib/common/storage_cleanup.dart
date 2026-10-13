import 'package:firebase_storage/firebase_storage.dart';

/// Removes files from Storage when their card or photo is deleted, so no
/// "old data" is left behind.
class StorageCleanup {
  static const thumbFolder = 'thumbnails';
  static const thumbSize = '600x600';

  /// Deletes the file behind a download URL and its thumbnail, if any.
  /// Errors are ignored: the file may already be gone.
  static Future<void> deleteByUrl(String url) async {
    if (url.isEmpty) return;
    Reference ref;
    try {
      ref = FirebaseStorage.instance.refFromURL(url);
    } catch (_) {
      return;
    }
    try {
      await ref.delete();
    } catch (_) {
      // already deleted or not ours
    }
    final name = ref.name;
    final dot = name.lastIndexOf('.');
    final stem = dot > 0 ? name.substring(0, dot) : name;
    final parent = ref.parent;
    if (parent == null) return;
    try {
      await parent.child(thumbFolder).child('${stem}_$thumbSize.jpg').delete();
    } catch (_) {
      // no thumbnail
    }
  }

  /// Deletes every file a card document points to (photos, signature, video).
  static Future<void> deleteCardFiles(Map<String, dynamic> card) async {
    final urls = <String>[];
    final images = card['car_images'];
    if (images is List) urls.addAll(images.map((e) => e.toString()));
    for (final key in ['customer_signature', 'car_video']) {
      final v = card[key];
      if (v is String && v.isNotEmpty) urls.add(v);
    }
    for (final url in urls) {
      await deleteByUrl(url);
    }
  }
}
