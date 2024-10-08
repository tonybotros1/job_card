import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/finished_works_screen_controller.dart';
import 'package:job_card/widgets/card%20style%20widgets/car_card_style_for_web.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../widgets/Side menu widgets/side_menu_widgets.dart';
import '../../widgets/card style widgets/car_card_style_for_mobile.dart';
import '../../widgets/screen_size_widget.dart';

class FinishedWorksScreen extends StatelessWidget {
  FinishedWorksScreen({super.key});
  final FinishedWorksController finishedWorksController =
      Get.put(FinishedWorksController());

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
              : null,
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
                    const Flexible(
                      child: AutoSizeText(
                        'Compass Automatic Gear',
                        style: TextStyle(color: iconColor),
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Finished Cards',
                  style: TextStyle(color: Colors.white),
                ),
          centerTitle: kIsWeb ? false : true,
          backgroundColor: kIsWeb ? mainColorForWeb : mainColor,
          actions: [
            Obx(() => AutoSizeText(
                  'Number of Cards: ${finishedWorksController.numberOfCars.value}',
                  style: const TextStyle(color: iconColor),
                )),
            const SizedBox(
              width: 10,
            ),
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
        body: GetX<FinishedWorksController>(
            init: FinishedWorksController(),
            builder: (controller) {
              if (controller.carCards.isEmpty) {
                return Center(
                    child: Text(
                  'No Cards Yet',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      fontSize: 25),
                ));
              } else {
                return kIsWeb
                    ? carCardStyleForMWeb(
                        controller: controller,
                        listName: controller.carCards,
                        color: Colors.grey.shade800,
                        status: 'Added')
                    : LiquidPullToRefresh(
                        onRefresh: () => controller.getFinishedWorks(),
                        color: mainColor,
                        // backgroundColor: secColor,
                        animSpeedFactor: 2,
                        height: 300,
                        child: carCardStyleForMobile(
                            controller: controller,
                            color: Colors.grey,
                            status: 'Added',
                            listName: controller.carCards));
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
    return GetX<FinishedWorksController>(builder: (controller) {
      final FinishedWorksController finishedWorksController =
          Get.put(FinishedWorksController());

      finishedWorksController.filterResults(query);

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
                color: Colors.grey.shade800,
                status: 'Added')
            : carCardStyleForMobile(
                controller: controller,
                color: Colors.grey,
                status: 'Added',
                listName: controller.filteredCarCards);
      }
    });
  }
}
