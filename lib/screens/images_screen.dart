import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/controllers/edit_card_screen_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagesScreen extends StatelessWidget {
  ImagesScreen({super.key});

  final EditCardScreenController editCardScreenController =
      Get.put(EditCardScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: editCardScreenController.carImages.length,
        builder: (context, j) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(editCardScreenController.carImages[j]),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(
                tag: editCardScreenController.carImages[j]),
          );
        },
        loadingBuilder: (context, event) => const Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
