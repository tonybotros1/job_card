import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/card_images_screen_controller.dart';

import '../../mobile/photo_gallery_screen.dart';
import '../../web/web_images.dart';
import '../../web/web_theme.dart';
import '../../web/web_widgets.dart';

/// All photos of a card, grouped by the day they were taken. Thumbnails load
/// here; the full-size photo opens on tap.
class CardImagesScreen extends StatelessWidget {
  CardImagesScreen({super.key});

  final CardImagesScreenController cardImagesScreenController =
      Get.put(CardImagesScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebColors.bg,
      appBar: AppBar(title: const Text('Photos')),
      body: GetBuilder<CardImagesScreenController>(
        init: cardImagesScreenController,
        builder: (controller) {
          if (controller.carImages.isEmpty) {
            return const WebEmptyState(icon: Icons.photo_library_outlined, title: 'No photos');
          }
          if (controller.groupedImages.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: WebColors.brand));
          }
          final keys = controller.groupedImages.keys.toList()..sort((a, b) => b.compareTo(a));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final dateKey = keys[index];
              final images = controller.groupedImages[dateKey] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16, color: WebColors.subtle),
                        const SizedBox(width: 6),
                        Text(
                          fmtDate(DateTime.tryParse(dateKey)).isEmpty
                              ? dateKey
                              : fmtDate(DateTime.tryParse(dateKey)),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text('${images.length}',
                            style: const TextStyle(color: WebColors.subtle, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, i) {
                        final image = images[i];
                        return GestureDetector(
                          onTap: () {
                            // All photos in the order shown, so swiping moves through them.
                            final urls = <String>[];
                            final captions = <String>[];
                            for (final k in keys) {
                              final label = fmtDate(DateTime.tryParse(k)).isEmpty ? k : fmtDate(DateTime.tryParse(k));
                              for (final img in controller.groupedImages[k] ?? []) {
                                urls.add(img.imageUrl);
                                captions.add(label);
                              }
                            }
                            Get.toNamed('/photoGallery',
                                arguments: PhotoGalleryArgs(
                                    urls: urls, initialIndex: urls.indexOf(image.imageUrl), captions: captions));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: WebNetworkImage(url: image.imageUrl, memCacheWidth: 400),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
