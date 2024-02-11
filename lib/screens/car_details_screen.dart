import 'package:flutter/cupertino.dart';
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
          title: const Text(
            'Details',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          centerTitle: true,
          actions: [
            cardDetailsController.status == true
                ? TextButton(
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
                : SizedBox()
          ],
        ),
        body: Padding(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  cardDetailsController.customerName,
                                  style: GoogleFonts.mooli(fontSize: 30),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              cardDetailsController.phoneNumber.isNotEmpty
                                  ? Text(
                                      cardDetailsController.phoneNumber,
                                      style: GoogleFonts.mooli(
                                          fontSize: 20,
                                          color: Colors.grey[600]),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        GetBuilder<CardDetailsController>(
                            init: CardDetailsController(),
                            builder: (controller) {
                              return CupertinoSwitch(
                                  value: controller.status,
                                  onChanged: (val) {
                                    controller.changeStatus(val);
                                  });
                            })
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
                        cardDetailsController.carImages.isNotEmpty
                            ? GridView.builder(
                                // padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                itemCount:
                                    cardDetailsController.carImages.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: FittedBox(
                                          fit: BoxFit.cover,
                                          clipBehavior: Clip.hardEdge,
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(() => SingleImageViewer(),
                                                  arguments: ImageModel(
                                                      url: cardDetailsController
                                                          .carImages[i]));
                                            },
                                            child: Image.network(
                                                cardDetailsController
                                                    .carImages[i]),
                                          )),
                                    ),
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
                        cardDetailsController.video.isNotEmpty
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: secColor),
                                onPressed: () {
                                  Get.to(() => VideoScreen(),
                                      arguments: ImageModel(
                                          url: cardDetailsController.video));
                                },
                                child: const Text('Watch Video'))
                            : const SizedBox()
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
                                '${cardDetailsController.carBrand} | ${cardDetailsController.carModel}'),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Car Color:',
                            icon: Icons.color_lens,
                            controller: cardDetailsController.color.isNotEmpty
                                ? cardDetailsController.color
                                : ''),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Chassis Number:',
                            icon: Icons.tag,
                            controller:
                                cardDetailsController.chassisNumber.isNotEmpty
                                    ? cardDetailsController.chassisNumber
                                    : ''),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Plate Number:',
                            icon: Icons.pin,
                            controller:
                                cardDetailsController.plateNumber.isNotEmpty
                                    ? cardDetailsController.plateNumber
                                    : ''),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Car Mileage:',
                            icon: Icons.add_road,
                            controller:
                                cardDetailsController.carMileage.isNotEmpty
                                    ? '${cardDetailsController.carMileage} KM'
                                    : ''),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Fuel Amount:',
                            icon: Icons.local_gas_station_outlined,
                            controller:
                                '${cardDetailsController.fuelAmount} %'),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Email:',
                            icon: Icons.email,
                            controller:
                                cardDetailsController.emailAddress.isNotEmpty
                                    ? cardDetailsController.emailAddress
                                    : ''),
                        const SizedBox(
                          height: 35,
                        ),
                        cardDetails(
                            title: 'Received On:',
                            icon: Icons.date_range,
                            controller: cardDetailsController.date)
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
                Image.network(cardDetailsController.customerSignature),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
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
