import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../const.dart';
import '../../models/job_card_model.dart';
import '../../screens/Cards screens/card_details_screen.dart';

Widget carCardStyleForMobile(
    {required controller,
    required listName,
    required Color color,
    required String status}) {
  return ListView.builder(
      itemCount: listName.length,
      shrinkWrap: true,
      itemBuilder: (context, i) {
        var carCard = listName[i];
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 70,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: color
                                  // carCard['status'] == true
                                  //     ? const Color.fromARGB(255, 50, 212, 56)
                                  //     : Colors.grey,
                                  ),
                              child: Center(
                                  child: Text(
                                status,
                                style: const TextStyle(color: Colors.white),
                              )
                                  //  carCard['status'] == true
                                  //     ? const Text(
                                  //         'New',
                                  //         style: TextStyle(color: Colors.white),
                                  //       )
                                  //     : const Text(
                                  //         'Added',
                                  //         style: TextStyle(color: Colors.white),
                                  //       ),
                                  ),
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
      });
}
