import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class SingleImageViewer extends StatelessWidget {
  SingleImageViewer({super.key});

  final argument = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(imageProvider: NetworkImage(argument.url)),
    );
  }
}
