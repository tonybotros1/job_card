import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CardImagesScreenController extends GetxController {
  late String customerName;
  List<String> carImages = [];

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
}
