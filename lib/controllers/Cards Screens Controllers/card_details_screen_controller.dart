import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CardDetailsController extends GetxController {
  late String customerName;

  late String carBrand;
  late String carModel;
  late String plateNumber;
  late String carMileage;
  late String chassisNumber;
  late String phoneNumber;
  late String emailAddress;
  late String color;
  late String date;
  late String id;
  late String video;
  late bool status;
  late String comments;
  double fuelAmount = 25;
  late String customerSignature;
  List<String> carImages = [];

  @override
  void onInit() {
    getDetails();
    super.onInit();
  }

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
