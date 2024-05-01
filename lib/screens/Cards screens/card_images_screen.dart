import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/card_images_screen_controller.dart';
import '../../const.dart';
import '../../models/image_model.dart';
import '../single_image_viewer.dart';

class CardImagesScreen extends StatelessWidget {
  CardImagesScreen({super.key});
  final CardImagesScreenController cardImagesScreenController =
      Get.put(CardImagesScreenController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Card Images',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: Get.width,
                color: containerColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Images',
                    style: GoogleFonts.mooli(
                        fontSize: 14, color: Colors.grey[900]),
                  ),
                ),
              ),
            ),
            GetBuilder<CardImagesScreenController>(
                init: CardImagesScreenController(),
                builder: (controller) {
                  return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      // padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: controller.carImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: ClipRRect(
                            // borderRadius: BorderRadius.circular(20),
                            child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => SingleImageViewer(),
                                        arguments: ImageModel(
                                            url: controller.carImages[i]));
                                  },
                                  child: CachedNetworkImage(
                                                cacheManager:
                                                    controller
                                                        .customCachedManeger,
                                                progressIndicatorBuilder:
                                                    (context, url, progress) =>
                                                        Padding(
                                                  padding: const EdgeInsets.all(
                                                      30.0),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: progress.progress,
                                                      color: mainColor,
                                                      strokeWidth: 3,
                                                    ),
                                                  ),
                                                ),
                                                imageUrl: controller
                                                    .carImages[i],
                                                key: UniqueKey(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                  // child: Image.network(
                                  //   controller.carImages[i],
                                  //   loadingBuilder: (BuildContext context,
                                  //       Widget child,
                                  //       ImageChunkEvent? loadingProgress) {
                                  //     if (loadingProgress == null) {
                                  //       return child; // Return the actual image if it's already loaded.
                                  //     } else {
                                  //       // Show a loading indicator while the image is loading.
                                  //       return Center(
                                  //         child: Padding(
                                  //           padding: const EdgeInsets.all(30.0),
                                  //           child: CircularProgressIndicator(
                                  //             color: secColor,
                                  //             value: loadingProgress
                                  //                         .expectedTotalBytes !=
                                  //                     null
                                  //                 ? loadingProgress
                                  //                         .cumulativeBytesLoaded /
                                  //                     (loadingProgress
                                  //                             .expectedTotalBytes ??
                                  //                         1)
                                  //                 : null,
                                  //           ),
                                  //         ),
                                  //       );
                                  //     }
                                  //   },
                                  // ),
                                )),
                          ),
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
