import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/Cards screens/all_works_screen.dart';
import '../../screens/Cards screens/finished_works_screen.dart';
import '../../screens/auth/loading_screen.dart';

class SideMenuController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool visible = true.obs;

  void updateSelectedIndex(int index) => selectedIndex.value = index;

  Widget buildRightContent(int index) {
    switch (index) {
      case 0:
        return  AllWorksScreen();
      case 1:
        return FinishedWorksScreen();
      // case 2:
      //   return FinishedWorksScreen();
      // case 2:
      //   return  const PatientArchiveView();
      default:
        return const Text('4');
    }
  }

  void shrink() {
    if (visible.value) {
      visible.value = false;
    } else {
      visible.value = true;
    }
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }

  // this function is to logout from app:
  void logOut() async {
    await FirebaseAuth.instance.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceToken', '');
    await prefs.setString('userId', '');
    Get.offAll(() => const LoadingScreen());
  }
}
