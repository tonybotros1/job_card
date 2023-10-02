import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;

class JobCardScreenController extends GetxController {
  var selectedDate = DateTime.now().obs;
  TextEditingController customerName = TextEditingController();
  TextEditingController carBrand = TextEditingController();
  RxString selectedBrandValue = RxString('');
  TextEditingController carModel = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController carMileage = TextEditingController();
  TextEditingController chassisNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController color = TextEditingController();
  RxString selectedColorValue = RxString('');
  RxString theDate = RxString('');
  RxDouble fuelAmount = RxDouble(25);
  RxString videoDownloadUrl = RxString('');
  RxList<String> carBrandList = RxList<String>([]);
  RxList<String> carColorsList = RxList<String>([]);

  final picker = ImagePicker();
  File? file;

  RxList<File> imagesList =
      RxList([]); // to add each image in so i can show it on screen

  final formKey = GlobalKey<FormState>(); // for the fields validation
  RxString signatureImageDownloadUrl =
      RxString(''); // to get the signature image URL after save it in firebase
  RxList<String> carImagesDownloadURL =
      RxList<String>([]); // to get the Images URLs after save it in firebase

  RxBool recorded = RxBool(false);

  @override
  void onInit() {
    customerName.text = 'Customer';
    chassisNumber.text = '';
    emailAddress.text = '';
    phoneNumber.text = '';
    readCarBrandsColors();
    super.onInit();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> selectDateContext(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate.value) {
      selectDate(picked);
    }
  }

  // Function to format the date
  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    theDate.value = formatter.format(date);
    return formatter.format(date);
  }

// this function is to add the car card when all informations addedd
  void addCard() async {
    signatureAsImage = await controller.toPngBytes();
    await saveSignatureImage(signatureAsImage);
    await saveCarImages();
    if (file != null) {
      await uploadVideo(file);
    }
    FirebaseFirestore.instance.collection('car_card').add({
      "customer_name": customerName.text,
      "car_brand": carBrand.text,
      "car_model": carModel.text,
      "plate_number": plateNumber.text,
      "car_mileage": carMileage.text,
      "chassis_number": chassisNumber.text,
      "phone_number": phoneNumber.text,
      "email_address": emailAddress.text,
      "color": color.text,
      "date": theDate.value,
      "fuel_amount": fuelAmount.value,
      "customer_signature": signatureImageDownloadUrl.value,
      "car_video": videoDownloadUrl.value,
      "car_images": carImagesDownloadURL,
      "timestamp": FieldValue.serverTimestamp(),
      "editing_time": ''
    });
  }

// for signature:
  Uint8List? signatureAsImage;

  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

// for saving signature image in firebase
  saveSignatureImage(file) async {
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('customers_signatures')
        .child(
            '${customerName.value}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = ref.putData(file);
    await uploadTask.whenComplete(() async {
      signatureImageDownloadUrl.value = await ref.getDownloadURL();
    });
  }

  // this function is to save car images in firebase

  saveCarImages() async {
    for (var element in imagesList) {
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('car_pictures')
          .child(
              '${customerName.value}_${carBrand.value}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final UploadTask uploadTask = ref.putFile(element);
      await uploadTask.whenComplete(() async {
        final url = await ref.getDownloadURL();
        carImagesDownloadURL.add(url);
      });
    }
  }

  // function to record video
  void recordVideo() async {
    final XFile? cameraVideo = await picker.pickVideo(
      source: ImageSource.camera,
    );
    if (cameraVideo != null) {
      file = File(cameraVideo.path);
      recorded.value = true;
    }
  }

  // function to save the video in firebase
  uploadVideo(video) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('order_videos')
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
    final UploadTask uploadTask = ref.putFile(video);
    await uploadTask.whenComplete(() async {
      videoDownloadUrl.value = await ref.getDownloadURL();
    });
  }

  // this functions is to take photos
  void takePhoto() async {
    final XFile? cameraImage =
        await picker.pickImage(source: ImageSource.camera);
    if (cameraImage != null) {
      File image = File(cameraImage.path);
      imagesList.add(image);
    }
  }

  // this function to remove recorded video
  void removeVideo() {
    file = null;
    update();
  }
// this function is to takr the values from the txt files and set them to lists with sorting them
  Future<void> readCarBrandsColors() async {
    final String carBrands =
        await rootBundle.loadString('assets/carBrands.txt');

    final String carColors =
        await rootBundle.loadString('assets/carColors.txt');

    carBrandList.value = carBrands.split('\n')..sort();
    carColorsList.value = carColors.split('\n')..sort();
  }
}
