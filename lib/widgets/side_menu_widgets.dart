import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../const.dart';
import '../controllers/Widgets controller/side_menu_widget_controller.dart';
import 'side_menu_data.dart';

class SideMenuWidget extends StatelessWidget {
  SideMenuWidget({super.key, required menuCon});

  final SideMenuController menuCon = Get.put(SideMenuController());

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 10),
      color: mainColorForWeb,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => menuCon.shrink(),
                icon: Icon(
                  menuCon.visible.value
                      ? Icons.menu_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: iconColor,
                ),
              ),
            ),
          ),
          verticalSpace(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: data.menu.length,
            itemBuilder: (context, index) => Obx(
              () => buildMenuEntry(data, index),
            ),
          ),
          const Spacer(),
          FittedBox(
            child: TextButton(
              onPressed: () {},
              child: menuCon.visible.value
                  ? const Text(
                      'LOGOUT',
                      style: TextStyle(color: Colors.redAccent),
                    )
                  : const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = menuCon.selectedIndex.value == index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(50.0),
            ),
            color: isSelected ? menuSelectionColor : Colors.transparent,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: InkWell(
              onTap: () => menuCon.updateSelectedIndex(index),
              child: Row(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    child: Icon(
                      data.menu[index].icon,
                      color: isSelected ? backgroundColor2 : iconColor,
                    ),
                  ),
                  Visibility(
                    visible: menuCon.visible.value,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Text(
                        data.menu[index].title,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? backgroundColor2 : iconColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
