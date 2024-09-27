import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../const.dart';
import '../../screens/Cards screens/all_works_screen.dart';
import '../../screens/Cards screens/finished_works_screen.dart';
import '../../screens/Cards screens/job_card_screen.dart';

class MainCardScreenController extends GetxController{

 List<Widget> buildScreens() {
    return [
      AllWorksScreen(),
      JobCardScreen(),
      FinishedWorksScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: mainColor,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.add),
        title: ("Add"),
        activeColorPrimary: mainColor,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.domain_verification),
        title: ("Done"),
        activeColorPrimary: mainColor,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }


}