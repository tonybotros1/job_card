import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

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

  RxString selectedBrandValue = RxString('');
  RxString selectedColorValue = RxString('');

  RxList<String> carBrandList = RxList<String>([]);
  RxList<String> carColorsList = RxList<String>([]);
  Uint8List? signatureAsImage;
  RxString signatureImageDownloadUrl = RxString('');
  RxBool errorWhileUploading = RxBool(false);

  @override
  void onInit() async {
    readCarBrandsColors();
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

  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  void editValues() async {
    signatureAsImage = await controller.toPngBytes();

    if (signatureAsImage != null) {
      await editSignature();
      FirebaseFirestore.instance
          .collection('car_card')
          .doc(arguments.docID)
          .update({
        "customer_signature": signatureImageDownloadUrl.value,
      });
    }
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


// this function is to edit the signature

  Future<void> editSignature() async {
    try {
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('customers_signatures')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = ref.putData(signatureAsImage!);
      await uploadTask.then((p0) async {
        signatureImageDownloadUrl.value = await ref.getDownloadURL();
      });
    } catch (e) {
      errorWhileUploading.value = true;
    }
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

  // this function is to take the values from the txt files and set them to lists with sorting them
  Future<void> readCarBrandsColors() async {
    final String carBrands =
        await rootBundle.loadString('assets/carBrands.txt');

    final String carColors =
        await rootBundle.loadString('assets/carColors.txt');

    carBrandList.value = carBrands.split('\n')..sort();
    carColorsList.value = carColors.split('\n')..sort();
  }
}
