import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../models/image_date_filter_model.dart';
import '../models/web_job_card.dart';

/// Loads one job card by id and groups its photos by the day they were taken
/// (Storage metadata), the same grouping the mobile app shows.
class WebCardDetailsController extends GetxController {
  WebCardDetailsController(this.id);

  final String id;

  final card = Rxn<WebJobCard>();
  final loading = true.obs;
  final notFound = false.obs;
  final error = RxnString();

  /// Date key (yyyy-MM-dd) -> images, newest day first.
  final groups = <MapEntry<String, List<ImageWithDate>>>[].obs;
  final imagesLoading = false.obs;
  final saving = false.obs;

  DocumentReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection('car_card').doc(id);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final doc = await _ref.get();
      if (!doc.exists) {
        notFound.value = true;
        return;
      }
      card.value = WebJobCard.fromDoc(doc);
      _loadImages(card.value!.carImages);
    } catch (_) {
      error.value = 'Could not load this card';
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadImages(List<String> urls) async {
    if (urls.isEmpty) return;
    imagesLoading.value = true;
    final map = <String, List<ImageWithDate>>{};
    await Future.wait(urls.map((url) async {
      try {
        final meta = await FirebaseStorage.instance.refFromURL(url).getMetadata();
        final created = meta.timeCreated;
        if (created == null) return;
        final key = '${created.year}-${created.month.toString().padLeft(2, '0')}-'
            '${created.day.toString().padLeft(2, '0')}';
        map.putIfAbsent(key, () => []).add(ImageWithDate(imageUrl: url, dateAdded: created));
      } catch (_) {
        // Unreadable metadata: still show the photo under "Other".
        map.putIfAbsent('', () => []).add(
              ImageWithDate(imageUrl: url, dateAdded: DateTime.fromMillisecondsSinceEpoch(0)),
            );
      }
    }));
    final entries = map.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    for (final e in entries) {
      e.value.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
    }
    groups.assignAll(entries);
    imagesLoading.value = false;
  }

  /// Marks the card as new (`true`) or finished (`false`). The only write on
  /// the web portal; the page asks for confirmation first.
  Future<bool> setOpen(bool open) async {
    final current = card.value;
    if (current == null || saving.value) return false;
    saving.value = true;
    try {
      await _ref.update({'status': open});
      final doc = await _ref.get();
      if (doc.exists) card.value = WebJobCard.fromDoc(doc);
      return true;
    } catch (_) {
      error.value = 'Could not update the card';
      return false;
    } finally {
      saving.value = false;
    }
  }
}
