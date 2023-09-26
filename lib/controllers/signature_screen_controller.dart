import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class MySignatureController extends GetxController {
  Uint8List? signatureAsImage;

  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  void saveImage(file) async {
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('order_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final UploadTask uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() async {
      final String downloadUrl = await ref.getDownloadURL();

      // FirebaseFirestore.instance.collection('car_card').doc()
    });
  }
}
