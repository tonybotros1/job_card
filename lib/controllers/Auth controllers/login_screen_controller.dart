import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/messenger.dart';


class LoginScreenController extends GetxController {
  late TextEditingController email = TextEditingController();
  late TextEditingController pass = TextEditingController();
  final FocusNode focusNode = FocusNode(); // To keep track of focus

  late String currentUserToken = '';
  late String userId;
  RxBool obscureText = RxBool(true);
  RxBool sigingInProcess = RxBool(false);

  var width = Get.width;
  var height = Get.height;

  var isPermissionGranted = false.obs; // حالة الإذن

  @override
  void onInit() {
    // myTest();
    checkPermission();
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
    if (obscureText.value == true) {
      obscureText.value = false;
    } else {
      obscureText.value = true;
    }
  }

// this function is to show a snackbae with the state of the login process:
  void showSnackBar(title, body) {
    if (kIsWeb) {
      showAppBanner('$title', '$body');
      return;
    }
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
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
      // print('Document ID: $documentId');
      var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
      final tokens = userData['users_tokens'] is List ? List<dynamic>.from(userData['users_tokens']) : <dynamic>[];

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      currentUserToken = token;

      if (!tokens.contains(currentUserToken)) {
        tokens.add(currentUserToken);
        await FirebaseFirestore.instance
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
      if (kIsWeb) {
        // The portal has no push: the stored value only marks the session as
        // signed in. Asking the browser for a push token here can return null
        // (permission blocked, incognito) and would leave the button spinning.
        currentUserToken = 'web';
      } else {
        try {
          await saveToken(userId);
        } catch (_) {
          // Push registration is best effort; PushToken.sync retries at start.
          currentUserToken = currentUserToken.isEmpty ? 'pending' : currentUserToken;
        }
      }
      await saveTokenInSharedPref();
      sigingInProcess.value = false;
      // On the web the route change below unmounts the overlay the snackbar
      // needs, so the welcome toast is mobile-only.
      if (!kIsWeb) showSnackBar('Login Success', 'Welcome');
      Get.offAllNamed('/mainCardsScreen');
    } on FirebaseAuthException catch (e) {
      sigingInProcess.value = false;

      if (e.code == 'invalid-email') {
        // print('No user found for that email.');

        showSnackBar('Wrong Email', 'This Email is not registed');
      } else if (e.code == 'invalid-credential') {
        // print('Wrong password provided for that user.');
        showSnackBar('Wrong Email or Password',
            'Please recheck your Email and Password then try again');
      } else {
        // print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee ${e.code}');
        showSnackBar('Unexpected Error', 'Please try again');
      }
    } catch (_) {
      // Never leave the button spinning.
      sigingInProcess.value = false;
      showSnackBar('Unexpected Error', 'Please try again');
    }
  }

  Future<void> checkPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();

    // تحقق مما إذا كانت الإشعارات مُفعلة بالفعل
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      isPermissionGranted.value = true;
    } else {
      requestPermission();
    }
  }

// this function is to order permission from users
  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // إذا تم رفض الإذن
      isPermissionGranted.value = false;
      _showPermissionDeniedDialog();
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // الإذن مُعطى
      isPermissionGranted.value = true;
    } else {
      // Not determined (prompt dismissed) or provisional: do not ask again in a
      // loop - the user can retry from the dialog or the browser settings.
      isPermissionGranted.value = false;
    }
  }

// this function to show dialog if the user denided the permission
  void _showPermissionDeniedDialog() {
    Get.defaultDialog(
      title: "Notifications are off",
      middleText:
          "Allow notifications so you hear about new job cards. You can change this in the system settings.",
      textConfirm: "Try again",
      textCancel: "Close",
      onConfirm: () {
        requestPermission(); // إعادة محاولة طلب الإذن
        Get.back(); // إغلاق مربع الحوار
      },
      onCancel: () {
        Get.back(); // إغلاق مربع الحوار
      },
    );
  }
}
