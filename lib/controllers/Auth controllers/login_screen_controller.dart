import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/Cards screens/main_cards_screen.dart';

class LoginScreenController extends GetxController {
  late TextEditingController email = TextEditingController();
  late TextEditingController pass = TextEditingController();
  late String currentUserToken;
  late String userId;
  bool obscureText = true;
  RxBool sigingInProcess = RxBool(false);
  @override
  void onInit() {
    // myTest();

    super.onInit();
  }

  // myTest() {
  //   FirebaseFirestore.instance.collection('car_card').get().then((value) {
  //     for (var element in value.docs) {
  //       print(element.data()['user_id']);

  //       //  FirebaseFirestore.instance
  //       //       .collection('car_card')
  //       //       .doc(element.id)
  //       //       .update({"user_id": 'U9NX17IjbmQD0x27TV8x09YkoXH3'});
  //     }
  //   });

  //   // print(docs);
  // }

// this function is to change the obscureText value:
  void changeObscureTextValue() {
    if (obscureText == true)
      obscureText = false;
    else
      obscureText = true;

    update();
  }

// this function is to show a snackbae with the state of the login process:
  void showSnackBar(title, body) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.grey,
      colorText: Colors.white,
    );
  }

  // this function to save the token for the user device in DB:
  saveToken(userId) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // Get the document ID of the first document (assuming there's only one match)
      String documentId = userSnapshot.docs.first.id;
      print('Document ID: $documentId');
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      var tokens = userData['users_tokens'];

      currentUserToken = (await FirebaseMessaging.instance.getToken())!;

      if (!tokens.contains(currentUserToken)) {
        tokens.add(currentUserToken);
        FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'users_tokens': tokens});
      }
    }
  }

  saveTokenInSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceToken', currentUserToken);
    await prefs.setString('userId', userId);
    // final String? action = prefs.getString('devideToken');
  }

// this function is to sigin in
  void singIn() async {
    try {
      sigingInProcess.value = true;

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );
      User? user = userCredential.user;

      // Get the user ID
      userId = user!.uid;
      await saveToken(userId);
      await saveTokenInSharedPref();
      sigingInProcess.value = false;
      showSnackBar('Login Success', 'Welcome');
      Get.offAll(() => MainCardsScreen());
    } on FirebaseAuthException catch (e) {
      sigingInProcess.value = false;

      if (e.code == 'invalid-email') {
        print('No user found for that email.');

        showSnackBar('Wrong Email', 'This Email is not registed');
      } else if (e.code == 'invalid-credential') {
        print('Wrong password provided for that user.');
        showSnackBar('Wrong Email or Password',
            'Please recheck your Email and Password then try again');
      } else {
        print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee ${e.code}');
        showSnackBar('Unexpected Error', 'Please try again');
      }
    }
  }
}
