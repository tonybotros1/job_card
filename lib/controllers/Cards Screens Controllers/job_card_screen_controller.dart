import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:job_card/screens/Cards%20screens/main_cards_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

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
  UploadTask? addedImagesUploadTask;

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
  RxString userId = RxString('');
  RxString currentUserToken = RxString('');
  RxList tokens = RxList([]);
  @override
  void onInit() async {
    await getUserId();
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

  // this function is to get user id:
  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = (await prefs.getString('userId'))!;
  }

  // this function is to clear the fields
  void clearFields() {
    customerName.text = 'Customer';
    carBrand.text = '';
    carModel.text = '';
    plateNumber.text = '';
    carMileage.text = '';
    chassisNumber.text = '';
    phoneNumber.text = '';
    emailAddress.text = '';
    color.text = '';
    signatureAsImage = null;
    imagesList.clear();
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
    // uploading.value = true;

    signatureAsImage = await controller.toPngBytes();

    if (imagesList.isNotEmpty) {
      await saveCarImages();
    }
    if (file != null) {
      await uploadVideo();
    }
    if (signatureAsImage != null) {
      await saveSignatureImage();
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
          "status": true,
          "user_id": userId.value,
        }).then((value) async {
          uploading.value = false;

          Get.offAll(() => MainCardsScreen());
          await getUserTokens();
          // send the notifications:
          if (tokens.isNotEmpty) {
            for (var element in tokens) {
              await sendNotifications('New Card Added!',
                  '${carBrand.text} ${carModel.text}', '$element');
            }
          }
        });
      } catch (e) {
        errorWhileUploading.value = true;
      }
    }
  }

// this function is to send Notifications:
  sendNotifications(title, bodyText, token) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAAkEOveI:APA91bGTlKdPoq_5Epeb2aId1krrQ1_UtbqizlbtI4b2ZkP4M_1wng9L6U52Rr8-AX1ZHAyOYi5vIF5pi_BCqkub97aY0yxOdJIeVqqkoam7Bz2Lrtp0pomFtihBdeqDxIgdWdUfnsFd'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": token,
      "notification": {
        "title": title,
        "body": bodyText,
        "mutable_content": true,
        "sound": "Tri-tone"
      },
      "data": {
        "url": "<url of media image>",
        "dl": "<deeplink action on tap of notification>"
      }
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
  }

// this function is to get users tokens to send them notifications:
  getUserTokens() async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Get the document ID of the first document (assuming there's only one match)
      String documentId = userSnapshot.docs.first.id;
      print('Document ID: $documentId');
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      tokens = userData['users_tokens'];
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
        // uploading.value = true;
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
          addedImagesUploadTask = ref.putFile(element);
          await addedImagesUploadTask!.then((p0) async {
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
