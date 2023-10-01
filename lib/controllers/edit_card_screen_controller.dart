import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCardScreenController extends GetxController {
  TextEditingController customerName = TextEditingController();
  TextEditingController carBrand = TextEditingController();
  TextEditingController carModel = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController carMileage = TextEditingController();
  TextEditingController chassisNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController color = TextEditingController();
  RxDouble fuelAmount = RxDouble(25);
  RxString customerSignature = RxString('');
  var arguments = Get.arguments;
  // late VideoPlayerController controller;
  RxList<String> carImages = RxList<String>([]);

  @override
  void onInit() async {
    await setValuesToFields();
    super.onInit();
  }

  @override
  void onClose() {
    // controller.dispose();
    super.onClose();
  }

  // this function is to give the fields the values when i want to edit the selected car card
  setValuesToFields() {
    if (Get.arguments == null) {
    } else {
      customerSignature.value = arguments.customerSignature;
      carImages.value = arguments.carImages;
      customerName.text = arguments.customerName;
      carBrand.text = arguments.carBrand;
      carModel.text = arguments.carModel;
      plateNumber.text = arguments.plateNumber;
      carMileage.text = arguments.carMileage;
      chassisNumber.text = arguments.chassisNumber;
      phoneNumber.text = arguments.phoneNumber;
      emailAddress.text = arguments.emailAddress;
      color.text = arguments.color;
      fuelAmount.value = arguments.fuelAmount;
      // controller =
      //     VideoPlayerController.networkUrl(Uri.parse('${arguments.carVideo}'));
      // controller.addListener(() {
      //   update();
      // });
      // // controller.setLooping(true);
      // controller.initialize().then((_) {
      //   controller.play();
      //   update();
      // });
    }
  }

  void editValues() {
    FirebaseFirestore.instance
        .collection('car_card')
        .doc(arguments.docID)
        .update({
      "customer_name": customerName.text,
      "car_brand": carBrand.text,
      "car_model": carModel.text,
      "plate_number": plateNumber.text,
      "car_mileage": carMileage.text,
      "chassis_number": chassisNumber.text,
      "phone_number": phoneNumber.text,
      "email_address": emailAddress.text,
      "color": color.text,
      "fuel_amount": fuelAmount.value,
      "editing_time": FieldValue.serverTimestamp(),
      "car_images": carImages
    });
  }

// this function is to delete cards
  void deleteCard() {
    FirebaseFirestore.instance
        .collection('car_card')
        .doc(arguments.docID)
        .delete();
  }

  // this functios is to remove images from the imagesList
  void removeImage(i) {
    carImages.remove(i);
    update();
  }

  // // this function is to delete image from firebase
  // void deleteImage(image) async {
  //   final DocumentSnapshot documentSnapshot =
  //       await FirebaseFirestore.instance.collection('car_card').doc(arguments.docID).get();
  //   if (documentSnapshot.exists) {
  //     final Map<String, dynamic>? data =
  //         documentSnapshot.data() as Map<String, dynamic>?;
  //     if (data != null) {
  //       final List<dynamic> imagesList = data['car_images'];
  //       imagesList.remove(image);

  //       // Now, update the document with the modified list
  //       await FirebaseFirestore.instance.collection('car_card').doc(arguments.docID).update({
  //         'car_images': imagesList,
  //       });
  //     }
  //   }
  // }
}
