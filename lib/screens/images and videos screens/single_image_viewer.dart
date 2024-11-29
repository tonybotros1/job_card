import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SingleImageViewer extends StatelessWidget {
  SingleImageViewer({super.key});

  final argument = Get.arguments;
  final ValueNotifier<double> _rotationNotifier = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    CachedNetworkImageProvider cachedImageProvider =
        CachedNetworkImageProvider(argument.url);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body:
          // PhotoView(
          //   imageProvider: cachedImageProvider,
          //   minScale: PhotoViewComputedScale.contained,
          //   maxScale: PhotoViewComputedScale.covered * 4,
          // ),
          Stack(
        children: [
          Center(
            child: ValueListenableBuilder<double>(
              valueListenable: _rotationNotifier,
              builder: (context, rotation, child) {
                return Transform.rotate(
                  angle: rotation,
                  child: PhotoView(
                    imageProvider: cachedImageProvider,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                _rotationNotifier.value += 3.14159 / 2;
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.rotate_right,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
