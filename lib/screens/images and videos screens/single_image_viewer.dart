import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SingleImageViewer extends StatelessWidget {
  SingleImageViewer({super.key});

  final argument = Get.arguments;

  @override
  Widget build(BuildContext context) {
    CachedNetworkImageProvider cachedImageProvider = CachedNetworkImageProvider(argument.url);

    return Scaffold(
      body: PhotoView(imageProvider: cachedImageProvider),
    );
  }
}
