import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_card/widgets/screen_size_widget.dart';
import 'package:readmore/readmore.dart';

import '../../const.dart';
import '../../controllers/Cards Screens Controllers/card_details_screen_controller.dart';
import '../../widgets/Details screen widgets/details_card_for_web.dart';
import '../../widgets/Details screen widgets/details_images_side_for_web.dart';

class CardDetailsScreenForWeb extends StatelessWidget {
  CardDetailsScreenForWeb({super.key});

  final CardDetailsController cardDetailsController =
      Get.put(CardDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: mainColorForWeb,
        title: const Text('Details', style: TextStyle(color: iconColor)),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 2.5),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  topLeft: Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        child: SelectableText(
                                          cardDetailsController.customerName,
                                          style:
                                              GoogleFonts.mooli(fontSize: 30),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      cardDetailsController
                                              .phoneNumber.isNotEmpty
                                          ? SelectableText(
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
                        cardDetailsController.comments.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    color: containerColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    )),
                                width: Get.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Comments',
                                        style: GoogleFonts.mooli(
                                            fontSize: 14,
                                            color: Colors.grey[900]),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth,
                                        child: ReadMoreText(
                                          isExpandable: true,
                                          cardDetailsController.comments,
                                          trimLines: 1,
                                          trimMode: TrimMode.Line,
                                          trimCollapsedText: 'Read more',
                                          trimExpandedText: ' Read less',
                                          style: const TextStyle(fontSize: 15),
                                          textAlign: TextAlign.start,
                                          moreStyle: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                          lessStyle: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        ScreenSize.isNotWeb(context)
                            ? Column(
                                children: [
                                  cardDetails(
                                      title: 'Car Brand | Model:',
                                      icon: Icons.directions_car,
                                      controller:
                                          '${cardDetailsController.carBrand} ${cardDetailsController.carModel}'),
                                  cardDetails(
                                      title: 'Car Color:',
                                      icon: Icons.color_lens,
                                      controller:
                                          cardDetailsController.color.isNotEmpty
                                              ? cardDetailsController.color
                                              : ''),
                                  cardDetails(
                                      title: 'Chassis Number:',
                                      icon: Icons.tag,
                                      controller: cardDetailsController
                                              .chassisNumber.isNotEmpty
                                          ? cardDetailsController.chassisNumber
                                          : ''),
                                  cardDetails(
                                      title: 'Plate Number:',
                                      icon: Icons.pin,
                                      controller: cardDetailsController
                                              .plateNumber.isNotEmpty
                                          ? cardDetailsController.plateNumber
                                          : ''),
                                  const SizedBox(
                                      height:
                                          20), // Add space between the two columns
                                  cardDetails(
                                      title: 'Car Mileage:',
                                      icon: Icons.add_road,
                                      controller: cardDetailsController
                                              .carMileage.isNotEmpty
                                          ? '${cardDetailsController.carMileage} KM'
                                          : ''),
                                  cardDetails(
                                      title: 'Fuel Amount:',
                                      icon: Icons.local_gas_station_outlined,
                                      controller:
                                          '${cardDetailsController.fuelAmount} %'),
                                  cardDetails(
                                      title: 'Email:',
                                      icon: Icons.email,
                                      controller: cardDetailsController
                                              .emailAddress.isNotEmpty
                                          ? cardDetailsController.emailAddress
                                          : ''),
                                  cardDetails(
                                      title: 'Received On:',
                                      icon: Icons.date_range,
                                      controller: cardDetailsController.date),
                                ],
                              )
                            : Container(
                                width: Get.width,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            cardDetails(
                                                title: 'Car Brand | Model:',
                                                icon: Icons.directions_car,
                                                controller:
                                                    '${cardDetailsController.carBrand} ${cardDetailsController.carModel}'),
                                            cardDetails(
                                                title: 'Car Color:',
                                                icon: Icons.color_lens,
                                                controller:
                                                    cardDetailsController
                                                            .color.isNotEmpty
                                                        ? cardDetailsController
                                                            .color
                                                        : ''),
                                            cardDetails(
                                                title: 'Chassis Number:',
                                                icon: Icons.tag,
                                                controller:
                                                    cardDetailsController
                                                            .chassisNumber
                                                            .isNotEmpty
                                                        ? cardDetailsController
                                                            .chassisNumber
                                                        : ''),
                                            cardDetails(
                                                title: 'Plate Number:',
                                                icon: Icons.pin,
                                                controller:
                                                    cardDetailsController
                                                            .plateNumber
                                                            .isNotEmpty
                                                        ? cardDetailsController
                                                            .plateNumber
                                                        : ''),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            cardDetails(
                                                title: 'Car Mileage:',
                                                icon: Icons.add_road,
                                                controller: cardDetailsController
                                                        .carMileage.isNotEmpty
                                                    ? '${cardDetailsController.carMileage} KM'
                                                    : ''),
                                            cardDetails(
                                                title: 'Fuel Amount:',
                                                icon: Icons
                                                    .local_gas_station_outlined,
                                                controller:
                                                    '${cardDetailsController.fuelAmount} %'),
                                            cardDetails(
                                                title: 'Email:',
                                                icon: Icons.email,
                                                controller:
                                                    cardDetailsController
                                                            .emailAddress
                                                            .isNotEmpty
                                                        ? cardDetailsController
                                                            .emailAddress
                                                        : ''),
                                            cardDetails(
                                                title: 'Received On:',
                                                icon: Icons.date_range,
                                                controller:
                                                    cardDetailsController.date),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(2.5, 0, 10, 10),
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )),
                          width: constraints.maxWidth,
                          // constraints:
                          // BoxConstraints(maxWidth: constraints.maxWidth),
                          child: SingleChildScrollView(
                            child: detailsImagesSide(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      }),
    );
  }
}
