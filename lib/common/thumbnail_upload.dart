import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'image_cache.dart';

/// Uploads a 600x600-bounded thumbnail next to a photo the app has just
/// stored, at the path the portal looks for:
///   `car_pictures/<name>.jpg` -> `car_pictures/thumbnails/<name>_600x600.jpg`
///
/// The `resizedImage` metadata marks the file the way the Firebase "Resize
/// Images" extension marks its own output, so the extension leaves it alone
/// instead of resizing the thumbnail again.
///
/// Failures are swallowed: the card is saved with the original photo either
/// way, and the portal falls back to the original when no thumbnail exists.
class ThumbnailUpload {
  static const folder = 'thumbnails';
  static const size = 600;
  static const quality = 80;

  static Future<void> forPhoto(Reference original, File photo) async {
    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        photo.absolute.path,
        minWidth: size,
        minHeight: size,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (bytes == null || bytes.isEmpty) return;

      final name = original.name;
      final dot = name.lastIndexOf('.');
      final base = dot > 0 ? name.substring(0, dot) : name;
      final parent = original.parent;
      final thumbRef = (parent ?? FirebaseStorage.instance.ref())
          .child(folder)
          .child('${base}_${size}x$size.jpg');

      await thumbRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: JobCardImageCache.cacheControlHeader,
          customMetadata: const {'resizedImage': 'true'},
        ),
      );
    } catch (_) {
      // Thumbnail is an optimisation only.
    }
  }
}
