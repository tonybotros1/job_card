import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/Cards%20Screens%20Controllers/all_works_screen_controller.dart';
import 'package:job_card/screens/auth/login_screen.dart';
import 'package:job_card/screens/Cards%20screens/card_details_screen.dart';
import '../../models/job_card_model.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../widgets/screen_size_widget.dart';
import '../../widgets/side_menu_widgets.dart';

class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});
  final AllWorksController allWorksController = Get.put(AllWorksController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: kIsWeb
            ? ScreenSize.isNotWeb(context)
                ? SizedBox(
                    width:ScreenSize.isMobile(context) ? 100 : 180,
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
                                    Get.offAll(() => LoginScreen());
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
              ? const Text(
                  'Compass Automatic Gear',
                  style: TextStyle(color: iconColor),
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
                return LiquidPullToRefresh(
                  onRefresh: () => controller.getAllWorks(),
                  color: mainColor,
                  // backgroundColor: secColor,
                  animSpeedFactor: 2,
                  height: 300,
                  showChildOpacityTransition: false,
                  child: ListView.builder(
                      itemCount: controller.carCards.length,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        var carCard = controller.carCards[i];
                        List<String> carImages = [];

                        for (var item in carCard['car_images']) {
                          try {
                            carImages.add(item.toString());
                          } catch (e) {
                            // Handle the exception, or skip the item if necessary
                          }
                        }

                        return Card(
                          surfaceTintColor: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => CarDetailsScreen(),
                                  arguments: JobCardModel(
                                      carImages: carImages,
                                      customerSignature:
                                          carCard['customer_signature'],
                                      carBrand: carCard['car_brand'],
                                      carMileage: carCard['car_mileage'],
                                      carModel: carCard['car_model'],
                                      chassisNumber: carCard['chassis_number'],
                                      color: carCard['color'],
                                      customerName: carCard['customer_name'],
                                      date: carCard['date'],
                                      emailAddress: carCard['email_address'],
                                      fuelAmount: carCard['fuel_amount'],
                                      phoneNumber: carCard['phone_number'],
                                      plateNumber: carCard['plate_number'],
                                      comments: carCard['comments'],
                                      docID: carCard.id,
                                      carVideo: carCard['car_video'],
                                      status: carCard['status']),
                                  transition: Transition.leftToRight);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Customer:',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        FittedBox(
                                          child: Text(
                                            '${carCard['customer_name']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Car:',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          '${carCard['car_brand']} | ${carCard['car_model']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Plate Number:',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        FittedBox(
                                          child: Text(
                                            '${carCard['plate_number']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Received On:',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: mainColor,
                                          ),
                                        ),
                                        Text(
                                          '${carCard['date']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: carCard['status'] ==
                                                          true
                                                      ? const Color.fromARGB(
                                                          255, 50, 212, 56)
                                                      : Colors.grey),
                                              child: Center(
                                                  child: carCard['status'] ==
                                                          true
                                                      ? const Text(
                                                          'New',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : const Text(
                                                          'Added',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                controller.shareToSocialMedia(
                                                  'Dear ${carCard['customer_name']},\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: ${carCard['car_brand']}, ${carCard['car_model']}\nPlate:  ${carCard['plate_number']}\nMileage: ${carCard['car_mileage']} km\nChassis No.: ${carCard['chassis_number']}\nColor:  ${carCard['color']}\nReceived on: ${carCard['date']}\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear',
                                                );
                                              },
                                              icon: Icon(
                                                Icons.share,
                                                color: mainColor,
                                                size: 35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
        return ListView.builder(
            itemCount: controller.filteredCarCards.length,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              var carCard = controller.filteredCarCards[i];
              List<String> carImages = [];

              for (var item in carCard['car_images']) {
                try {
                  carImages.add(item.toString());
                } catch (e) {
                  // Handle the exception, or skip the item if necessary
                }
              }
              return Card(
                surfaceTintColor: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => CarDetailsScreen(),
                        arguments: JobCardModel(
                            carImages: carImages,
                            customerSignature: carCard['customer_signature'],
                            carBrand: carCard['car_brand'],
                            carMileage: carCard['car_mileage'],
                            carModel: carCard['car_model'],
                            chassisNumber: carCard['chassis_number'],
                            color: carCard['color'],
                            customerName: carCard['customer_name'],
                            date: carCard['date'],
                            emailAddress: carCard['email_address'],
                            fuelAmount: carCard['fuel_amount'],
                            phoneNumber: carCard['phone_number'],
                            plateNumber: carCard['plate_number'],
                            comments: carCard['comments'],
                            docID: carCard.id,
                            carVideo: carCard['car_video'],
                            status: carCard['status']),
                        transition: Transition.leftToRight);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer:',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${carCard['customer_name']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Car:',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${carCard['car_brand']} | ${carCard['car_model']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Plate Number:',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '${carCard['plate_number']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Received On:',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            Text(
                              '${carCard['date']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 15),
                            IconButton(
                              onPressed: () {
                                controller.shareToSocialMedia(
                                    'Dear ${carCard['customer_name']},\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: ${carCard['car_brand']}, ${carCard['car_model']}\nPlate:  ${carCard['plate_number']}\nMileage: ${carCard['car_mileage']} km\nChassis No.: ${carCard['chassis_number']}\nColor:  ${carCard['color']}\nReceived on: ${carCard['date']}\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear');
                              },
                              icon: Icon(
                                Icons.share,
                                color: mainColor,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }
    });
  }
}
