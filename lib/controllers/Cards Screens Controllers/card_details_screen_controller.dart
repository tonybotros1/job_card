import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CardDetailsController extends GetxController {
  late String customerName =
      'ggggggggggggggggggggggggggggggggggggggggggggggggggggg';

  late String carBrand = 'gg';
  late String carModel = 'gg';
  late String plateNumber = 'gggg';
  late String carMileage =
      'ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggtttttttttttttttttt';
  late String chassisNumber = 'ggggggggggg';
  late String phoneNumber = 'gggggggggg';
  late String emailAddress = 'gggggggg';
  late String color = 'ggggggggg';
  late String date = 'ggggggggg';
  late String id = 'gggggggggg';
  late String video = 'ggggggggggg';
  late bool status = true;
  late String comments = 'gggggggggggg';
  double fuelAmount = 25;
  late String customerSignature = 'gggggggggggg';
  List<String> carImages = [];

  @override
  void onInit() {
    getDetails();
    super.onInit();
  }

// this is for cached images
  final customCachedManeger = CacheManager(
      Config('customCacheKey', stalePeriod: const Duration(days: 3)));

  void getDetails() {
    if (Get.arguments != null) {
      var arguments = Get.arguments;
      customerSignature = arguments.customerSignature;
      customerName = arguments.customerName;
      carImages = arguments.carImages;
      customerName = arguments.customerName;
      carBrand = arguments.carBrand;
      carModel = arguments.carModel;
      plateNumber = arguments.plateNumber;
      carMileage = arguments.carMileage;
      chassisNumber = arguments.chassisNumber;
      comments = arguments.comments;
      phoneNumber = arguments.phoneNumber;
      emailAddress = arguments.emailAddress;
      color = arguments.color;
      fuelAmount = arguments.fuelAmount;
      date = arguments.date;
      id = arguments.docID;
      video = arguments.carVideo;
      status = arguments.status;
    }
    update();
  }

  void changeStatus(stat) {
    status = stat;
    FirebaseFirestore.instance
        .collection('car_card')
        .doc(id)
        .update({"status": stat});
    update();
  }

  void updateMethod() {
    update();
  }
}
