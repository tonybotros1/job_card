import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/widgets/screen_size_widget.dart';
import 'package:job_card/widgets/side_menu_widgets.dart';

import '../controllers/Widgets controller/side_menu_widget_controller.dart';

class MainScreenForWeb extends StatelessWidget {
  MainScreenForWeb({super.key});

  final SideMenuController menuCon = Get.put(SideMenuController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                ScreenSize.isWeb(context)
                    ? Obx(
                        () => Expanded(
                          flex: menuCon.visible.value ? 2 : 1,
                          child: SideMenuWidget(),
                        ),
                      )
                    : const SizedBox(),
                Obx(
                  () => Expanded(
                      flex: 14,
                      child: menuCon
                          .buildRightContent(menuCon.selectedIndex.value)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
