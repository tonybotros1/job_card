import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class JobCardScreenController extends GetxController {
  var selectedDate = DateTime.now().obs;
  TextEditingController customerName = TextEditingController();
  TextEditingController carBrand = TextEditingController();
  TextEditingController carModel = TextEditingController();
  TextEditingController plateNumber = TextEditingController();
  TextEditingController carMileage = TextEditingController();
  TextEditingController chassisNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController color = TextEditingController();
  RxString theDate = RxString('');
  RxDouble fuelAmount = RxDouble(25);
  RxString videoDownloadUrl = RxString('');

  final picker = ImagePicker();
  File? file;

  late VideoPlayerController player;

  final formKey = GlobalKey<FormState>();
  RxString imageDownloadUrl = RxString('');

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
    await saveImage(signatureAsImage);
    await uploadVideo(file);
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
      "customer_signature": imageDownloadUrl.value,
      "car_video": videoDownloadUrl.value,
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

// for saving images in firebase
  saveImage(file) async {
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('order_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = ref.putData(file);
    await uploadTask.whenComplete(() async {
      imageDownloadUrl.value = await ref.getDownloadURL();
    });
  }

  // function to record video
  recordVideo() async {
    final XFile? cameraVideo =
        await picker.pickVideo(source: ImageSource.camera);
    if (cameraVideo != null) {
      file = File(cameraVideo.path);
    }
    return file;
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
}
