import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/all_works_screen_controller.dart';
import 'package:job_card/widgets/card%20style%20widgets/car_card_style_for_web.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../widgets/card style widgets/car_card_style_for_mobile.dart';
import '../../widgets/screen_size_widget.dart';
import '../../widgets/Side menu widgets/side_menu_widgets.dart';

class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});
  final AllWorksController allWorksController = Get.put(AllWorksController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: kIsWeb
            ? ScreenSize.isNotWeb(context)
                ? SizedBox(
                    width: ScreenSize.isMobile(context) ? 100 : 180,
                    child: SideMenuWidget(),
                  )
                : null
            : null,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: kIsWeb
              ? ScreenSize.isNotWeb(context)
                  ? Builder(builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: iconColor,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    })
                  : null
              : IconButton(
                  onPressed: () {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                              title: const Text('Alert'),
                              content: const Text(
                                  'Are you sure you want to Logout?'),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'No',
                                    style: TextStyle(color: mainColor),
                                  ),
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    allWorksController.logOut();
                                    Get.offAllNamed('/loginScreen');
                                  },
                                )
                              ],
                            ));
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  )),
          automaticallyImplyLeading: false,
          title: kIsWeb
              ? Row(
                  children: [
                    Image.asset(
                      'assets/logo2.png',
                      width: 40,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const AutoSizeText(
                      'Compass Automatic Gear',
                      style: TextStyle(color: iconColor),
                    ),
                  ],
                )
              : const Text(
                  'New Cards',
                  style: TextStyle(color: Colors.white),
                ),
          centerTitle: kIsWeb ? false : true,
          backgroundColor: kIsWeb ? mainColorForWeb : mainColor,
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                },
                icon: const Icon(
                  Icons.search,
                  color: kIsWeb ? iconColor : Colors.white,
                )),
            kIsWeb
                ? const SizedBox(
                    width: 20,
                  )
                : const SizedBox(),
          ],
        ),
        body: GetX<AllWorksController>(
            init: AllWorksController(),
            builder: (controller) {
              if (controller.carCards.isEmpty) {
                return LiquidPullToRefresh(
                  onRefresh: () => controller.getAllWorks(),
                  color: mainColor,
                  // backgroundColor: secColor,
                  animSpeedFactor: 2,
                  height: 300,
                  showChildOpacityTransition: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'No Cards Yet',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                                fontSize: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return kIsWeb
                    ? carCardStyleForMWeb(
                        controller: controller,
                        listName: controller.carCards,
                        color: const Color.fromARGB(255, 50, 212, 56),
                        // color: const Color.fromARGB(255, 177, 250, 189),
                        status: 'New')
                    : LiquidPullToRefresh(
                        onRefresh: () => controller.getAllWorks(),
                        color: mainColor,
                        // backgroundColor: secColor,
                        animSpeedFactor: 2,
                        height: 300,
                        child: carCardStyleForMobile(
                            controller: controller,
                            color: const Color.fromARGB(255, 50, 212, 56),
                            status: 'New',
                            listName: controller.carCards),
                      );
              }
            }));
  }
}

class DataSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return GetX<AllWorksController>(builder: (controller) {
      final AllWorksController allWorksController =
          Get.put(AllWorksController());

      allWorksController.filterResults(query);

      if (controller.filteredCarCards.isEmpty) {
        return Center(
            child: Text(
          'No Cards Yet',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: mainColor, fontSize: 25),
        ));
      } else {
        return kIsWeb
            ? carCardStyleForMWeb(
                controller: controller,
                listName: controller.filteredCarCards,
                color: const Color.fromARGB(255, 50, 212, 56),
                status: 'New')
            : carCardStyleForMobile(
                controller: controller,
                color: const Color.fromARGB(255, 50, 212, 56),
                status: 'New',
                listName: controller.filteredCarCards);
      }
    });
  }
}
