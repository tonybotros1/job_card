import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/card_details_screen_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_card/models/image_model.dart';
import 'package:job_card/models/job_card_model.dart';
import 'package:job_card/screens/edit_card_screen.dart';
import 'package:job_card/screens/single_image_viewer.dart';
import 'package:job_card/screens/video_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  CarDetailsScreen({super.key});

  final CardDetailsController cardDetailsController =
      Get.put(CardDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: mainColor,
          title: const Text('Details'),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {
                  Get.to(
                    () => EditCardScreen(),
                    arguments: JobCardModel(
                        carImages: cardDetailsController.carImages,
                        customerSignature:
                            cardDetailsController.customerSignature,
                        carBrand: cardDetailsController.carBrand,
                        carMileage: cardDetailsController.carMileage,
                        carModel: cardDetailsController.carModel,
                        chassisNumber: cardDetailsController.chassisNumber,
                        color: cardDetailsController.color,
                        customerName: cardDetailsController.customerName,
                        date: cardDetailsController.date,
                        emailAddress: cardDetailsController.emailAddress,
                        fuelAmount: cardDetailsController.fuelAmount,
                        phoneNumber: cardDetailsController.phoneNumber,
                        plateNumber: cardDetailsController.plateNumber,
                        docID: cardDetailsController.id,
                        carVideo: cardDetailsController.video),
                  );
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: GetBuilder<CardDetailsController>(
            init: CardDetailsController(),
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                controller.customerName,
                                style: GoogleFonts.mooli(fontSize: 30),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                controller.phoneNumber,
                                style: GoogleFonts.mooli(
                                    fontSize: 20, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width,
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Images',
                                style: GoogleFonts.mooli(
                                    fontSize: 14, color: Colors.grey[900]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              controller.carImages.isNotEmpty
                                  ? GridView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller.carImages.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3),
                                      itemBuilder: (context, i) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: FittedBox(
                                              fit: BoxFit.cover,
                                              clipBehavior: Clip.hardEdge,
                                              child: InkWell(
                                                onTap: () {
                                                  Get.to(
                                                      () => SingleImageViewer(),
                                                      arguments: ImageModel(
                                                          url: controller
                                                              .carImages[i]));
                                                },
                                                child: Image.network(
                                                    controller.carImages[i]),
                                              )),
                                        );
                                      })
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width,
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Video',
                                style: GoogleFonts.mooli(
                                    fontSize: 14, color: Colors.grey[900]),
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: secColor),
                                  onPressed: () {
                                    Get.to(() => VideoScreen(),
                                        arguments:
                                            ImageModel(url: controller.video));
                                  },
                                  child: const Text('Watch Video'))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width,
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              cardDetails(
                                  title: 'Car Brand | Model:',
                                  icon: Icons.directions_car,
                                  controller:
                                      '${controller.carBrand} | ${controller.carModel}'),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Car Color:',
                                  icon: Icons.color_lens,
                                  controller: controller.color),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Chassis Number:',
                                  icon: Icons.tag,
                                  controller: controller.chassisNumber),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Plate Number:',
                                  icon: Icons.pin,
                                  controller: controller.plateNumber),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Car Mileage:',
                                  icon: Icons.add_road,
                                  controller: '${controller.carMileage} KM'),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Fuel Amount',
                                  icon: Icons.local_gas_station_outlined,
                                  controller: '${controller.fuelAmount} %'),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Email:',
                                  icon: Icons.email,
                                  controller: controller.emailAddress),
                              const SizedBox(
                                height: 35,
                              ),
                              cardDetails(
                                  title: 'Received On:',
                                  icon: Icons.date_range,
                                  controller: controller.date)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: Get.width,
                        color: containerColor,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Customer Signature',
                                style: GoogleFonts.mooli(
                                    fontSize: 14, color: Colors.grey[900]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Image.network(controller.customerSignature),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Row cardDetails(
      {required String title,
      required IconData icon,
      required String controller}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: secColor,
                size: 35,
              )
            ],
          ),
        ),
        Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                ),
                Text(
                  controller,
                  style: const TextStyle(fontSize: 14),
                )
              ],
            ))
      ],
    );
  }
}
