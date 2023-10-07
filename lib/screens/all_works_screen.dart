import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/all_works_screen_controller.dart';
import 'package:job_card/screens/car_details_screen.dart';
import '../models/job_card_model.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});
  final AllWorksController allWorksController = Get.put(AllWorksController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('New Cards'),
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
        // floatingActionButton: FloatingActionButton(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10.0),
        //   ),
        //   backgroundColor: mainColor,
        //   onPressed: () {},
        //   child: IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () {
        //       Get.to(() => JobCardScreen(), transition: Transition.leftToRight);
        //     },
        //   ),
        // ),
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
                                          MainAxisAlignment.start,
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
                                            // Display a green checkmark if status is true, otherwise display a red "X"
                                            // Icon(
                                            //   carCard['status'] == true
                                            //       ? Icons.check_circle
                                            //       : Icons.cancel,
                                            //   color: carCard['status'] == true
                                            //       ? Colors.green
                                            //       : Colors.grey,
                                            //   size: 35,
                                            // ),
                                            Container(
                                              width: 70,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color:
                                                      carCard['status'] == true
                                                          ? Color.fromARGB(
                                                              255, 50, 212, 56)
                                                          : Colors.grey),
                                              child: Center(
                                                  child: carCard['status'] ==
                                                          true
                                                      ? Text(
                                                          'New',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      : Text(
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
                              // const Text(
                              //   'Mileage:',
                              //   style: TextStyle(
                              //     fontSize: 19,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                              // Text(
                              //   '${carCard['car_mileage']} km',
                              //   style: const TextStyle(
                              //     fontSize: 16,
                              //     color: Colors.black54,
                              //   ),
                              // ),
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