import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/main_cards_screen.dart';

class LoadingScreenController extends GetxController {
  @override
  void onInit() async {
    await checkLogStatus();

    super.onInit();
  }

  checkLogStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? action = prefs.getString('devideToken');
    if (action!.isEmpty) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => MainCardsScreen());
    }
  }
}