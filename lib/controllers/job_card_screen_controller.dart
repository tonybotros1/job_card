import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_card/screens/all_works_screen.dart';
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
  Uint8List? signatureAsImage;

  final picker = ImagePicker();
  File? file;

  RxBool uploading = RxBool(false);

  UploadTask? videoUploadTask;

// to check if there error while uploading files
  RxBool errorWhileUploading = RxBool(false);

// to add each image in so i can show it on screen
  RxList<File> imagesList = RxList([]);

  final formKey = GlobalKey<FormState>(); // for the fields validation

  // to get the signature image URL after save it in firebase
  RxString signatureImageDownloadUrl = RxString('');

  // to get the Images URLs after save it in firebase
  RxList<String> carImagesDownloadURL = RxList<String>([]);

  RxBool recorded = RxBool(false);

  @override
  void onInit() {
    customerName.text = 'Customer';
    chassisNumber.text = '';
    emailAddress.text = '';
    phoneNumber.text = '';
    // carModel.text = 'Audi';
    // color.text = 'red';
    // carModel.text = '2022';
    // plateNumber.text = '100';
    // carMileage.text = '0000';

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
  addCard() async {
    signatureAsImage = await controller.toPngBytes();
    if (file != null) {
      await uploadVideo();
    }
    await saveSignatureImage();

    if (imagesList.isNotEmpty) {
      await saveCarImages();
    }
    if (errorWhileUploading.value != true) {
      try {
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
          "editing_time": '',
          "status": true
        }).then((value) {
          uploading.value = false;

          Get.offAll(() => AllWorksScreen());
        });
      } catch (e) {
        errorWhileUploading.value = true;
      }
    }
  }

// for signature:

  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

// for saving signature image in firebase
  saveSignatureImage() async {
    if (errorWhileUploading.value != true) {
      try {
        uploading.value = true;
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
  }

  // this function is to save car images in firebase
  saveCarImages() async {
    if (errorWhileUploading.value != true) {
      try {
        uploading.value = true;
        for (var element in imagesList) {
          final Reference ref = FirebaseStorage.instance
              .ref()
              .child('car_pictures')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          final UploadTask uploadTask = ref.putFile(element);
          await uploadTask.then((p0) async {
            final url = await ref.getDownloadURL();
            carImagesDownloadURL.add(url);
          });
        }
      } catch (e) {
        errorWhileUploading.value = true;
      }
    }
  }

  // function to record video
  void recordVideo() async {
    try {
      final XFile? cameraVideo = await picker.pickVideo(
        source: ImageSource.camera,
      );
      if (cameraVideo != null) {
        file = File(cameraVideo.path);
        recorded.value = true;
      }
    } catch (e) {
//
    }
  }

  // function to save the video in firebase
  uploadVideo() async {
    if (errorWhileUploading.value != true) {
      try {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('car_videos')
            .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
        videoUploadTask = ref.putFile(file!);
        uploading.value = true;

        await videoUploadTask!.then((p0) async {
          videoDownloadUrl.value = await ref.getDownloadURL();
        });
      } catch (e) {
        errorWhileUploading.value = true;
      }
    }
  }

  // this functions is to take photos
  void takePhoto() async {
    try {
      final XFile? cameraImage =
          await picker.pickImage(source: ImageSource.camera);
      if (cameraImage != null) {
        File image = File(cameraImage.path);
        imagesList.add(image);
      }
    } catch (e) {
      //
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
