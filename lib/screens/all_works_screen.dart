import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/all_works_screen_controller.dart';

import '../models/job_card_model.dart';
import 'edit_card_screen.dart';
import 'job_card_screen.dart';

class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});
  final AllWorksController allWorksController = Get.put(AllWorksController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('All Cards'),
          centerTitle: true,
          backgroundColor: mainColor,
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                },
                icon: const Icon(Icons.search))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: mainColor,
          onPressed: () {},
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => JobCardScreen(), transition: Transition.leftToRight);
            },
          ),
        ),
        body: GetX<AllWorksController>(
            init: AllWorksController(),
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
                return ListView.builder(
                    itemCount: controller.carCards.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      var carCard = controller.carCards[i];
                      return Card(
                        elevation: 20,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () {
                                  Get.to(() => EditCardScreen(),
                                      arguments: JobCardModel(
                                          carBrand: carCard['car_brand'],
                                          carMileage: carCard['car_mileage'],
                                          carModel: carCard['car_model'],
                                          chassisNumber:
                                              carCard['chassis_number'],
                                          color: carCard['color'],
                                          customerName:
                                              carCard['customer_name'],
                                          date: carCard['date'],
                                          emailAddress:
                                              carCard['email_address'],
                                          fuelAmount: carCard['fuel_amount'],
                                          phoneNumber: carCard['phone_number'],
                                          plateNumber: carCard['plate_number'],
                                          docID: carCard.id,
                                          carVideo: carCard['car_video']
                                          ),
                                      transition: Transition.leftToRight);
                                },
                                child: SizedBox(
                                  height: 120,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FittedBox(
                                                child: Text(
                                              '${carCard['customer_name']}',
                                              style: fontStyle,
                                            )),
                                            FittedBox(
                                                child: Text(
                                              '${carCard['date']}',
                                              style: fontStyle2,
                                            )),
                                            FittedBox(
                                              child: IconButton(
                                                  onPressed: () {
                                                    controller.shareToSocialMedia(
                                                        'Dear ${carCard['customer_name']},\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: ${carCard['car_brand']}, ${carCard['car_model']}\nPlate:  ${carCard['plate_number']}\nMileage: ${carCard['car_mileage']} km\nChassis No.: ${carCard['chassis_number']}\nColor:  ${carCard['color']}\nReceived on: ${carCard['date']}\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear');
                                                  },
                                                  icon: Icon(
                                                    Icons.share,
                                                    color: mainColor,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            FittedBox(
                                              child: Text(
                                                '${carCard['car_brand']}',
                                                style: fontStyle2,
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                '${carCard['car_model']}',
                                                style: fontStyle2,
                                              ),
                                            ),
                                            FittedBox(
                                              child: Text(
                                                '${carCard['plate_number']}',
                                                style: fontStyle2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))),
                      );
                    });
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
              return Card(
                elevation: 20,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onLongPress: () {
                          // controller.shareToWhatsApp(carCard['phone_number'],
                          //     'Hello this is Compass Automatic Gear! \n This is a copy of details of your car \n Customer Name: ${carCard['customer_name']} \n Car Brand: ${carCard['car_brand']} \n Car Model: ${carCard['car_model']} \n Plate Number: ${carCard['plate_number']} \n Car Mileage: ${carCard['car_mileage']} \n Chassis Number: ${carCard['chassis_number']} \n Date: ${carCard['date']} \n Car Color: ${carCard['color']}');
                        },
                        onTap: () {
                          Get.to(() => EditCardScreen(),
                              arguments: JobCardModel(
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
                                  docID: carCard.id),
                              transition: Transition.leftToRight);
                        },
                        child: SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                        child: Text(
                                      '${carCard['customer_name']}',
                                      style: fontStyle,
                                    )),
                                    FittedBox(
                                        child: Text(
                                      '${carCard['date']}',
                                      style: fontStyle2,
                                    )),
                                    FittedBox(
                                      child: IconButton(
                                          onPressed: () {
                                            controller.shareToSocialMedia(
                                                'Dear ${carCard['customer_name']},\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: ${carCard['car_brand']}, ${carCard['car_model']}\nPlate:  ${carCard['plate_number']}\nMileage: ${carCard['car_mileage']} km\nChassis No.: ${carCard['chassis_number']}\nColor:  ${carCard['color']}\nReceived on: ${carCard['date']}\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear');
                                          },
                                          icon: Icon(
                                            Icons.share,
                                            color: mainColor,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        '${carCard['car_brand']}',
                                        style: fontStyle2,
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        '${carCard['car_model']}',
                                        style: fontStyle2,
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        '${carCard['plate_number']}',
                                        style: fontStyle2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))),
              );
            });
      }
    });
  }
}



// ListTile(
//                                 contentPadding: const EdgeInsets.all(16),
//                                 title: Text(
//                                   '${carCard['customer_name']}',
//                                   style: fontStyle,
//                                 ),
//                                 subtitle: Text('${carCard['date']}'),
//                                 trailing: Column(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     SizedBox(
//                                       child: Text(
//                                         '${carCard['car_brand']}  ${carCard['car_model']}',
//                                         style: fontStyle,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       child: Text(
//                                         '${carCard['plate_number']}',
//                                         style: fontStyle,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),