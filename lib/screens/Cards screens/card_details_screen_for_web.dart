import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_card/widgets/screen_size_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
          toolbarHeight: 75,
          centerTitle: true,
          // automaticallyImplyLeading: false,
          backgroundColor: mainColorForWeb,
          title: Text(
            '${cardDetailsController.carBrand} ${cardDetailsController.carModel}'
                .toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.grey[700]),
          ),
          actions: [
            GetBuilder<CardDetailsController>(
                init: CardDetailsController(),
                builder: (controller) {
                  return CupertinoSwitch(
                      value: controller.status,
                      onChanged: (val) {
                        controller.changeStatus(val);
                      });
                }),
            SizedBox(
              width: 25,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
              children: [
                Container(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 2.5),
                    child: Column(children: [
                      // Container(
                      //   padding: const EdgeInsets.all(20.0),
                      //   width: constraints.maxWidth,
                      //   decoration: BoxDecoration(
                      //       color: containerColor,
                      //       borderRadius: const BorderRadius.only(
                      //           bottomRight: Radius.circular(15),
                      //           bottomLeft: Radius.circular(15),
                      //           topLeft: Radius.circular(15),
                      //           topRight: Radius.circular(15))),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(Icons.arrow_back),
                      //         onPressed: () {
                      //           Get.back();
                      //         },
                      //       ),
                      //       SizedBox(
                      //         width: 30,
                      //       ),
                      //       Expanded(
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             FittedBox(
                      //               child: SelectableText(
                      //                 cardDetailsController.customerName,
                      //                 style: GoogleFonts.mooli(fontSize: 30),
                      //               ),
                      //             ),
                      //             const SizedBox(
                      //               height: 10,
                      //             ),
                      //             cardDetailsController.phoneNumber.isNotEmpty
                      //                 ? SelectableText(
                      //                     cardDetailsController.phoneNumber,
                      //                     style: GoogleFonts.mooli(
                      //                         fontSize: 20,
                      //                         color: Colors.grey[600]),
                      //                   )
                      //                 : const SizedBox(),
                      //           ],
                      //         ),
                      //       ),
                      //       GetBuilder<CardDetailsController>(
                      //           init: CardDetailsController(),
                      //           builder: (controller) {
                      //             return CupertinoSwitch(
                      //                 value: controller.status,
                      //                 onChanged: (val) {
                      //                   controller.changeStatus(val);
                      //                 });
                      //           })
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(
                        height: 5,
                      ),
                      cardDetailsController.comments.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  )),
                              width: Get.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comments',
                                    style: GoogleFonts.mooli(
                                        fontSize: 20, color: Colors.grey[900]),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: constraints.maxWidth,
                                    child: ReadMoreText(
                                      isExpandable: true,
                                      cardDetailsController.comments,
                                      trimLines: 2,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Read more',
                                      trimExpandedText: ' Read less',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[600]),
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
                            )
                          : const SizedBox(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        child: ScreenSize.isNotWeb(context)
                            ? Column(
                                children: [
                                  // cardDetails(
                                  //     title: 'Car Brand | Model:',
                                  //     icon: Icons.directions_car,
                                  //     controller:
                                  //         '${cardDetailsController.carBrand} ${cardDetailsController.carModel}'),
                                  cardDetails(
                                    title: 'Customer Name | Number',
                                    icon: Icons.person,
                                    controller:
                                        '${cardDetailsController.customerName} ${cardDetailsController.phoneNumber}',
                                  ),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // cardDetails(
                                        //     title: 'Car Brand | Model',
                                        //     icon: Icons.directions_car,
                                        //     controller:
                                        //         '${cardDetailsController.carBrand} ${cardDetailsController.carModel}'),
                                        cardDetails(
                                          title: 'Customer Name | Number',
                                          icon: Icons.person,
                                          controller:
                                              '${cardDetailsController.customerName} ${cardDetailsController.phoneNumber}',
                                        ),
                                        cardDetails(
                                            title: 'Car Color',
                                            icon: Icons.color_lens,
                                            controller: cardDetailsController
                                                    .color.isNotEmpty
                                                ? cardDetailsController.color
                                                : ''),
                                        cardDetails(
                                            title: 'Chassis Number',
                                            icon: Icons.tag,
                                            controller: cardDetailsController
                                                    .chassisNumber.isNotEmpty
                                                ? cardDetailsController
                                                    .chassisNumber
                                                : ''),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        cardDetails(
                                            title: 'Plate Number',
                                            icon: Icons.pin,
                                            controller: cardDetailsController
                                                    .plateNumber.isNotEmpty
                                                ? cardDetailsController
                                                    .plateNumber
                                                : ''),
                                        cardDetails(
                                            title: 'Email',
                                            icon: Icons.email,
                                            controller: cardDetailsController
                                                    .emailAddress.isNotEmpty
                                                ? cardDetailsController
                                                    .emailAddress
                                                : ''),
                                        cardDetails(
                                            title: 'Received On',
                                            icon: Icons.date_range,
                                            controller:
                                                cardDetailsController.date),
                                      ],
                                    ),
                                  ),
                                  ScreenSize.isWeb(context)
                                      ? Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              CircularPercentIndicator(
                                                radius:
                                                    80.0, // Size of the circle
                                                lineWidth:
                                                    10.0, // Thickness of the circle line
                                                percent: 100 /
                                                    100, // Convert percentage to a value between 0 and 1
                                                center: FittedBox(
                                                  child: Column(
                                                    children: [
                                                      Text('Car Mileage',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      SelectableText(
                                                        "${cardDetailsController.carMileage} KM", // Display fuel amount
                                                        style: TextStyle(
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                progressColor:
                                                    mainColor, // Progress bar color
                                                backgroundColor: Colors.grey[
                                                    300]!, // Background color
                                                circularStrokeCap:
                                                    CircularStrokeCap
                                                        .round, // Rounded ends
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              CircularPercentIndicator(
                                                radius:
                                                    80.0, // Size of the circle
                                                lineWidth:
                                                    10.0, // Thickness of the circle line
                                                percent: cardDetailsController
                                                        .fuelAmount /
                                                    100, // Convert percentage to a value between 0 and 1
                                                center: FittedBox(
                                                  child: Column(
                                                    children: [
                                                      Text('Fuel Amount',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                        "${cardDetailsController.fuelAmount}%", // Display fuel amount
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                progressColor:
                                                    mainColor, // Progress bar color
                                                backgroundColor: Colors.grey[
                                                    300]!, // Background color
                                                circularStrokeCap:
                                                    CircularStrokeCap
                                                        .round, // Rounded ends
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(2.5, 0, 10, 10),
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        child: Container(
                          decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
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
                      )
                    ]))
              ],
            );
          }),
        ));
  }
}
