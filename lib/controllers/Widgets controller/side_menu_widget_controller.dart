import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/Cards screens/all_works_screen.dart';
import '../../screens/Cards screens/finished_works_screen.dart';

class SideMenuController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool visible = true.obs;

  void updateSelectedIndex(int index) => selectedIndex.value = index;

  Widget buildRightContent(int index) {
    switch (index) {
      case 0:
        return AllWorksScreen();
      case 1:
        return  FinishedWorksScreen();
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
}
