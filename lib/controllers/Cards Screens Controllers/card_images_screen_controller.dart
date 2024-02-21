import 'package:get/get.dart';

class CardImagesScreenController extends GetxController {
  late String customerName;
  List<String> carImages = [];

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
