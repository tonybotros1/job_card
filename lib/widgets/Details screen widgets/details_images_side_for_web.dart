import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_card/widgets/screen_size_widget.dart';

import '../../const.dart';
import '../../controllers/Cards Screens Controllers/card_images_screen_controller.dart';
import '../../models/image_model.dart';

GetBuilder<CardImagesScreenController> detailsImagesSide() {
  return GetBuilder<CardImagesScreenController>(
    init: CardImagesScreenController(),
    builder: (controller) {
      return controller.groupedImages.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.groupedImages.keys.length,
              itemBuilder: (context, index) {
                final dateKey = controller.groupedImages.keys.elementAt(index);
                final images = controller.groupedImages[dateKey] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date: $dateKey',
                          style: GoogleFonts.mooli(
                              fontSize: 14,
                              color: Colors.grey[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ScreenSize.isWeb(context)
                                ? 6
                                : ScreenSize.isNotWeb(context)
                                    ? 4
                                    : ScreenSize.isMobile(context)
                                        ? 3
                                        : 2,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, i) {
                            final image = images[i];
                            return Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      onTap: () {
                                        // controller.showFullScreen(
                                        //     context, image.imageUrl);
                                        Get.toNamed('/singleImageViewer',
                                            arguments: ImageModel(
                                                url: image.imageUrl));
                                      },
                                      child: CachedNetworkImage(
                                        cacheManager:
                                            controller.customCachedManeger,
                                        progressIndicatorBuilder:
                                            (context, url, progress) => Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: progress.progress,
                                              color: mainColor,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                        imageUrl: image.imageUrl,
                                        key: UniqueKey(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: CircularProgressIndicator(
                  color: mainColor,
                ),
              ),
            );
    },
  );
}
