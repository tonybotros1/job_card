import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Photos straight from the camera are 3-5 MB. For a job card a 2000 px JPEG
/// is indistinguishable and 5-10x smaller, so uploads and the viewer get
/// much faster and Storage stays small. Falls back to the original bytes if
/// compression fails.
class ImageUpload {
  static const maxSide = 2000;
  static const quality = 85;

  static Future<Uint8List> compressForUpload(File photo) async {
    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        photo.absolute.path,
        minWidth: maxSide,
        minHeight: maxSide,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (bytes != null && bytes.isNotEmpty) return bytes;
    } catch (_) {
      // fall through
    }
    return photo.readAsBytes();
  }
}
