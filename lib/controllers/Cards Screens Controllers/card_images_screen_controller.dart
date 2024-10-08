import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CardImagesScreenController extends GetxController {
  late String customerName;
  List<String> carImages = [];
    OverlayEntry? overlayEntry;
Timer? hoverTimer;
bool isOverlayVisible = false;


  final customCachedManeger = CacheManager(
      Config('customCacheKey', stalePeriod: const Duration(days: 3)));

  @override
  void onInit() {
    getDetails();
    super.onInit();
  }

  void getDetails() {
    if (Get.arguments != null) {
      var arguments = Get.arguments;
      carImages = arguments.carImages;
    }
    update();
  }


  void showFullScreen(BuildContext context, String imageUrl) {
    // تجنب عرض الصورة مجددًا إذا كانت موجودة بالفعل
    if (isOverlayVisible) return;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          onTap: () => removeOverlay(),
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
    isOverlayVisible = true; // يتم عرض الصورة
  }

     void removeOverlay() {
    hoverTimer?.cancel(); // تأكد من إلغاء المؤقت
    overlayEntry?.remove();
    overlayEntry = null;
    isOverlayVisible = false; // تم إزالة الصورة
  }
}
