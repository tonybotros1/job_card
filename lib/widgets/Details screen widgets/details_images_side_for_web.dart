import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../controllers/Cards Screens Controllers/card_images_screen_controller.dart';

GetBuilder<CardImagesScreenController> detailsImagesSide() {
  return GetBuilder<CardImagesScreenController>(
    init: CardImagesScreenController(),
    builder: (controller) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.carImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    controller.showFullScreen(
                          context, controller.carImages[i]);
                  },
                  child: CachedNetworkImage(
                    cacheManager: controller.customCachedManeger,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                          color: mainColor,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    imageUrl: controller.carImages[i],
                    key: UniqueKey(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
