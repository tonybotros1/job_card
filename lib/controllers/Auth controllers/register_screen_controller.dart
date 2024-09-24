import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  late TextEditingController email = TextEditingController();
  late TextEditingController pass = TextEditingController();
  late TextEditingController name = TextEditingController();

  List<String> areaName = [];
  String selectedAreaValue='';

  @override
  void onInit() {
    readAreasNames();
    super.onInit();
  }

  void readAreasNames() async {
    
        await FirebaseFirestore.instance.collection('area').get().then((value) {
      for (var element in value.docs) {
        areaName.add(element.data()['area name']);
      }
    });
  }

  register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );
      User? user = userCredential.user;
      String? token;
      String? uid;
      if (user != null) {
        token = await FirebaseMessaging.instance.getToken();
        uid = user.uid;
       
      }
      FirebaseFirestore.instance.collection('users').add({
        "email": email.text,
        "name": name.text,
        "user_id": uid,
        "users_tokens": [token]
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
      }
    } catch (e) {
      // print(e);
    }
  }
}
