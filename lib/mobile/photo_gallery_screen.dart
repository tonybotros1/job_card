import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../common/image_cache.dart';
import '../web/web_theme.dart';

/// Arguments for [PhotoGalleryScreen]: all photos of the card and the one to start on.
class PhotoGalleryArgs {
  const PhotoGalleryArgs({required this.urls, this.initialIndex = 0, this.captions});
  final List<String> urls;
  final int initialIndex;
  final List<String>? captions;
}

/// Full-screen viewer: swipe left / right between photos, pinch to zoom,
/// rotate, counter in the title. Shows the full-size original.
class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  late final PhotoGalleryArgs args;
  late final PageController _page;
  late int _index;
  final Map<int, double> _rotation = {};

  @override
  void initState() {
    super.initState();
    final a = Get.arguments;
    args = a is PhotoGalleryArgs ? a : const PhotoGalleryArgs(urls: []);
    _index = args.urls.isEmpty ? 0 : args.initialIndex.clamp(0, args.urls.length - 1);
    _page = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = args.urls.length;
    final caption = args.captions != null && _index < args.captions!.length ? args.captions![_index] : null;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const Border(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(total == 0 ? 'Photo' : '${_index + 1} / $total',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            if (caption != null && caption.isNotEmpty)
              Text(caption, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Rotate',
            icon: const Icon(Icons.rotate_right),
            onPressed: () => setState(() => _rotation[_index] = (_rotation[_index] ?? 0) + 1.5707963),
          ),
        ],
      ),
      body: total == 0
          ? const Center(child: Text('No photo', style: TextStyle(color: Colors.white70)))
          : Stack(
              children: [
                PhotoViewGallery.builder(
                  pageController: _page,
                  itemCount: total,
                  onPageChanged: (i) => setState(() => _index = i),
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  loadingBuilder: (context, event) => const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: WebColors.brand),
                    ),
                  ),
                  builder: (context, i) {
                    final url = args.urls[i];
                    return PhotoViewGalleryPageOptions.customChild(
                      child: Transform.rotate(
                        angle: _rotation[i] ?? 0,
                        child: PhotoView(
                          imageProvider: CachedNetworkImageProvider(url, cacheManager: JobCardImageCache.instance),
                          backgroundDecoration: const BoxDecoration(color: Colors.black),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 4,
                        ),
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 4,
                    );
                  },
                ),
                if (total > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('Swipe for the next photo',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
